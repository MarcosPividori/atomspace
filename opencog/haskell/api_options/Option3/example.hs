{-# LANGUAGE GADTs #-}

import Api
import Types

someTv :: Maybe TV
someTv = Just $ SimpleTV 0.4 0.5

n = ConceptNode "Animal" someTv
l = ListLink [toAtom n]

ex = ExecutionLink
   (GroundedSchemaNode "some-fun")
   (ListLink [ toAtom $ ConceptNode "Arg1" someTv
             , toAtom $ ConceptNode "Arg2" someTv
             ])
   (ConceptNode "res" someTv)

exx = ExecutionLink
   (SchemaNode "some-fun")
   (ListLink [ toAtom $ ConceptNode "Arg1" someTv
             , toAtom $ ConceptNode "Arg2" someTv
             ])
   (ConceptNode "res" someTv)

{- This won't type
exxx = ExecutionLink
   (PredicateNode "some-fun")
   (ListLink [ toAtom $ ConceptNode "Arg1" someTv
             , toAtom $ ConceptNode "Arg2" someTv
             ])
   (ConceptNode "res" someTv)
-}

li = (ListLink [ toAtom $ ConceptNode "Arg1" someTv
               , toAtom $ PredicateNode "Arg2"
               , toAtom ex
               ])

main :: IO ()
main = do
         insert ex
         case li of
           ListLink (x:y:xs) -> case x of
               GenConcept c   -> print "We have a concept"
               GenPredicate p -> print "We have a predicate"
               _              -> undefined
         case ex of
           ExecutionLink x _ _ -> case toAtom x of
               GenGroundedSchema _ -> print "We have a GSchema"
               GenSchema         _ -> print "We have a Schema"
         return ()

