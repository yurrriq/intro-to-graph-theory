#! /usr/bin/env nix-shell
#! nix-shell --pure -i runghc -p "(haskellPackages.ghcWithPackages (hpkgs: with hpkgs; [ algebraic-graphs ]))"

module Main where


import           Algebra.Graph.AdjacencyIntMap (AdjacencyIntMap,
                                                adjacencyIntMap, edges, overlay,
                                                stars, vertices)
import           Control.Arrow                 (first, (***))
import           Control.Monad                 (join, unless)
import           Data.Function                 (on)
import qualified Data.IntMap.Strict            as IntMap
import qualified Data.IntSet                   as IntSet
import           Data.List                     (permutations, sort)
import           Data.Maybe                    (mapMaybe)
import           GHC.Exts                      (sortWith)


main :: IO ()
main =
    do putStrLn "The graph G" <* print graphG
       putStrLn "has the canonization" <* print (canonization graphG)
       putStr "which is "
       unless (isIsomorphic graphG graphH) (putStr "not ")
       putStrLn "isomorphic to the canonization" <* print (canonization graphH)
       putStrLn "of the graph H" <* print graphH



isIsomorphic :: AdjacencyIntMap -> AdjacencyIntMap -> Bool
isIsomorphic = (==) `on` (snd . canonization)


-- NOTE: Based on https://wiki.haskell.org/99_questions/Solutions/85
-- FIXME: Use State or similar to clean this up.
canonization :: AdjacencyIntMap -> ([(Int, Int)], AdjacencyIntMap)
canonization g = map fst *** stars . map (first snd) $
                 join (,) $
                 foldr1 minimum' $
                 go <$> permutations [0..IntMap.size adjacencies-1]
   where
     minimum' a b | ((<) `on` map (first snd)) a b = a
                  | otherwise                        = b

     adjacencies = adjacencyIntMap g

     go perms = mapMaybe relabelVertex (sortWith snd relabelledVertexList)
       where
         relabelledVertexList :: [(Int, Int)]
         relabelledVertexList = zip (IntMap.keys adjacencies) perms

         relabelledAdjacencies = IntMap.fromList relabelledVertexList

         relabelVertex (vertex, relabelledVertex) =
           (,) <$> pure (vertex, relabelledVertex) <*>
           (sort . mapMaybe (`IntMap.lookup` relabelledAdjacencies) .
            IntSet.toList <$> IntMap.lookup vertex adjacencies)


graphG :: AdjacencyIntMap
graphG =
    stars [ (0, [1,2,5,6])
          , (1, [0,2,3,6])
          , (2, [0,1,3,4])
          , (3, [1,2,4,5])
          , (4, [2,3,5,6])
          , (5, [0,3,4,6])
          , (6, [0,1,4,5])
          ]


graphH :: AdjacencyIntMap
graphH =
    stars [ (0, [1,3,4,6])
          , (1, [0,2,4,5])
          , (2, [1,3,5,6])
          , (3, [0,2,4,6])
          , (4, [0,1,3,5])
          , (5, [1,2,4,6])
          , (6, [0,2,3,5])
          ]


graphG1 :: AdjacencyIntMap
graphG1 = vertices [1..8] `overlay`
          edges [(1, 5), (1, 6), (1, 7), (2, 5), (2, 6), (2, 8),
                  (3, 5), (3, 7), (3, 8), (4, 6), (4, 7), (4, 8)]


graphH1 :: AdjacencyIntMap
graphH1 = vertices [1..8] `overlay`
          edges [(1, 2), (1, 4), (1, 5), (6, 2), (6, 5), (6, 7),
                  (8, 4), (8, 5), (8, 7), (3, 2), (3, 4), (3, 7)]
