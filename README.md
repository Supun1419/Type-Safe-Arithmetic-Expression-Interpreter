# EC8206 Functional Programming Project


## Files

- `Expr.hs` — expression data type, safe evaluator, simplifier, and batch functions.
- `Main.hs` — seven repeatable demonstrations with expected/actual results.
- `performance/` — optional Haskell-versus-Java performance benchmark; it is
  separate from the assignment's required deliverables.

Coursework reports, generated documents, and submission archives are kept
locally and excluded from this source repository through `.gitignore`.

## Run

Install GHC, open a terminal in this folder, and run:

```text
runghc Main.hs
```

To compile an executable instead:

```text
ghc -Wall Main.hs -o expression-interpreter
./expression-interpreter
```

The program prints seven `PASS`/`FAIL` checks, a simplification example, the
successful batch values, and a success/failure summary.

## Optional performance comparison

With GHC and Java installed:

```text
cd performance
.\run_benchmark.ps1
```

See `performance/README.md` for methodology and interpretation limits.


