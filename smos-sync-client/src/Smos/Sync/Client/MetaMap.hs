{-# LANGUAGE DeriveGeneric #-}

-- |
--
-- Import this module qualified
module Smos.Sync.Client.MetaMap
  ( MetaMap (..),
    empty,
    singleton,
    fromList,
    insert,
    union,
    unions,
  )
where

import Control.DeepSeq
import Control.Monad
import Data.Map (Map)
import qualified Data.Map as M
import Data.Validity
import Data.Validity.ByteString ()
import Data.Validity.Containers ()
import Data.Validity.Path ()
import GHC.Generics (Generic)
import Path
import Smos.Sync.Client.DirForest
import Smos.Sync.Client.Env

newtype MetaMap
  = MetaMap
      { metaMapFiles :: Map (Path Rel File) SyncFileMeta
      }
  deriving (Show, Eq, Generic)

instance Validity MetaMap where
  validate mm =
    mconcat
      [ genericValidate mm,
        decorate "The map can be translated to a valid DirForest" $
          case makeDirForest $ metaMapFiles mm of
            Left fp -> invalid $ "Duplicate path: " <> fp
            Right df -> validate df
      ]

instance NFData MetaMap

empty :: MetaMap
empty = MetaMap M.empty

singleton :: Path Rel File -> SyncFileMeta -> MetaMap
singleton k v = MetaMap $ M.singleton k v

fromList :: [(Path Rel File, SyncFileMeta)] -> Maybe MetaMap
fromList = constructValid . MetaMap . M.fromList

insert :: Path Rel File -> SyncFileMeta -> MetaMap -> Maybe MetaMap
insert k v (MetaMap m) = constructValid $ MetaMap $ M.insert k v m

union :: MetaMap -> MetaMap -> Maybe MetaMap
union (MetaMap m1) (MetaMap m2) = constructValid $ MetaMap $ M.union m1 m2

unions :: [MetaMap] -> Maybe MetaMap
unions = foldM union empty
