{-# LANGUAGE FlexibleInstances, UndecidableInstances, ScopedTypeVariables #-}

module Api (
      insert
    , remove
    , get
    , AtomSpace
    , Atom
    , IsAtom(..)
    , IsAtomType(..)
    , Inst(..)
    , AtomName
    , TruthVal(..)
    ) where

type AtomName = String
type AtomType = String
type AtomSpace = IO

data TruthVal = SimpleTruthVal Double Double
              | CountTruthVal Double Double Double
              | IndefiniteTruthVal Double Double Double Double
    deriving Show

data Inst a = Node { fromNode :: AtomName -> (Maybe TruthVal) -> Maybe a
                   , toNode   :: a -> (AtomName,Maybe TruthVal)
                   }
            | Link { fromLink :: [Atom] -> (Maybe TruthVal) -> Maybe a
                   , toLink   :: a -> ([Atom],Maybe TruthVal)
                   }

data Atom = ANode AtomType AtomName (Maybe TruthVal)
          | ALink AtomType [Atom]   (Maybe TruthVal)
    deriving Show

class IsAtom a where
    toAtom   :: a -> Atom
    fromAtom :: Atom -> Maybe a

class IsAtomType a where
    atomType :: a -> AtomType
    inst     :: Inst a

instance IsAtomType a => IsAtom a where
    toAtom i = let atype = atomType (undefined::a)
                in case  inst :: Inst a of
        Node _ to -> let (name,tv) = to i
                      in ANode atype name tv
        Link _ to -> let (out,tv) = to i
                      in ALink atype out tv
    fromAtom i = let atype = atomType (undefined::a)
                  in case inst :: Inst a of
        Node from _ -> case i of
            ANode t n tv -> if atype == t
                            then from n tv
                            else Nothing
            _            -> Nothing
        Link from _ -> case i of
            ALink t out tv -> if atype == t
                              then from out tv
                              else Nothing
            _              -> Nothing

insert :: IsAtom a => a -> AtomSpace ()
insert i = do
    putStrLn $ "call insert: " ++ (show $ toAtom i)
    case toAtom i of
             ANode atype aname atv     -> return ()
             --undefined foreign call to addNode.
             ALink atype aoutgoing atv -> return ()
             --undefined foreign call to addLink.

remove :: IsAtom a => a -> AtomSpace ()
remove i = do
    putStrLn $ "call remove: " ++ (show $ toAtom i)
    --undefined foreign call to removeAtom.

get :: IsAtom a => a -> AtomSpace (Maybe a)
get i = do
    res <- get_gen $ toAtom i
    return $ res >>= fromAtom

get_gen :: Atom -> AtomSpace (Maybe Atom)
get_gen at = do 
    putStrLn $ "call get: " ++ show at
    case at of
          ANode atype aname atv     -> return Nothing
            -- undefined foreign call to getNode.
          ALink atype aoutgoing atv -> return Nothing
            --undefined foreign call to getLink.

