{-# LANGUAGE GADTs #-}

import Api
import Types

someTv :: Maybe TV
someTv = Just $ SimpleTV 0.4 0.5

n = ConceptNode "Animal" someTv
l = ListLink [AtomGen n]

ex = ExecutionLink
   (GroundedSchemaNode "some-fun")
   (ListLink [ AtomGen $ ConceptNode "Arg1" someTv
             , AtomGen $ ConceptNode "Arg2" someTv
             ])
   (ConceptNode "res" someTv)

exx = ExecutionLink
   (SchemaNode "some-fun")
   (ListLink [ AtomGen $ ConceptNode "Arg1" someTv
             , AtomGen $ ConceptNode "Arg2" someTv
             ])
   (ConceptNode "res" someTv)

{- This won't type
exx = ExecutionLink
   (PredicateNode "some-fun")
   (ListLink [ AtomGen $ ConceptNode "Arg1" someTv
             , AtomGen $ ConceptNode "Arg2" someTv
             ])
   (ConceptNode "res" someTv)
-}

li = (ListLink [ AtomGen $ ConceptNode "Arg1" someTv
               , AtomGen $ PredicateNode "Arg2"
               , AtomGen ex
               ])

main :: IO ()
main = do
         insert ex
         () <- case li of
           ListLink (x:y:xs) -> case x of
               AtomGen (ConceptNode c tv) -> print "We have a concept"
               AtomGen (PredicateNode p ) -> print "We have a predicate"
               _                          -> undefined
         () <- case ex of
           ExecutionLink x _ _ -> case x of
               GroundedSchemaNode _ -> print "We have a GSchema"
               SchemaNode         _ -> print "We have a Schema"
         return ()

