{-# LANGUAGE GADTs #-}

module Api (
      insert
    , remove
    , get
    , AtomSpace
    ) where

import Types
import Data.Functor                 ((<$>))

type AtomType = String
type AtomSpace = IO

data AtomRaw = Node AtomType AtomName  (Maybe TruthVal)
             | Link AtomType [AtomRaw] (Maybe TruthVal)
    deriving Show

toAtomRaw :: Atom a -> AtomRaw
toAtomRaw at = case at of
    Concept n tv       -> Node "ConceptNode" n tv
    Predicate n        -> Node "PredicateNode" n Nothing
    Schema n           -> Node "SchemaNode" n Nothing
    List l             -> Link "ListLink" (map (appAtomGen toAtomRaw) l) Nothing
    Evaluation p l tv  -> Link "EvaluationLink"
                           [toAtomRaw p,toAtomRaw l] tv
    Execution s l a    -> Link "ExecutionLink"
                           [toAtomRaw s,toAtomRaw l,toAtomRaw a]
                           Nothing

fromAtomRaw :: AtomRaw -> Atom a -> Maybe (Atom a)
fromAtomRaw raw orig = case (raw,orig) of
    (Node "ConceptNode" n tv   , Concept _ _ ) -> Just $ Concept n tv
    (Node "PredicateNode" n _  , Predicate _ ) -> Just $ Predicate n
    (Node "SchemaNode" n _     , Schema _    ) -> Just $ Schema n
    (Link "ListLink" lraw _    , List lorig  ) -> do
        lnew <- if length lraw == length lorig
                 then sequence $ zipWith (\raw orig -> 
                                    appAtomGen
                                    ((<$>) AtomGen . fromAtomRaw raw) orig)
                                    lraw lorig
                 else Nothing
        Just $ List lnew
    (Link "EvaluationLink" (pr:lr:[]) tv , Evaluation p l _) -> do
        po <- fromAtomRaw pr p
        lo <- fromAtomRaw lr l
        return $ Evaluation po lo tv
    (Link "ExecutionLink" (sr:lr:ar:[]) _ , Execution s l a) -> do
        so <- fromAtomRaw sr s
        lo <- fromAtomRaw lr l
        ao <- fromAtomRaw ar a
        return $ Execution so lo ao
    _                                                        -> Nothing

insert :: Atom a -> AtomSpace ()
insert i = do
    putStrLn $ "call insert: " ++ (show i)
    case toAtomRaw i of
        Node atype aname atv     -> return ()
        --undefined foreign call to addNode.
        Link atype aoutgoing atv -> return ()
        --undefined foreign call to addLink.

remove :: Atom a -> AtomSpace ()
remove i = do
    putStrLn $ "call remove: " ++ (show i)
    --undefined foreign call to removeAtom.

get :: Atom a -> AtomSpace (Maybe (Atom a))
get i = do
    res <- get_gen $ toAtomRaw i
    return $ res >>= (\raw -> fromAtomRaw raw i)

get_gen :: AtomRaw -> AtomSpace (Maybe AtomRaw)
get_gen at = do 
    putStrLn $ "call get: " ++ show at
    case at of
        Node atype aname atv     -> return Nothing
        -- undefined foreign call to getNode.
        Link atype aoutgoing atv -> return Nothing
        --undefined foreign call to getLink.

