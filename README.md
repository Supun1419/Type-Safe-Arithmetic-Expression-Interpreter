# EC8206 Functional Programming Project

This folder contains the complete arithmetic-expression interpreter and its
written report.

## Files

- `Expr.hs` — expression data type, safe evaluator, simplifier, and batch functions.
- `Main.hs` — seven repeatable demonstrations with expected/actual results.
- `EC8206_Project_Report.docx` — submission-ready report (after replacing the student placeholders).
- `EC8206_Project_Report.pdf` — PDF copy of the same report.
- `report.html` — editable source used to generate the report.
- `build_report.ps1` — regenerates DOCX and PDF from `report.html` using Microsoft Word.
- `performance/` — optional Haskell-versus-Java performance benchmark; it is
  separate from the assignment's required deliverables.

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

## Before submitting

Replace `[Your Name]` and `[Your Registration Number]` in the report. Review
the code and report so that you can explain every design choice. Keep or amend
the assistance disclosure according to the university's academic-integrity
policy.
