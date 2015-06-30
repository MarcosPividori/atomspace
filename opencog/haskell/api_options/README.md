#Atom Data Type Definition:

When developing the data type definitions for atoms, we have some main goals:

- We want to impose type restrictions in how atoms connect between them, I mean,
we want to constrain the class of atoms that a certain link type includes in its
outgoing set, established by the hierarchy:
```
 Atom
  |   \
 Node Link
  |      \
 Concept  Evaluation
  ...
```
Everywhere we need a Node, we can place an SchemaNode or a ConceptNode,
but we can't place a ListLink for example. We want the compiler to check this.

For example, an ExecutionLink,
as defined on [ExecutionLink](http://wiki.opencog.org/w/ExecutionLink), has in its outgoing
set: first has an schema node, then a list link and then any atom type.
We want the compiler to check this type conditions.

So, we need to incorporate this hierarchy to the haskell type environment:

- We need to go upward and downward in class hierarchy.
For example, if we have some atom of class Schema, we need to be able to use it as a Node (upward).
Also, if we have an atom of class Node, some times we need to know the real atom type,
for example SchemaNode, GroundedSchemaNode, etc (downward).

- Also, we need a common data type to group all atom types, let's call it AtomGen.
We need this, for example, when defining a ListLink, where we need to define a list of atoms: [AtomGen], or when defining a query functionality on the atomspace like: getByName :: Name -> AtomSpace [AtomGen]
So, we need a way to group all atoms types in a same data type. But this process has to be reversible, I mean, we need to be able to get the specific atom back from AtomGen. For example, when examining the items of a ListLink.

Looking for a solution to this, the first approaches are:

## OPTION 3 - code: [./Option3](https://github.com/MarcosPividori/atomspace/tree/data-options/opencog/haskell/api_options/Option3)

We define a different data type for each atom type, and an associated type
class, in order to impose the type constraints.
```haskell
data ConceptNode   = ConceptNode AtomName (Maybe TV)
data PredicateNode = PredicateNode AtomName
data SchemaNode    = SchemaNode AtomName
data GroundedSchemaNode = GroundedSchemaNode AtomName
data ListLink      = ListLink [AtomGen]
data ExecutionLink = forall s l a. (IsSchema s, IsList l,IsAtom a)
                   => ExecutionLink s l a
```
And we define the proper class hierarchy between them, through Type Classes.
(This could be done automatically from the types.script file)
```haskell
class IsAtom a where
    toAtom   :: a -> AtomGen
class IsAtom a   => IsNode a
class IsAtom a   => IsLink a
class IsNode a   => IsConcept a
class IsNode a   => IsPredicate a
class IsNode a   => IsSchema a
class IsSchema a => IsGroundedSchema a
class IsLink a   => IsList a
class IsLink a   => IsExecution a
```
By defining them this way, the compiler knows than an Schema is also a Node and
is also an Atom, etc. I mean, the compiler can follow hierarchy upwards.
So, we define the instances of these classes:
```haskell
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

And finally, we define a general data type:

data AtomGen = GenConcept        ConceptNode
             | GenPredicate      PredicateNode
             | GenSchema         SchemaNode
             | GenGroundedSchema GroundedSchemaNode
             | GenList           ListLink
             | GenExecution      ExecutionLink
```

----------------------------------------------------------------------

So lets analyse the main goals:

- Atom hierarchy: OK. Combining data types and type classes.
It works really well. For example:
```haskell
-- Type checking OK:
   ex1 = ExecutionLink
      (GroundedSchemaNode "some-fun")
      (ListLink [ toAtom $ ConceptNode "Arg1" someTv
                , toAtom $ ConceptNode "Arg2" someTv
                ])
      (ConceptNode "res" someTv)

-- Type checking error:
   ex2 = ExecutionLink
      (ConceptNode "some-conc" Nothing) -- This type isn't instance of IsSchema
      (PredicateNode "some-pred")       -- This type isn't instance of IsList
      (ConceptNode "res" someTv)
```
- Upward/Downward:
Upward: Type classes, automatically.
Downward: if we have some instance of IsA and we know A 
is an atom type, then
we can convert it to the AtomGen general data type with toAtom, and then we can do
pattern matching over AtomGen to know the specific atom type. For example:
```haskell
    case ex1 of
        ExecutionLink x _ _ -> case toAtom x of
            GenGroundedSchema _ -> print "We have a GSchema"
            GenSchema         _ -> print "We have a Schema"
```
- General data type:
We define AtomGen as a general atom type, with a different constructor for each
atom type.

 We avoid the problem with fromAtom in Option 2.
 Now, we can do pattern matching on an atom type, for example, on the
 items of a list:
```haskell
         case l of
            List x:xs -> case x of
                AtomConcept (Concept c)     -> we have a concept
                AtomPredicate (Predicate p) -> we have a predicate
```

## Option4 - GADTs: [./Option4](https://github.com/MarcosPividori/atomspace/tree/data-options/opencog/haskell/api_options/Option4)

With GADTs, we can group together all atom types in a same data type Atom a,
where the "a" type variable is used as a phantom type to carry the atom type
information and impose type constraints.
So, we define empty data types for each atom type:
```haskell
data ConceptT
data SchemaT
data GroundedSchemaT
data ListT
data ExecutionT
```
And we define the proper class hierarchy between them, through Type Classes.
(This could be done automatically from the types.script file)
```haskell
class IsAtom
class IsAtom a => IsNode a
class IsAtom a => IsLink a
class IsNode a => IsConcept a
class IsNode a => IsSchema a
class IsSchema a => IsGroundedSchema a
class IsLink a => IsList a
class IsLink a => IsExecution a
```
By defining them this way, the compiler knows than an Schema is also a Node and
is also an Atom, etc. I mean, the compiler can follow hierarchy upwards.
So, we define the instances of these classes:
```haskell
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

Now, we can define the Atom data type, imposing type restrictions in how atoms
relate between them through phantom types and type classes!

data Atom a where
    ConceptNode    :: AtomName -> Maybe TV -> Atom ConceptT
    SchemaNode     :: AtomName -> Atom SchemaT
    GroundedSchemaNode :: AtomName -> Atom GroundedSchemaT
    ListLink       :: [AtomGen] -> Atom ListT
    ExecutionLink  :: (IsSchema s,IsList l,IsAtom a)
                   => Atom s -> Atom l -> Atoma -> Atom ExecutionT

AtomGen = forall a. AtomGen (Atom a)
```
-------------------------------------------------

So lets analyse the main goals:

- Atom hierarchy: OK. Combining phantom types, type classes and GADTs.
It works really well. For example:
```haskell
-- Type checking OK:
ex = ExecutionLink
   (GroundedSchemaNode "some-fun")
   (ListLink [ AtomGen $ ConceptNode "Arg1" someTv
             , AtomGen $ ConceptNode "Arg2" someTv
             ])
   (ConceptNode "res" someTv)

-- Type checking error:
exx = ExecutionLink
   (ConceptNode "some-conc" Nothing) -- ConceptT type isn't instance of IsSchema
   (PredicateNode "some-pred")       -- PredicateT type isn't instance of IsList
   (ConceptNode "res" someTv)
```
- Upward/Downward:
Upward: Type classes, automatically!

Downward: Pattern Matching on GADTs constructors!
As we are using GADTs to group all atom types
we have the advantages of doing pattern matching on the constructors to know
which specific atom type we have. For example:
```haskell
    case ex1 of
        ExecutionLink x _ _ -> case x of
            GroundedSchemaNode _ -> print "We have a GSchema"
            SchemaNode         _ -> print "We have a Schema"
```
- General data type:
We define a general data type AtomGen using Existential Quantifiers over the
phantom type 'a' in the type Atom a, and adding a constructor AtomGen.


 Also, with GADTs, we avoid using a different constructor for each type of Atom inside AtomGen.
 Now, we can do pattern matching on an atom type, for example, on the
 items of a list:

```haskell
         case l of
            List x:xs -> case x of
                AtomGen (Concept c _) -> we have a concept
                AtomGen (Predicate p) -> we have a predicate
```
 Also, some flexibilities of using GADTs, such as
 the ability to work with a generic data type: Atom a
 (unless we need to group many instances such as with lists, where we
 have to use AtomGen). We can let the type instance 'a'
 be determined by the compiler if necessary.
