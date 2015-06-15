module Api (
      insert
    , remove
    , get
    , AtomSpace
    ) where

import Types

type AtomSpace = IO

insert :: Atom -> AtomSpace ()
insert i = do
    putStrLn $ "call insert: " ++ (show i)
    case i of
             Link t o tv -> return ()
             -- undefined foreign call to addLink.
             Node t n tv -> return ()
             -- undefined foreign call to addNode.

remove :: Atom -> AtomSpace ()
remove i = do
    putStrLn $ "call remove: " ++ (show i)
    --undefined foreign call to removeAtom.

get :: Atom -> AtomSpace (Maybe Atom)
get at = do 
    putStrLn $ "call get: " ++ show at
    case at of
        Node atype aname atv     -> return Nothing
        -- undefined foreign call to getNode.
        Link atype aoutgoing atv -> return Nothing
        -- undefined foreign call to getLink.

