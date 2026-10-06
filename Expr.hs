module Expr
  ( Expr (..)
  , Env
  , BatchSummary (..)
  , eval
  , simplify
  , evalBatch
  , batchSummary
  ) where

-- | An arithmetic expression.  'Let' introduces a locally scoped variable:
--   Let name boundExpression bodyExpression.
data Expr
  = Lit Double
  | Var String
  | Add Expr Expr
  | Sub Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  | Let String Expr Expr
  deriving (Eq, Show)

-- | Earlier pairs shadow later pairs with the same variable name.
type Env = [(String, Double)]

-- | Counts the outcomes from evaluating a list of expressions.
data BatchSummary = BatchSummary
  { succeeded :: Int
  , failed :: Int
  }
  deriving (Eq, Show)

-- | Evaluate an expression without throwing runtime exceptions.
--   Failures are values in the 'Left' branch of 'Either'.
eval :: Env -> Expr -> Either String Double
eval _   (Lit value) = Right value
eval env (Var name) = lookupVariable name env
eval env (Add left right) = do
  leftValue <- eval env left
  rightValue <- eval env right
  Right (leftValue + rightValue)
eval env (Sub left right) = do
  leftValue <- eval env left
  rightValue <- eval env right
  Right (leftValue - rightValue)
eval env (Mul left right) = do
  leftValue <- eval env left
  rightValue <- eval env right
  Right (leftValue * rightValue)
eval env (Div numerator denominator) = do
  numeratorValue <- eval env numerator
  denominatorValue <- eval env denominator
  if denominatorValue == 0
    then Left "division by zero"
    else Right (numeratorValue / denominatorValue)
eval env (Let name boundExpression bodyExpression) = do
  boundValue <- eval env boundExpression
  eval ((name, boundValue) : env) bodyExpression

lookupVariable :: String -> Env -> Either String Double
lookupVariable name [] = Left ("undefined variable: " ++ name)
lookupVariable name ((candidate, value) : rest)
  | name == candidate = Right value
  | otherwise = lookupVariable name rest

-- | Recursively simplify an expression.  Division by zero is deliberately
--   retained so that 'eval' can report the error rather than hide it.
simplify :: Expr -> Expr
simplify (Lit value) = Lit value
simplify (Var name) = Var name
simplify (Add left right) = simplifyAdd (simplify left) (simplify right)
simplify (Sub left right) = simplifySub (simplify left) (simplify right)
simplify (Mul left right) = simplifyMul (simplify left) (simplify right)
simplify (Div left right) = simplifyDiv (simplify left) (simplify right)
simplify (Let name boundExpression bodyExpression) =
  Let name (simplify boundExpression) (simplify bodyExpression)

simplifyAdd :: Expr -> Expr -> Expr
simplifyAdd expression (Lit 0) = expression
simplifyAdd (Lit 0) expression = expression
simplifyAdd (Lit left) (Lit right) = Lit (left + right)
simplifyAdd left right = Add left right

simplifySub :: Expr -> Expr -> Expr
simplifySub expression (Lit 0) = expression
simplifySub (Lit left) (Lit right) = Lit (left - right)
simplifySub left right = Sub left right

simplifyMul :: Expr -> Expr -> Expr
simplifyMul _ (Lit 0) = Lit 0
simplifyMul (Lit 0) _ = Lit 0
simplifyMul expression (Lit 1) = expression
simplifyMul (Lit 1) expression = expression
simplifyMul (Lit left) (Lit right) = Lit (left * right)
simplifyMul left right = Mul left right

simplifyDiv :: Expr -> Expr -> Expr
simplifyDiv expression (Lit 1) = expression
simplifyDiv (Lit left) (Lit right)
  | right /= 0 = Lit (left / right)
simplifyDiv left right = Div left right

-- | Evaluate every expression and retain only successful results.
--   The section (eval env) is partial application: the environment is fixed
--   now and each expression is supplied later by 'map'.
evalBatch :: Env -> [Expr] -> [Double]
evalBatch env expressions = foldr keepRight [] (map (eval env) expressions)
  where
    keepRight (Right value) values = value : values
    keepRight (Left _) values = values

-- | Report how many expressions in a batch succeeded and failed.
batchSummary :: Env -> [Expr] -> BatchSummary
batchSummary env = foldr countOutcome (BatchSummary 0 0) . map (eval env)
  where
    countOutcome (Right _) (BatchSummary ok bad) = BatchSummary (ok + 1) bad
    countOutcome (Left _) (BatchSummary ok bad) = BatchSummary ok (bad + 1)
