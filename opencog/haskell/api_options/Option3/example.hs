
import Api
import Types

someTv :: Maybe TruthVal
someTv = Just $ SimpleTruthVal 0.4 0.5

n = Concept "Animal" someTv
l = List [toAtom n]

e = Evaluation someTv
   (Predicate "isFriend")
   (List [ toAtom $ Concept "Alan" someTv
         , toAtom $ Concept "Robert" someTv
         ])

ex = Execution
   (Schema "some-fun")
   (List [ toAtom $ Concept "Arg1" someTv
         , toAtom $ Concept "Arg2" someTv
         ])
   (toAtom $ Concept "res" someTv)

li = (List [ toAtom $ Concept "Arg1" someTv
           , toAtom $ Predicate "Arg2"
           ])
main :: IO ()
main = do
         p <- get $ Predicate "Pred"
         case p of
            Nothing            -> print "nothing"
            Just (Predicate _) -> print "predicate"
         insert ex
         get ex
         remove e
         case li of
           List (x:y:xs) -> case x of
                              AtomConcept   (Concept c tv) -> undefined
                              AtomPredicate (Predicate p ) -> undefined
                              _                            -> undefined
         return ()

