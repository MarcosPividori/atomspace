{-# LANGUAGE GADTs , EmptyDataDecls , ExistentialQuantification , RankNTypes #-}

module Types where

data TV = SimpleTV Double Double
        | CountTV Double Double Double
        | IndefiniteTV Double Double Double Double
    deriving Show

type AtomName = String

data ConceptNode   = ConceptNode AtomName (Maybe TV)              deriving Show
data PredicateNode = PredicateNode AtomName                       deriving Show
data SchemaNode    = SchemaNode AtomName                          deriving Show
data GroundedSchemaNode = GroundedSchemaNode AtomName             deriving Show
data ListLink      = ListLink [AtomGen]                           deriving Show
data ExecutionLink = forall s l a. (IsSchema s, IsList l,IsAtom a)
                   => ExecutionLink s l a

instance Show ExecutionLink where
    show (ExecutionLink a b c) = "ExecutionLink " ++
                                  show a ++ " " ++
                                  show b ++ " " ++
                                  show c

class (Show a)   => IsAtom a where
    toAtom   :: a -> AtomGen
class IsAtom a   => IsNode a
class IsAtom a   => IsLink a
class IsNode a   => IsConcept a
class IsNode a   => IsPredicate a
class IsNode a   => IsSchema a
class IsSchema a => IsGroundedSchema a
class IsLink a   => IsList a
class IsLink a   => IsExecution a

instance IsAtom PredicateNode where
    toAtom = GenPredicate
instance IsNode PredicateNode
instance IsPredicate PredicateNode

instance IsAtom ConceptNode where
    toAtom = GenConcept
instance IsNode ConceptNode
instance IsConcept ConceptNode

instance IsAtom SchemaNode where
    toAtom = GenSchema
instance IsNode SchemaNode
instance IsSchema SchemaNode

instance IsAtom GroundedSchemaNode where
    toAtom = GenGroundedSchema
instance IsNode GroundedSchemaNode
instance IsSchema GroundedSchemaNode
instance IsGroundedSchema GroundedSchemaNode

instance IsAtom ListLink where
    toAtom = GenList
instance IsLink ListLink
instance IsList ListLink

instance IsAtom ExecutionLink where
    toAtom = GenExecution
instance IsLink ExecutionLink
instance IsExecution ExecutionLink


data AtomGen = GenConcept        ConceptNode
             | GenPredicate      PredicateNode
             | GenSchema         SchemaNode
             | GenGroundedSchema GroundedSchemaNode
             | GenList           ListLink
             | GenExecution      ExecutionLink
    deriving Show

instance IsAtom AtomGen where
    toAtom = id
