
import Api
import Types

someTv :: Maybe TruthVal
someTv = Just $ SimpleTruthVal 0.4 0.5

n = Node Concept "Animal" someTv
l = Link List [n] Nothing

e = Link Evaluation
         [ Node Predicate "isFriend" Nothing
         , Link List
                [ Node Concept "Alan" someTv
                , Node Concept "Robert" someTv
                ]
                Nothing
         ]
         someTv

ex = Link Execution
          [ Node Schema "some-fun" Nothing
          , Link List
                 [ Node Concept "Arg1" someTv
                 , Node Concept "Arg2" someTv
                 ]
                 Nothing
          , Node Concept "res" someTv
          ]
          Nothing

li = Link List
          [ Node Concept "Arg1" someTv
          , Node Predicate "Arg2" Nothing
          ]
          Nothing

main :: IO ()
main = do
         p <- get $ Node Predicate "Pred" Nothing
         case p of
            Nothing                   -> print "nothing"
            Just (Node Predicate _ _) -> print "predicate"
         insert ex
         get ex
         remove e
         case li of
           Link List (x:y:xs) _ -> case x of
                              Node Concept c tv  -> undefined
                              Node Predicate p _ -> undefined
                              _                  -> undefined
         return ()

