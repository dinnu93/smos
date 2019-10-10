{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

module Smos.Sync.Server.Handler.PostRegister
  ( handlePostRegister
  ) where

import Smos.Sync.Server.Handler.Import

import qualified Data.ByteString.Lazy as LB
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Time

handlePostRegister :: Register -> SyncHandler NoContent
handlePostRegister Register {..} = do
  maybeHashedPassword <- liftIO $ passwordHash registerPassword
  case maybeHashedPassword of
    Nothing -> throwError err400 {errBody = "Failed to hash password."}
    Just hashedPassword -> do
      now <- liftIO getCurrentTime
      let user =
            User
              { userUsername = registerUsername
              , userHashedPassword = hashedPassword
              , userCreated = now
              }
      maybeUserEntity <- runDB . getBy $ UniqueUsername $ userUsername user
      case maybeUserEntity of
        Nothing -> runDB $ insert_ user
        Just _ ->
          throwError
            err409
              { errBody =
                  LB.fromStrict $
                  TE.encodeUtf8 $
                  T.unwords
                    ["Account with the username", usernameText registerUsername, "already exists."]
              }
  pure NoContent
