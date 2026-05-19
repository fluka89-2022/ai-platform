# Workflow: Benchmark

## Purpose

Measure the performance of a function or critical path, establish a baseline, verify the impact of a change, and document the results.

## When to use it

- Before a performance-oriented refactoring (establishes the baseline).
- After a refactoring (verifies the improvement).
- When a Go audit flags a HIGH or CRITICAL finding on performance or allocation.
- When comparing two alternative implementations.

## Prerequisites

- The Go module to measure is accessible in the workspace.
- The function or path to measure is known (or derived from the audit).

## Process

### 1. Identify the target

Ask the user (or derive from the audit):

- Which function or path should be measured?
- Is there an existing baseline (existing benchmark or pprof profile)?
- What is the realistic execution context (input size, concurrency)?

### 2. Explore the existing code

Invoke the `codebase-analysis` skill.
Look for existing benchmarks (`Benchmark` in the name, `_test.go` files).
Read the code for the path being measured to understand realistic parameters.

### 3. Write the benchmarks

Before touching production code, write the benchmark functions:

```go
func BenchmarkFunctionName(b *testing.B) {
    // Setup outside the loop
    input := prepareInput()

    b.ResetTimer()
    for b.Loop() {  // Go 1.24+; use b.N for earlier versions
        result = FunctionName(input)
    }
    _ = result // prevent compiler elimination
}
```

For benchmarks with input variants use `b.Run`:

```go
func BenchmarkFunctionName(b *testing.B) {
    cases := []struct{ name string; size int }{
        {"small", 10},
        {"medium", 100},
        {"large", 1000},
    }
    for _, tc := range cases {
        b.Run(tc.name, func(b *testing.B) {
            input := prepareInput(tc.size)
            b.ResetTimer()
            for b.Loop() {
                FunctionName(input)
            }
        })
    }
}
```

Confirm with the user before proceeding to measurement.

### 4. Establish the baseline

```bash
# From the Go module directory
go test -bench=BenchmarkFunctionName -benchmem -count=5 ./path/to/package/... \
  | tee benchmark-baseline.txt
```

The `-benchmem` flag reports allocations per operation — essential for evaluating GC pressure.
`-count=5` reduces statistical variance.

Show the results to the user before proceeding with changes.

### 5. Apply the change (if requested)

If the benchmark is pre-change, proceed with the refactoring.
If the benchmark is post-change, compare with the baseline.

For statistical comparison use `benchstat`:

```bash
go install golang.org/x/perf/cmd/benchstat@latest
benchstat benchmark-baseline.txt benchmark-after.txt
```

`benchstat` indicates whether the delta is statistically significant.

### 6. Generate profiles (if findings are HIGH or CRITICAL)

```bash
go test -bench=BenchmarkFunctionName -benchtime=30s \
  -cpuprofile=cpu.pprof -memprofile=mem.pprof \
  ./path/to/package/...
```

The `.pprof` files can be attached to an `/audit` session for runtime analysis.

### 7. Document the results

Save a report to `docs/benchmark/<name>-<YYYY-MM-DD>.md` with:

- Context: which function, which scenario, Go version.
- Baseline: formatted `go test -bench` output.
- Post-change result (if applicable): output + delta from `benchstat`.
- Interpretation: what the numbers mean, where headroom remains.
- Next steps: other benchmarks to run, profiles to generate.

Invoke the `doc-standard` skill and apply it for style and language.

### 8. Stop and report

> "Benchmark complete. Baseline: [N ns/op, N allocs/op]. [If post-change: X% improvement on CPU, Y% on allocations — statistically significant per benchstat.]
> Report in `docs/benchmark/<name>-<date>.md`."

## Output

→ `benchmark-baseline.txt` (or equivalent file) in the module directory.
→ `docs/benchmark/<name>-<YYYY-MM-DD>.md` with documented results.
