{-# LANGUAGE GADTs #-}

import Api
import Types

someTv :: Maybe TruthVal
someTv = Just $ SimpleTruthVal 0.4 0.5

n = Concept "Animal" someTv
l = List [AtomGen n]

e = Evaluation
   (Predicate "isFriend")
   (List [ AtomGen $ Concept "Alan" someTv
         , AtomGen $ Concept "Robert" someTv
         ])
   someTv

ex = Execution
   (Schema "some-fun")
   (List [ AtomGen $ Concept "Arg1" someTv
         , AtomGen $ Concept "Arg2" someTv
         ])
   (Concept "res" someTv)

li = (List [ AtomGen $ Concept "Arg1" someTv
           , AtomGen $ Predicate "Arg2"
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
                              AtomGen (Concept c tv) -> undefined
                              AtomGen (Predicate p ) -> undefined
                              _                      -> undefined
         return ()

