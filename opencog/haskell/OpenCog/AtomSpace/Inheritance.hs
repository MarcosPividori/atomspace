-- GSoC 2015 - Haskell bindings for OpenCog.
{-# LANGUAGE EmptyDataDecls       #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE DeriveDataTypeable   #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE KindSignatures       #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeOperators        #-}
{-# LANGUAGE ConstraintKinds      #-}
{-# LANGUAGE UndecidableInstances #-}

-- | This Module defines the relation between different atom types.
module OpenCog.AtomSpace.Inheritance (
  type (<~)
, type (<<~)
, Children
) where

import GHC.Exts                     (Constraint)
import OpenCog.AtomSpace.AtomType   (AtomType(..),Down(..))
import Data.Typeable                (Typeable)

-- | 'FDown' type level function to get the list of all descendants
-- of a given atom type.
type family FDown a b :: [AtomType] where
    FDown (x ': xs) a         = x ': FDown xs (x ': a)
    FDown '[]       (x ': xs) = FDown (Down x) xs
    FDown '[]       '[]       = '[]

type Children a = FDown '[a] '[]

type AllAtomTypes = Children AtomT

type family (-) (a::[AtomType]) (b::AtomType) where
    (x ': xs) - x = xs - x
    (x ': xs) - y = x ': (xs - y)
    '[]       - y = '[]

type family (\\) (a::[AtomType]) (b::[AtomType]) where
    l \\ (x ': xs) = (l - x) \\ xs
    l \\ '[]       = l

type family (==) (a::AtomType) (b::AtomType) :: Bool where
    a == a = 'True
    a == x = 'False

type family NotIn (a::AtomType) (b::[AtomType]) :: Constraint where
    NotIn a '[]       = 'True ~ 'True
    NotIn a (x ': xs) = ((a == x) ~ 'False,NotIn a xs)

type family ConcatT l :: [AtomType] where
    ConcatT ((x ': xs) ': ys) = x ': ConcatT (xs ': ys)
    ConcatT ('[]       ': ys) = ConcatT ys
    ConcatT  '[]              = '[]

type family MapChildren (l::[AtomType]) where
    MapChildren (x ': xs) = Children x ': MapChildren xs
    MapChildren '[]       = '[]

-- | '<~' builds a list of constraints to assert that a is not outside the
-- subtree of successors of b.
infix 9 <~
type a <~ b = a <<~ '[b]

-- | '<~' builds a list of constraints to assert that a is not outside the
-- subtree of successors of each atom type in the list b.
infix 9 <<~
type a <<~ b = (Typeable a,NotIn a (AllAtomTypes \\ (ConcatT (MapChildren b))))

