#Atom Data Type Definition:

## OPTION 1 - code: [./Option1](https://github.com/MarcosPividori/atomspace/tree/data-options/opencog/haskell/api_options/Option1)
 - *Advantages*: Same type for all Atoms, so it is simple to define common
 functions that takes an atom as argument, such as: insert, remove, etc.

 - *Disadvantages*: We can differenciate between a Node and a Link through pattern
 matching, but we don't have different types for Nodes and Links.
 So, we can't add type restrictions, for example, we can not
 define a function that only accepts Links or Nodes.
 Also, we can not impose type restrictions in how atoms connect
 between them, I mean, we can not constrain the kind of atoms
 that a certain link type includes in its outgoing set.


## OPTION 2 - code: [./Option2](https://github.com/MarcosPividori/atomspace/tree/data-options/opencog/haskell/api_options/Option2)
  - *Advantages*: We have differents types for each Atom type, so we can use this
 type information for adding restrictions, for example, we can
 define specific functions that only accept certain types of Atoms.
 For example:
```haskell
                    specific_concept_fun :: ConceptNode -> ...
                    specific_execlink_fun :: ExecutionLink -> ...
```
 Also, for example, be can be sure than the output of a call to
 get with an atom of one type will return the same kind of atom.
 For example:
```haskell
                    do 
                      n <- get ConceptNode "Alan"
                      m <- get ListLink [toAtom (ConceptNode "Alan")]
                           --we can be sure that:  n :: Maybe ConceptNode
                           --                      m :: Maybe ListLink
```
 We can impose type restrictions in how atoms connect
 between them. I mean, we can constrain the kind of atoms
 that a certain link type includes in its outgoing set.

  - *Disadvantages*:
 fromAtom :: Atom -> Maybe a,  is ok when we know the type of the atom
 wrapped in the general type Atom, for example, in the call to the
 function get :: a -> AtomSpace (Maybe a), the get can wrap the parameter
 a in the type atom with toAtom, then try to get it from the atomspace,
 and then unwrap it with fromAtom, because it knows it wants to retrieve
 some value of type a.
 On the other hand, if we have a ListLink, for example, with a list of
 Atoms, we don't know the type of the atoms wrapped there, so we don't
 know which instance of the function fromAtom to call.

## OPTION 3 - code: [./Option3](https://github.com/MarcosPividori/atomspace/tree/data-options/opencog/haskell/api_options/Option3)
```haskell
       data AtomGen = AtomConcept Concept
                    | AtomList List
                    | AtomPredicate Predicate
                    ...
```
 - *Advantages*:
 Same than on Option 2 + avoid the problem with fromAtom.
 Now, we can do pattern matching on an atom type, for example, on the
 items of a list:
```haskell
         case l of
            List x:xs -> case x of
                AtomConcept (Concept c)     -> we have a concept
                AtomPredicate (Predicate p) -> we have a predicate
```

## OPTION 4 GADTs - code: [./Option4](https://github.com/MarcosPividori/atomspace/tree/data-options/opencog/haskell/api_options/Option4)
 - *Advantages*:
 Same than on Option 3 + avoid using a different constructor for each type
 of Atom inside AtomGen.
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
