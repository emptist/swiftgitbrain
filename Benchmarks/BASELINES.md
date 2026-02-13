# GitBrainSwift Performance Baselines

This document contains the performance baselines for GitBrainSwift components.

## KnowledgeBase

| Operation | Baseline | Goal | Status |
|-----------|----------|------|--------|
| AddKnowledge | 0.316 ms | < 1 ms | ✅ Pass |
| GetKnowledge | 0.006 ms | < 0.1 ms | ✅ Pass |
| SearchKnowledge | 47.869 ms | < 10 ms | ❌ Fail |
| DeleteKnowledge | 0.148 ms | < 1 ms | ✅ Pass |

## MemoryStore

| Operation | Baseline | Goal | Status |
|-----------|----------|------|--------|
| Set | 0.002 ms | < 0.5 ms | ✅ Pass |
| Get | 0.001 ms | < 0.05 ms | ✅ Pass |
| Delete | 0.001 ms | < 0.5 ms | ✅ Pass |
| Clear | 0.002 ms | < 10 ms | ✅ Pass |

## MessageValidator

| Operation | Baseline | Goal | Status |
|-----------|----------|------|--------|
| Validate | 0.009 ms | < 1 ms | ✅ Pass |

## Notes

- SearchKnowledge operation is slower than the goal and needs optimization
- All other operations meet or exceed performance goals
- Baselines were measured on 1000 iterations (except SearchKnowledge which was measured on 1000 items)
- Results may vary based on hardware and system load

## Running Benchmarks

To run the benchmarks:

```bash
swift run GitBrainSwiftBenchmarks
```

## Updating Baselines

When updating baselines:
1. Run benchmarks multiple times to get consistent results
2. Calculate average and standard deviation
3. Update this document with new baselines
4. Document any significant changes
5. Investigate performance regressions

## Performance Regression Detection

A performance regression is detected when:
- An operation is 20% slower than the baseline
- An operation fails to meet its performance goal
- Multiple operations show degradation

When a regression is detected:
1. Investigate the cause
2. Fix the issue
3. Update baselines if the change is intentional
