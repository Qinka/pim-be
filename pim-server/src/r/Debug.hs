module Debug where

import Yesod.Core
import Control.Monad.Logger(LogSource(..),NoLoggingT(..))

pimShouldLog :: LogSource -> LogLevel -> IO Bool
pimShouldLog _ LevelInfo      = return True
pimShouldLog _ LevelDebug     = return False
pimShouldLog _ LevelWarn      = return False
pimShouldLog _ LevelError     = return True
pimShouldLog _ (LevelOther _) = return False

pimLogger :: MonadIO m => NoLoggingT m a -> m a
pimLogger = runNoLoggingT
