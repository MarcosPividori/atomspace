{-# LANGUAGE GADTs #-}

module Api (
      insert
    , remove
    , get
    , AtomSpace
    ) where

import Types
import Data.Functor                 ((<$>))

type AtomType = String
type AtomSpace = IO


insert :: Atom a -> AtomSpace ()
insert i = do
    putStrLn $ "call insert: " ++ (show i)
    -- undefined

remove :: Atom a -> AtomSpace ()
remove i = do
    putStrLn $ "call remove: " ++ (show i)
    --undefined foreign call to removeAtom.

get :: Atom a -> AtomSpace (Maybe (Atom a))
get i = do
    putStrLn $ "call get: " ++ show i
    undefined

