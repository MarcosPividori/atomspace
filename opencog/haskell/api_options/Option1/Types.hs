
module Types (
      Atom(..)
    , TruthVal(..)
    , AtomType(..)
    , AtomName(..)
    ) where

type AtomName = String
data AtomType = Concept
              | Predicate
              | Schema
              | List
              | Execution
              | Evaluation

instance Show AtomType where
    show Concept    = "ConceptNode"
    show Predicate  = "PredicateNode"
    show Schema     = "SchemaNode"
    show List       = "ListLink"
    show Execution  = "ExecutionLink"
    show Evaluation = "EvaluationLink"

data TruthVal = SimpleTruthVal Double Double
              | CountTruthVal Double Double Double
              | IndefiniteTruthVal Double Double Double Double
    deriving Show

data Atom = Link {  linkType     :: AtomType
                 ,  linkOutGoing :: [Atom]
                 ,  linkTv       :: Maybe TruthVal
                 } 
          | Node {  nodeType  :: AtomType
                 ,  nodeName  :: AtomName
                 ,  nodeTv    :: Maybe TruthVal
                 }
    deriving Show

