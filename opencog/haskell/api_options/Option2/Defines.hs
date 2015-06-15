
module Defines (
      Concept(..)
    , Predicate(..)
    , Schema(..)
    , List(..)
    , Execution(..)
    , Evaluation(..)
    ) where

import Api

data Concept = Concept AtomName (Maybe TruthVal)

data Predicate = Predicate AtomName

data Schema = Schema AtomName

data List = List [Atom]
    
data Evaluation = Evaluation (Maybe TruthVal) Predicate List

data Execution = Execution Schema List Atom

instance IsAtomType Concept where
    atomType _ = "ConceptNode"
    inst = let from aname tv    = Just $ Concept aname tv
               to (Concept a b) = (a,b)
            in Node from to

instance IsAtomType Predicate where
    atomType _ = "PredicateNode"
    inst = let from aname _     = Just $ Predicate aname
               to (Predicate a) = (a,Nothing)
            in Node from to

instance IsAtomType Schema where
    atomType _ = "SchemaNode"
    inst = let from aname _  = Just $ Schema aname
               to (Schema a) = (a,Nothing)
            in Node from to

instance IsAtomType List where
    atomType _ = "ListLink"
    inst = let from aout _   = Just $ List aout
               to (List out) = (out,Nothing)
            in Link from to

instance IsAtomType Execution where
    atomType _ = "ExecutionLink"
    inst = let from (a:b:c:[]) _  = do
                                      a1 <- fromAtom a
                                      b1 <- fromAtom b
                                      return $ Execution a1 b1 c
               from _          _  = Nothing
               to (Execution a b c) = ([toAtom a,toAtom b,c],Nothing)
            in Link from to

instance IsAtomType Evaluation where
    atomType _ = "EvaluationLink"
    inst = let from (s:l:[]) tv = do
                                    s1 <- fromAtom s
                                    l1 <- fromAtom l
                                    return $ Evaluation tv s1 l1
               from _        _  = Nothing
               to (Evaluation tv s l) = ([toAtom s,toAtom l],tv)
            in Link from to

