\begin{code}
module Main where

import Data.Aeson
import Data.Maybe
import Data.Time
import Yesod.Core
import Yesod.Core.Json
import Yesod.Persist
import Database.Persist
import Database.Persist.Postgresql
import Database.Persist.TH
import System.Environment
import Control.Monad.Logger (runStderrLoggingT)
import Control.Monad.Trans.Resource (runResourceT)
import Control.Monad.Trans.Reader

import Data.Text(Text)
import qualified Data.Text as T
import qualified Data.ByteString.Char8 as BC8


import Debug

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Todo json
  own Text
  context Text
  date Day
  prioity Text
  deriving Show Eq
Note json
  own Text
  context Text
  prioity Text
  deriving Show Eq
Appointment json
  own Text
  context Text
  date Day
  prioity Text
  deriving Show Eq
Contact json
  fname Text
  lname Text
  email Text
  own Text
  prioity Text
  deriving Show Eq
|]


data App = App
           { dbPool :: ConnectionPool
           }


mkYesod "App" [parseRoutes|
/list             ListR              GET
/list/todo        ListTodoR          GET
/list/note        ListNoteR          GET
/list/appointment ListAppointmentR   GET
/list/contact     ListContactR       GET

/add              AddR               POST
|]

instance Yesod App where
  shouldLogIO _ = pimShouldLog
instance YesodPersist App where
  type YesodPersistBackend App = SqlBackend
  runDB a = getYesod >>= (runSqlPool a . dbPool)

getListR :: Handler Value
getListR = do
  own <- lookupGetParam "own"
  begin <- readMT <$> lookupGetParam "begin"
  end   <- readMT <$> lookupGetParam "end"
  todos        <- map (kv "todo")        <$> fetchTodos        own begin end
  notes        <- map (kv "note")        <$> fetchNotes        own
  appointments <- map (kv "appointment") <$> fetchAppointments own begin end
  contacts     <- map (kv "contact")     <$> fetchContacts     own
  returnSuccess $ todos ++ appointments ++ contacts ++ notes
  
getListTodoR :: Handler Value
getListTodoR = do
  own <- lookupGetParam "own"
  begin <- readMT <$> lookupGetParam "begin"
  end   <- readMT <$> lookupGetParam "end"
  returnSuccess =<< map (kv "todo") <$> fetchTodos own begin end

getListNoteR :: Handler Value
getListNoteR = do
  own <- lookupGetParam "own"
  returnSuccess =<< map (kv "note") <$> fetchNotes own

getListAppointmentR :: Handler Value
getListAppointmentR = do
  own <- lookupGetParam "own"
  begin <- readMT <$> lookupGetParam "begin"
  end   <- readMT <$> lookupGetParam "end"
  returnSuccess =<< map (kv "appointment") <$> fetchAppointments own begin end

getListContactR :: Handler Value
getListContactR = do
  own <- lookupGetParam "own"
  returnSuccess =<< map (kv "contact") <$> fetchContacts own


postAddR :: Handler Value
postAddR = do
  typ <- lookupGetParam "type"
  case typ of
    Just "todo"          -> addTodo
    Just "note"          -> addNote
    Just "appointment"   -> addAppointment
    Just "contact"       -> addContact
    _                    -> invalidArgs ["need type"]
  where addTodo        = updateDateable Todo        (Just TodoOwn)        (Just TodoContext)        (Just TodoDate)
        addAppointment = updateDateable Appointment (Just AppointmentOwn) (Just AppointmentContext) (Just AppointmentDate)
        addNote        = updateItem     Note        (Just NoteOwn)        (Just NoteContext)
        addContact     = do
          i       <- readMT <$> lookupPostParam "id"
          own     <-            lookupPostParam "own"
          lname   <-            lookupPostParam "lname"
          fname   <-            lookupPostParam "fname"
          email   <-            lookupPostParam "email"
          prioity <-            lookupPostParam "prioity"
          case i of
            Just i' -> do
              let up = catMaybes [(Just ContactOwn) `match` own,(Just ContactLname) `match` lname, (Just ContactFname) `match` fname]
              runDB $ update i' up
              returnSuccess ()
            Nothing -> case (own,lname,fname,email,prioity) of
              (Just o,Just l,Just f,Just e,Just p) -> returnSuccess =<< (runDB $ insert $ Contact f l e o p)
              (Nothing,_,_,_,_) -> invalidArgs ["need own"]
              (_,Nothing,_,_,_) -> invalidArgs ["need last  name"]
              (_,_,Nothing,_,_) -> invalidArgs ["need first name"]
              (_,_,_,Nothing,_) -> invalidArgs ["need email"]
              (_,_,_,_,Nothing) -> invalidArgs ["need prioity"]




main :: IO ()
main = do
  now <- getCurrentTime
  port:args <- unwords <$> getArgs
  pimLogger $ withPostgresqlPool (BC8.pack args) 100 $ \pool -> liftIO $
    warp (read port) $ App pool


\end{code}

