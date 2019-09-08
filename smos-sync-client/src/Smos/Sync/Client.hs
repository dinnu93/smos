{-# LANGUAGE RecordWildCards #-}

module Smos.Sync.Client
  ( smosSyncClient
  ) where

import Smos.Sync.Client.OptParse
import Smos.Sync.Client.Sync

smosSyncClient :: IO ()
smosSyncClient = do
  Instructions dispatch Settings {..} <- getInstructions
  case dispatch of
    DispatchSync ss -> syncSmosSyncClient ss