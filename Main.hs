module Main where

import Expr
import Text.Printf (printf)

main :: IO ()
main = do
  putStrLn "EC8206 arithmetic expression interpreter"
  putStrLn "========================================"
  mapM_ runCase sampleCases

  let expressionToSimplify = Mul (Add (Var "x") (Lit 0)) (Lit 1)
  putStrLn "\nSimplification"
  putStrLn ("Before: " ++ show expressionToSimplify)
  putStrLn ("After:  " ++ show (simplify expressionToSimplify))

  let expressions = map caseExpression sampleCases
  putStrLn "\nBatch processing"
  putStrLn ("Successful values: " ++ show (evalBatch sharedEnv expressions))
  putStrLn ("Summary: " ++ show (batchSummary sharedEnv expressions))

data SampleCase = SampleCase
  { caseLabel :: String
  , caseEnvironment :: Env
  , caseExpression :: Expr
  , caseExpected :: Either String Double
  }

runCase :: SampleCase -> IO ()
runCase sample = do
  let actual = eval (caseEnvironment sample) (caseExpression sample)
      verdict = if actual == caseExpected sample then "PASS" else "FAIL"
  printf "\n%-24s %s\n" (caseLabel sample) verdict
  putStrLn ("  Expression: " ++ show (caseExpression sample))
  putStrLn ("  Expected:   " ++ show (caseExpected sample))
  putStrLn ("  Actual:     " ++ show actual)

sharedEnv :: Env
sharedEnv = [("x", 10), ("y", 4)]

sampleCases :: [SampleCase]
sampleCases =
  [ SampleCase
      "literal addition"
      sharedEnv
      (Add (Lit 2) (Lit 3))
      (Right 5)
  , SampleCase
      "variables and multiply"
      sharedEnv
      (Mul (Var "x") (Var "y"))
      (Right 40)
  , SampleCase
      "nested arithmetic"
      sharedEnv
      (Sub (Mul (Var "x") (Lit 3)) (Var "y"))
      (Right 26)
  , SampleCase
      "division"
      sharedEnv
      (Div (Lit 20) (Var "y"))
      (Right 5)
  , SampleCase
      "let binding"
      sharedEnv
      (Let "x" (Lit 7) (Add (Var "x") (Lit 1)))
      (Right 8)
  , SampleCase
      "division by zero"
      sharedEnv
      (Div (Lit 8) (Sub (Var "y") (Lit 4)))
      (Left "division by zero")
  , SampleCase
      "undefined variable"
      sharedEnv
      (Add (Var "missing") (Lit 1))
      (Left "undefined variable: missing")
  ]