common for add
\begin{code}
updateDateable :: ( PersistEntity v
                  , ToJSON k
                  , Read k
                  , EntityField v Text ~ o
                  , EntityField v Text ~ c
                  , EntityField v Day ~ d
                  , Key v ~ k
                  , PersistEntityBackend v ~ SqlBackend
                  ) 
               => (Text -> Text -> Day -> Text-> v) 
               -> Maybe o -> Maybe c -> Maybe d
               -> Handler Value
updateDateable func vo vc vd = do
  i       <- readMT <$> lookupPostParam "id"
  own     <-            lookupPostParam "own"
  context <-            lookupPostParam "context"
  date    <- readMT <$> lookupPostParam "date"
  prioity <-            lookupPostParam "prioity"
  case i of
    Just i' -> do
      let up = catMaybes [vo `match` own,vc `match` context, vd `match` date]
      runDB $ update i' up
      returnSuccess ()
    Nothing -> case (own,context,date,prioity) of
      (Just o,Just c, Just d,Just p) -> returnSuccess =<< (runDB $ insert $ func o c d p)
      (Nothing,_,_,_) -> invalidArgs ["need owner"]
      (_,Nothing,_,_) -> invalidArgs ["need context"]
      (_,_,Nothing,_) -> invalidArgs ["need date"]
      (_,_,_,Nothing) -> invalidArgs ["need prioity"]
      
match (Just f) (Just v) = Just $ f =. v
match _        _        = Nothing

updateItem :: ( PersistEntity v
              , ToJSON k
              , Read k
              , EntityField v Text ~ o
              , EntityField v Text ~ c
              , Key v ~ k
              , PersistEntityBackend v ~ SqlBackend
              ) 
            => (Text -> Text -> Text -> v) 
            -> Maybe o -> Maybe c
            -> Handler Value
updateItem func vo vc = do
  i       <- readMT <$> lookupPostParam "id"
  own     <-            lookupPostParam "own"
  context <-            lookupPostParam "context"
  prioity <-            lookupPostParam "prioity"
  case i of
    Just i' -> do
      let up = catMaybes [vo `match` own,vc `match` context]
      runDB $ update i' up
      returnSuccess ()
    Nothing -> case (own,context,prioity) of
      (Just o,Just c,Just p) -> returnSuccess =<< (runDB $ insert $ func o c p)
      (Nothing,_,_) -> invalidArgs ["need owner"]
      (_,Nothing,_) -> invalidArgs ["need context"]
      (_,_,Nothing) -> invalidArgs ["need prioity"]
\end{code}


Common for fetch 
\begin{code}
fetchFilter :: ( EntityField v Text ~ o
               , EntityField v Day ~ d
               , PersistEntity v
               )
            => Maybe o    -> Maybe d
            -> Maybe Text -> Maybe Day -> Maybe Day
            -> [Filter v]
fetchFilter fo fd vo vb ve = catMaybes $ [match' fo vo (==.), match' fd vb (>=.),match' fd ve (<=.)]
  where match' (Just a) (Just b) opt = Just $ a `opt` b
        match' _ _ _                 = Nothing

fetchItems :: ( EntityField v Text ~ o
              , EntityField v Day ~ d
              , PersistEntity v
              , Key v ~ k
              , PersistEntityBackend v ~ SqlBackend
              )
           => Maybe o    -> Maybe d
           -> Maybe Text -> Maybe Day -> Maybe Day
           -> [SelectOpt v]
           -> Handler [(k,v)]
fetchItems fo fd vo vb ve asc = mapEntities =<< runDB (selectList fl $ asc)
  where fl = fetchFilter fo fd vo vb ve

mapEntities :: (PersistEntity v, Key v ~ k)
            => [Entity v] -> Handler [(k,v)]
mapEntities = return . map (\(Entity key item) -> (key,item))

returnSuccess :: ToJSON a => a -> Handler Value
returnSuccess item = returnJson $ object ["status" .= (0::Int), "context" .= item]

kv :: (PersistEntity v,Key v ~ k,ToJSON v,ToJSON k) => Text -> (k,v) -> Value
kv t (k,v) = object [ "id" .= k,t .= v]

readMT :: Read a => Maybe Text -> Maybe a
readMT = fmap (read . T.unpack)
\end{code}

For fetch todo
\begin{code}
fetchTodos ::  Maybe Text -> Maybe Day -> Maybe Day -> Handler [(TodoId,Todo)]
fetchTodos own beg end = fetchItems (Just TodoOwn) (Just TodoDate) own beg end [Desc TodoDate]
\end{code}

For fetch note
\begin{code}
fetchNotes :: Maybe Text -> Handler [(NoteId,Note)]
fetchNotes own = fetchItems (Just NoteOwn) Nothing own Nothing Nothing []
\end{code}

For fetch appointment
\begin{code}
fetchAppointments :: Maybe Text -> Maybe Day -> Maybe Day -> Handler [(AppointmentId,Appointment)]
fetchAppointments own beg end = fetchItems (Just AppointmentOwn) (Just AppointmentDate) own beg end [Desc AppointmentDate]
\end{code}

For fetch contact
\begin{code}
fetchContacts :: Maybe Text -> Handler [(ContactId,Contact)]
fetchContacts own = fetchItems (Just ContactOwn) Nothing own Nothing Nothing []
\end{code}

