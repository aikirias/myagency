# research

General-purpose investigation plugin — usable in ANY project, with or without the DE
toolkit. Provides the `investigate` skill: a standard for how research is conducted
(context-bound alternatives, source hierarchy, annotated references, explicit decisions)
and a record system that tracks whether each investigation led to implementation.

## What it produces in each project

```
research/
├── INDEX.md                      # state of all recorded decisions, one line each
├── RES-001-<slug>.md             # one record per investigation (TL;DR at top)
└── RES-002-<slug>.md
```

Lifecycle per record: `in-progress → concluded → implemented | not-implemented |
superseded` — closing the loop (status + implementation link) is part of the
definition of done of the work that implements it.

## Install

```bash
/plugin install research@myagency --scope project
```

Standalone by design: no dependency on de-core. When de-core IS present (data projects),
the skill picks up its practices as investigation constraints automatically (that is what
the "context and constraints" phase reads).
