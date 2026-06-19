# {{PROJECT_NAME}} — Perf Branch

**This is the performance optimization branch.** You are in profiling mode.

---

## The First Rule

**Measure before optimizing.** Never change code for performance reasons
without a documented baseline. If you cannot show a before/after number,
the optimization does not ship.

---

## Your Role Here

1. Profile the application to identify real bottlenecks — not assumed ones.
2. Record the baseline measurement in `BENCHMARK.md`.
3. Implement one targeted optimization.
4. Measure again and record the delta.
5. Ship only if the improvement is meaningful and the code is not
   significantly harder to maintain.

For profiling tools, measurement methodology, and optimization patterns,
consult `.claude/skills/performance/SKILL.md`.

---

## What to Measure (Frontend)

- **Core Web Vitals**: LCP, INP, CLS
- **Bundle size**: total JS weight, per-route chunk sizes
- **Render behavior**: component render counts, unnecessary re-renders (`React DevTools Profiler`)
- **Network**: waterfall timing, request count, cache hit rates
- **Runtime**: specific operation timings with `performance.mark` / `performance.measure`

---

## Rules

- One optimization per PR. Bundling changes makes it impossible to attribute improvements.
- If an optimization meaningfully degrades readability, document why the trade-off is worth it.
- Every optimization must have a test or check that would catch a regression.
- Do not optimize code that is not on a measured hot path.

---

## BENCHMARK.md Entry Format

```markdown
## YYYY-MM-DD — Metric Name

**Target:** What component or operation is being optimized
**Condition:** How the measurement was taken (device, network, dataset size)
**Baseline:** Measurement before
**After:** Measurement after
**Delta:** Change (e.g., −340ms LCP, −18% bundle size)
**Method:** What was changed to achieve the result
```

---

## Documents in This Branch

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — quick reference |
| `CLAUDE-detailed.md` | Full performance methodology and measurement process |
| `SPEC.md` | Project requirements |
| `BENCHMARK.md` | Performance baselines and optimization results |
| `README.md` | Project documentation |
| `.claude/skills/` | All project skills |

---

## Skills

- `.claude/skills/performance/SKILL.md` — profiling, measurement, optimization patterns
