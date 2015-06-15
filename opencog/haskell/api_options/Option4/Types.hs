{-# LANGUAGE GADTs , EmptyDataDecls , ExistentialQuantification , RankNTypes #-}

module Types (
      Atom(..)
    , AtomGen(..)
    , TruthVal(..)
    , AtomName(..)
    , TConceptNode
    , TSchemaNode
    , appAtomGen
    ) where

type AtomName = String
data TruthVal = SimpleTruthVal Double Double
              | CountTruthVal Double Double Double
              | IndefiniteTruthVal Double Double Double Double
    deriving Show

data AtomGen where
    AtomGen :: Atom a -> AtomGen

appAtomGen :: (forall a. Atom a -> b) -> AtomGen -> b
appAtomGen f (AtomGen at) = f at

data TConceptNode
data TSchemaNode

data Atom a where
    Concept     :: AtomName -> (Maybe TruthVal) -> Atom TConceptNode
    Predicate   :: AtomName -> Atom (Atom a -> TruthVal)
    Schema      :: AtomName -> Atom TSchemaNode
    Evaluation  :: (Atom (Atom b -> TruthVal)) ->
                    Atom [AtomGen] -> Maybe TruthVal -> Atom a
    Execution   :: Atom TSchemaNode ->
                     Atom [AtomGen] -> Atom b -> Atom a
    List        :: [AtomGen] -> Atom [AtomGen]

instance Show AtomGen where
    show (AtomGen at) = concat' ["AtomGen",show at]

instance Show (Atom a) where
    show (Concept n m)        = concat' ["Concept",show n,show m]
    show (Predicate n)        = concat' ["Predicate",show n]
    show (Schema n)           = concat' ["Schema",show n]
    show (Evaluation a1 a2 m) = concat' ["Evaluation",show a1,show a2,show m]
    show (Execution a1 a2 a3) = concat' ["Execution",show a1,show a2,show a3]
    show (List l)             = concat' ["List",show l]

concat' (a:b:xs) = a ++ " " ++ concat' (b:xs)
concat' (b:[])   = b
concat' []       = ""
