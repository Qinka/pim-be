module Debug where

import Yesod.Core
import Control.Monad.Logger(LogSource(..),runStderrLoggingT,LoggingT)

pimShouldLog :: LogSource -> LogLevel -> IO Bool
pimShouldLog a LevelInfo      = print (1,a)   >> return True
pimShouldLog a LevelDebug     = print (1,a)   >> return True
pimShouldLog a LevelWarn      = print (1,a)   >> return True
pimShouldLog a LevelError     = print (1,a)   >> return True
pimShouldLog a (LevelOther b) = print (1,a,b) >> return True

pimLogger :: MonadIO m => LoggingT m a -> m a
pimLogger = runStderrLoggingT
