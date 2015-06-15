#Atoms Data:

**ATOM**
 * Mutable:
    - Attention Value
    - Truth Value
 * Immutable and unique:
    - Handle ID

**LINK**
  * Immutable and unique:
     - Type
     - Outgoing

**NODE**
  * Immutable and unique:
     - Type
     - Name

#AtomSpace Api:

  - **insert** : inserts an atom to the AtomSpace. (~ similar to INSERT/UPDATE of SQL)

  - **remove** : removes an atom from the AtomSpace. (~ similar to DELETE of SQL)

  - **get** : gets an atom from the AtomSpace. In fact, it looks for a specific
    atom in the atomspace and retrieves it, which means retrieving the mutable
    data: Truth Val and Attention Val. (~ similar to SELECT of SQL)
    
    In future, we could add other similar functions to search by node name,
    link outgoing, type, etc. (getting multiple atoms)

#Atoms Notation:

(From: Engineering General Intelligence Part 2 "2.2 Denoting Atoms")
General sintaxis:
```
  LinkType ListOfAtoms(outgoing) <optional truth value> <<optional att value>>

  NodeType NodeName              <optional truth value> <<optional att value>>
```
We can use indent notation to avoid ambiguity when writing Link's outgoing lists.

# Atoms Representation:

So, we want to develop an EDSL, Embeeded Domain Specific Language
([ref](https://wiki.haskell.org/Embedded_domain_specific_language)), to interact
with Atoms and the AtomSpace, embeeded in Haskell.
To develop an EDSL, we are going to work around a data type for representing
Atoms, let's name it "Atom".

Also, we want to take advantages of Haskell type system to specify type
restrictions on the type of the Atoms and how they combine together, so we need
to incorporate these restrictions in the construction of the data type "Atom".

The main goals on Atom representation is:
 - We want to use a simple EDSL to create new atoms, as similar as possible to
   the Atoms Notation described above ("Atoms Notation").
   For example:
```haskell
    ... do
          insert $ AndLink
                       ConceptNode "something"
                       ConceptNode "other thing"
                       <0.5,0.5>
          ...
```
 - We want to be able to do Pattern Matching over the atoms types to follow the
   atom relation, from one to another.
   For example:
```haskell
    ... case node of
          AndLink a1 a2 tv -> do something
          ConceptNode name -> do something
          ...
```

For creating new atoms and working with atoms data types, we have different options:
  - Work directly with the Data Constructors, for example, if we define the AndLink data constructor as:
```haskell
       AndLink :: Atom -> Atom -> Maybe TruthVal -> Atom
```
   Then we can use it to create a new node as:
```haskell
      AndLink (ConceptNode "something" Nothing)
              (ConceptNode "other thing" Nothing) (Just (0.5,0.5))
```
```haskell
    ---------------------------------------------------------------------------
    {-# LANGUAGE GADTs #-}

    data Atom a where
        ConceptNode :: String -> Maybe TruthVal -> Atom a
        Link :: Atom b -> Atom c -> Maybe TruthVal -> Atom a

    main = let nod = Link
                        (ConceptNode "Joan" Nothing)
                        (ConceptNode "Juan" (Just (0.5,0.4))
                        (Just (0.3,0.2))
            in
              case nod of
                ConceptNode _ _ -> putStrLn "We have a ConceptNode"
                Link _ _ _      -> putStrLn "We have a Link"
    --------------------------------------------------------------------------
```
 The problem with this approach is that we are limited to use the Haskell
 sintaxis, we can not use indentation notation, we have to use
 parenthesis to specify asociation, we can not make truth values optional, we
 have to always specify this parameter as Nothing or (Just value). I mean,
 we are using the internal representation.
 As advantage, we are using the same representation that we can access through
 pattern matching, data type constructors and internal representation,
 so we build and unpack atoms using the same notation.

  - To improve the syntax of the embedded language, we could avoid the usage
  of data constructors directly, and replace them by specific functions to build atom types:
```haskell
    ---------------------------------------------------------------------------
    {-# LANGUAGE PostfixOperators, GADTs #-}

    data Atom a where
        ConceptNode :: String -> TV -> Atom a
        Link :: Atom b -> Atom c -> TV -> Atom a

    conceptNode :: String -> Atom a
    conceptNode s = ConceptNode s Nothing

    link :: Atom a -> Atom b -> Atom c
    link s1 s2 = Link s1 s2 Nothing

    (.<) :: Atom a -> Double -> Atom a
    (.<) (ConceptNode s _) i = ConceptNode s (Just i)
    (.<) (Link s1 s2 _) i = Link s1 s2 (Just i)

    infixl 5 .<

    main = let nod = (link
                        (conceptNode "Joan")
                        (conceptNode "Juan" .<2)
                        .<4
                     )
            in do
                 case nod of
                   ConceptNode _ _ -> putStrLn "We have a ConceptNode"
                   Link _ _ _      -> putStrLn "We have a Link"
    --------------------------------------------------------------------------
```
 So, we avoid to specify the TruthValue when not necessary. But we have to
 deal with Types constructors on pattern matching, so we are using 2
 differents notations.

  - Other approach, is to use Template Haskell to wrap the Data Constructors
 with an Atom Notation similar to the one described above. We could write
 for example:
```haskell
       ... [atom| AndLink
                       ConceptNode "something"
                       ConceptNode "other thing"
                       <0.5,0.5>
           |]
```
 This would be converted to the internal representation:
```haskell
     AndLink (ConceptNode "something") (ConceptNode "other thing") (Just (0.5,0.5))
```
 But when doing pattern matching, we have to use the Data constructors, such as:
```haskell
       ... case node of
             AndLink a1 a2 tv -> do something
             ConceptNode name -> do something
             ...
```
 So, we should use code as similar as possible between Data Constructors and
 template haskell, to make it simple.
```haskell
    ---------------------------------------------------------------------------
    program :: AtomSpace ()
    program = do
                  liftIO $ putStrLn "Let's add some new nodes:"
                  insert [atom| EvaluationLink <0.9>
                                    PredicateNode "is"
                                    Concept "John"
                                    Concept "John" |]
                  s <- get [atom| EvaluationLink
                                    PredicateNode "is"
                                    Concept "John"
                                    Concept "John" |]
                  case s of
                    PredicateNode "is" _ _ -> liftIO $ putStrLn "It's Predicate Node"
                    Concept "John" _ _     -> liftIO $ putStrLn "It's Concept Node"
                    _                      -> liftIO $ putStrLn "It's other type"
    ---------------------------------------------------------------------------
```
Anyway, I think we can start with the Data Constructors and once everything is
working fine, we can add support for Template Haskell to use the original Atom
Notation embedded  in Haskell.


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
