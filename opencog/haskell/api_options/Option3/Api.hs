{-# LANGUAGE GADTs #-}

module Api (
      insert
    , remove
    , get
    , AtomSpace
    ) where

import Types
import Data.Functor                 ((<$>))

type AtomSpace = IO

insert :: IsAtom a => a -> AtomSpace ()
insert i = do
    putStrLn $ "call insert: " ++ (show i)
    -- undefined

remove :: IsAtom a => a -> AtomSpace ()
remove i = do
    putStrLn $ "call remove: " ++ (show i)
    --undefined foreign call to removeAtom.

get :: IsAtom a => a -> AtomSpace (Maybe a)
get i = do
    putStrLn $ "call get: " ++ show i
    undefined

