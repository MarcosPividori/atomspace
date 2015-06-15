
module Types (
      AtomGen(..)
    , IsAtom(..)
    , Concept(..)
    , Predicate(..)
    , Schema(..)
    , List(..)
    , Execution(..)
    , Evaluation(..)
    , TruthVal(..)
    , AtomName(..)
    ) where

type AtomName = String
data TruthVal = SimpleTruthVal Double Double
              | CountTruthVal Double Double Double
              | IndefiniteTruthVal Double Double Double Double
    deriving Show

data AtomGen = AtomConcept    Concept
             | AtomPredicate  Predicate
             | AtomSchema     Schema
             | AtomList       List
             | AtomEvaluation Evaluation
             | AtomExecution  Execution
    deriving Show

class IsAtom a where
    toAtom   :: a -> AtomGen
    fromAtom :: AtomGen -> Maybe a

data Concept = Concept AtomName (Maybe TruthVal)
    deriving Show

data Predicate = Predicate AtomName
    deriving Show

data Schema = Schema AtomName
    deriving Show

data List = List [AtomGen]
    deriving Show
    
data Evaluation = Evaluation (Maybe TruthVal) Predicate List
    deriving Show

data Execution = Execution Schema List AtomGen
    deriving Show

instance IsAtom Concept where
    toAtom = AtomConcept
    fromAtom (AtomConcept c) = Just c 
    fromAtom _               = Nothing 

instance IsAtom Predicate where
    toAtom = AtomPredicate
    fromAtom (AtomPredicate p) = Just p
    fromAtom _                 = Nothing 

instance IsAtom Schema where
    toAtom = AtomSchema
    fromAtom (AtomSchema s) = Just s 
    fromAtom _              = Nothing 

instance IsAtom List where
    toAtom = AtomList
    fromAtom (AtomList l) = Just l
    fromAtom _            = Nothing 

instance IsAtom Execution where
    toAtom = AtomExecution
    fromAtom (AtomExecution e) = Just e
    fromAtom _                 = Nothing 

instance IsAtom Evaluation where
    toAtom = AtomEvaluation
    fromAtom (AtomEvaluation e) = Just e
    fromAtom _                  = Nothing 

