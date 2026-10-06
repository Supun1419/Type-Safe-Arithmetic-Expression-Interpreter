{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Exception (evaluate)
import Expr
import GHC.Clock (getMonotonicTimeNSec)
import System.Environment (getArgs)
import Text.Printf (printf)

defaultIterations :: Int
defaultIterations = 5000000

main :: IO ()
main = do
  arguments <- getArgs
  let iterations = parseIterations arguments
      warmupIterations = min 250000 (max 1 (iterations `div` 10))

  -- Force a smaller run before measuring so code and data are resident.
  _ <- evaluate (runEvaluations warmupIterations)

  start <- getMonotonicTimeNSec
  checksum <- evaluate (runEvaluations iterations)
  end <- getMonotonicTimeNSec

  let elapsedSeconds = fromIntegral (end - start) / 1000000000 :: Double
      evaluationsPerSecond = fromIntegral iterations / elapsedSeconds

  putStrLn "Implementation: Haskell Expr.eval"
  printf "Iterations: %d\n" iterations
  printf "Checksum: %.6f\n" checksum
  printf "Elapsed seconds: %.6f\n" elapsedSeconds
  printf "Evaluations/second: %.0f\n" evaluationsPerSecond
  printf "TIME_SECONDS=%.9f\n" elapsedSeconds
  printf "CHECKSUM=%.6f\n" checksum

parseIterations :: [String] -> Int
parseIterations [] = defaultIterations
parseIterations (value : _) =
  case reads value of
    [(number, "")] | number > 0 -> number
    _ -> defaultIterations

-- The input environment changes on every iteration. This prevents the
-- compiler from replacing the complete benchmark with one constant result.
runEvaluations :: Int -> Double
runEvaluations count = go count 0
  where
    go :: Int -> Double -> Double
    go 0 !checksum = checksum
    go remaining !checksum =
      let x = fromIntegral (remaining `rem` 97)
          y = fromIntegral (remaining `rem` 53)
          environment = [("x", x), ("y", y)]
       in case eval environment workload of
            Right value -> go (remaining - 1) (checksum + value)
            Left message -> error message

workload :: Expr
workload =
  Div
    (Add
      (Mul (Var "x") (Lit 3.5))
      (Sub (Var "y") (Lit 2)))
    (Lit 2)
