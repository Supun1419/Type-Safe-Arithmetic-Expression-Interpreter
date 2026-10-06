# Optional performance comparison

This directory is separate from the assessed interpreter. The assignment does
not require a performance comparison.

The benchmark compares:

- the existing Haskell `Expr.eval` implementation;
- an equivalent imperative Java evaluator using a `switch`, mutable `HashMap`,
  and exceptions.

Both programs evaluate the same expression with the same changing values. A
matching checksum confirms that they calculated the same results. Each program
uses a monotonic wall clock and performs a warm-up before measurement.

## Run

From PowerShell:

```powershell
cd "D:\Functional_Programming\EC8206_Project\performance"
.\run_benchmark.ps1
```

To choose a different number of evaluations:

```powershell
.\run_benchmark.ps1 -Iterations 10000000
```

## Interpretation limits

This is a practical comparison of these two implementations, not proof that
one programming paradigm is universally faster. Results include differences
between GHC native compilation and the Java JIT, garbage collectors, startup
and warm-up behavior, and environment representations (Haskell association
list versus Java `HashMap`). Run several trials on an otherwise idle computer
and report a median or range together with the machine and compiler versions.
