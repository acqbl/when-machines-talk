# CLAUDE.md

## Tone & Writing Style

When writing narrative content (preface, chapter introductions, LinkedIn posts):
- **Dry British humour** — understated, slightly self-deprecating, deadpan
- Short punchy sentences. No purple prose.
- Accessible to non-technical readers without dumbing down
- Concrete over abstract — always ground concepts in the factory/machine reality

## R Coding Style

- **Tidyverse** style throughout — pipe operator `|>`, no `$` chaining
- Compact and concise — no redundant intermediate variables
- No comments stating the obvious; comment only non-evident logic
- Functions go in `scripts/functions/` — written to be generic (any machine log)
- Standard input contract for all functions:
  - Tidy interval log with: `equipment_ID`, `type`, `alarm`, `start`, `end`, `elapsed_s`
  - `type` values: `"production"`, `"performance_loss"`, `"downtime"`, `"idle"`, `"scheduled_downtime"`
  - Durations always in seconds (`elapsed_s`)

## Project Structure

```
/
├── book/          # Quarto Book (public — versioned)
├── data/
│   ├── raw/       # raw_data.csv (gitignored)
│   └── clean/     # clean_data.rds (gitignored)
├── scripts/
│   ├── 01_etl.R
│   └── functions/ # future package functions (oee.R, downtime.R, sequences.R…)
├── analyses/      # targeted analyses (gitignored)
├── sandbox/       # exploratory scratch work (gitignored)
└── pkg/           # future R package scaffold (machinelogr)
```

## Package Vision

All functions in `scripts/functions/` are written to be **machine-log-agnostic**:
- Generic column contract (not hardcoded to this dataset)
- No assumptions on alarm codes or equipment names
- Designed to be dropped into `pkg/R/` when the package episode is written
- Package name candidate: **machinelogr**
