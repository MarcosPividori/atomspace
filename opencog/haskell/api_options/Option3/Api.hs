module Api (
      insert
    , remove
    , get
    , AtomSpace
    ) where

import Types

type AtomType = String
type AtomSpace = IO

data AtomRaw = Node AtomType AtomName  (Maybe TruthVal)
             | Link AtomType [AtomRaw] (Maybe TruthVal)
    deriving Show

toAtomRaw :: AtomGen -> AtomRaw
toAtomRaw at = case at of
    AtomConcept    (Concept n tv      ) -> Node "ConceptNode" n tv
    AtomPredicate  (Predicate n       ) -> Node "PredicateNode" n Nothing
    AtomSchema     (Schema n          ) -> Node "SchemaNode" n Nothing
    AtomList       (List l            ) -> Link "ListLink" (map toAtomRaw l) Nothing
    AtomEvaluation (Evaluation tv p l ) -> Link "EvaluationLink"
                                           (map toAtomRaw [toAtom p,toAtom l]) tv
    AtomExecution  (Execution s l a   ) -> Link "ExecutionLink"
                                           (map toAtomRaw [toAtom s,toAtom l,a]) Nothing

fromAtomRaw :: AtomRaw -> Maybe AtomGen
fromAtomRaw (Node atype aname tv)
    | atype == "ConceptNode"   = Just $ toAtom $ Concept aname tv
    | atype == "PredicateNode" = Just $ toAtom $ Predicate aname
    | atype == "SchemaNode"    = Just $ toAtom $ Schema aname
    | otherwise                = Nothing
fromAtomRaw (Link "ListLink" l _) = do
    list <- mapM fromAtomRaw l
    Just $ toAtom $ List list
fromAtomRaw (Link "EvaluationLink" (p:l:[]) tv) = do
    p1 <- fromAtomRaw p >>= fromAtom
    l1 <- fromAtomRaw l >>= fromAtom
    Just $ toAtom $ Evaluation tv p1 l1
fromAtomRaw (Link "ExecutionLink" (s:l:a:[]) _) = do
    s1 <- fromAtomRaw s >>= fromAtom
    l1 <- fromAtomRaw l >>= fromAtom
    a1 <- fromAtomRaw a
    Just $ toAtom $ Execution s1 l1 a1
fromAtomRaw _ = Nothing

insert :: IsAtom a => a -> AtomSpace ()
insert i = do
    putStrLn $ "call insert: " ++ (show $ toAtom i)
    case toAtomRaw $ toAtom i of
        Node atype aname atv     -> return ()
        --undefined foreign call to addNode.
        Link atype aoutgoing atv -> return ()
        --undefined foreign call to addLink.

remove :: IsAtom a => a -> AtomSpace ()
remove i = do
    putStrLn $ "call remove: " ++ (show $ toAtomRaw $ toAtom i)
    --undefined foreign call to removeAtom.

get :: IsAtom a => a -> AtomSpace (Maybe a)
get i = do
    res <- get_gen $ toAtomRaw $ toAtom i
    return $ res >>= fromAtomRaw >>= fromAtom

get_gen :: AtomRaw -> AtomSpace (Maybe AtomRaw)
get_gen at = do 
    putStrLn $ "call get: " ++ show at
    case at of
        Node atype aname atv     -> return Nothing
        -- undefined foreign call to getNode.
        Link atype aoutgoing atv -> return Nothing
        --undefined foreign call to getLink.

