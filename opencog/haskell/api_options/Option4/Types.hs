{-# LANGUAGE GADTs , EmptyDataDecls , ExistentialQuantification , RankNTypes #-}

module Types where

data TV = SimpleTV Double Double
        | CountTV Double Double Double
        | IndefiniteTV Double Double Double Double
    deriving Show

type AtomName = String

data PredicateT
data ConceptT
data SchemaT
data GroundedSchemaT
data ListT
data ExecutionT

class IsAtom a
class IsAtom a => IsNode a
class IsAtom a => IsLink a
class IsNode a => IsConcept a
class IsNode a => IsPredicate a
class IsNode a => IsSchema a
class IsSchema a => IsGroundedSchema a
class IsLink a => IsList a
class IsLink a => IsExecution a

instance IsAtom PredicateT
instance IsNode PredicateT
instance IsPredicate PredicateT

instance IsAtom ConceptT
instance IsNode ConceptT
instance IsConcept ConceptT

instance IsAtom SchemaT
instance IsNode SchemaT
instance IsSchema SchemaT

instance IsAtom GroundedSchemaT
instance IsNode GroundedSchemaT
instance IsSchema GroundedSchemaT
instance IsGroundedSchema GroundedSchemaT

instance IsAtom ListT
instance IsLink ListT
instance IsList ListT

instance IsAtom ExecutionT
instance IsLink ExecutionT
instance IsExecution ExecutionT

data Atom a where
    ConceptNode    :: AtomName -> Maybe TV -> Atom ConceptT
    PredicateNode  :: AtomName -> Atom PredicateT
    SchemaNode     :: AtomName -> Atom SchemaT
    GroundedSchemaNode :: AtomName -> Atom GroundedSchemaT
    ListLink       :: [AtomGen] -> Atom ListT
    ExecutionLink  :: (IsSchema s,IsList l,IsAtom g)
                   => Atom s -> Atom l -> Atom g -> Atom ExecutionT

data AtomGen = forall a. AtomGen (Atom a)

instance Show AtomGen where
    show (AtomGen at) = concat' ["AtomGen",show at]

instance Show (Atom a) where
    show (ConceptNode n m)        = concat' ["ConceptNode",show n,show m]
    show (PredicateNode n)        = concat' ["PredicateNode",show n]
    show (SchemaNode n)           = concat' ["SchemaNode",show n]
    show (GroundedSchemaNode n)   = concat' ["GroundedSchemaNode",show n]
    show (ListLink l)             = concat' ["ListLink",show l]
    show (ExecutionLink a1 a2 a3) = concat' ["ExecutionLink",show a1,show a2,show a3]

concat' (a:b:xs) = a ++ " " ++ concat' (b:xs)
concat' (b:[])   = b
concat' []       = ""
