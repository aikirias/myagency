# .claude/ — Structure Guide

This folder contains all the configuration that defines how Claude Code behaves in this project. Each subfolder has a different role and they are not interchangeable.

---

## The four key concepts

### Agents — *specialists*

```
.claude/agents/
├── business-intake-manager.md
├── data-architect.md
├── data-engineer.md
├── data-analyst.md
├── data-quality-engineer.md
├── incident-analyst.md
└── ...
```

An **agent** is a sub-Claude with a well-defined role, personality, and set of responsibilities. When an agent is invoked, Claude adopts that role and applies its specific judgment.

**When to use them**: when the problem requires a specialist. Business intake and prioritization should not be handled by the same agent that investigates an incident or implements a workflow.

**How they are invoked**: Claude Code can select them automatically based on context, or the user can ask for them explicitly ("use the incident-analyst agent").

**What they define**:
- Role and area of responsibility
- What they should review and in what order
- Expected output format
- What they should avoid doing

> Analogy: they are like team roles. You do not ask the same thing from the person handling intake and prioritization as you do from the person designing architecture or doing RCA.

---

### Skills — *structured workflows*

```
.claude/skills/
├── sql-review/
│   └── SKILL.md
├── backfill-planning/
│   └── SKILL.md
└── ...
```

A **skill** is a complete workflow with a checklist, steps, required inputs, and output format. It is the protocol Claude follows to execute a task consistently.

**When to use them**: when a task is important and recurring enough to standardize. An ad-hoc SQL review is one thing; a SQL review with a correctness + performance + storage-layout checklist is a skill.

**How they are invoked**: usually through a command (`/project:review-sql` invokes the `sql-review` skill). They can also activate automatically if the context matches.

**What they define**:
- Required inputs
- Step-by-step review checklist
- Output format, with examples
- Example usage prompt

> Analogy: they are like runbooks or process checklists. The agent knows *what to do*; the skill tells it *how to do it for this type of task*.

---

### Commands — *entry points*

```
.claude/commands/
├── review-sql.md
├── generate-backfill-plan.md
└── ...
```

A **command** is what the user types: `/project:review-sql`, `/project:generate-backfill-plan`. It is the trigger. A command file is short and only tells Claude which skill to invoke, what inputs to expect, and a few operational notes.

**When to create them**: when you want a task to be invokable with a slash command from the Claude Code interface.

**How they are invoked**: the user types `/command-name` in chat.

**What they define**:
- Which skill to run
- What input to expect from the user
- Behavior for incomplete input
- Notes specific to that entry point

> Analogy: they are like API endpoints. The logic lives in the skill; the command is the URL that exposes it.

---

### Rules — *team standards*

```
.claude/rules/
├── sql-style-guide.md
├── orchestration-workflow-guide.md
├── analytical-modeling-guide.md
└── ...
```

**Rules** are the team's persistent context. Claude reads them as part of its base configuration and applies them to *everything* it does in the project, without the user having to mention them.

**When to create them**: when there is a standard, convention, or principle that should always apply, regardless of which task is being executed.

**How they are applied**: automatically. They are not invoked; they are always present.

**What they define**:
- Code and style standards
- Team engineering principles
- Naming, modeling, and data quality conventions
- What is prohibited without explicit approval

> Analogy: they are like the team's `CONTRIBUTING.md` or Architecture Decision Log, except Claude reads and applies them actively.

---

## How they relate to each other

```
User types:      /project:review-sql

    ↓
Command          review-sql.md
                 "Invoke the sql-review skill. Expect a SQL query as input."

    ↓
Skill            sql-review/SKILL.md
                 "1. Read the query. 2. Apply the correctness checklist.
                  3. Apply the performance checklist. 4. Output findings."

    ↓
Agent (if applicable) data-engineer.md
                 "I am the implementation and technical review specialist.
                  I review correctness, idempotency, operational risk..."

    ↓
Rules (always)   sql-style-guide.md + data-engineering-principles.md
                 "No SELECT *. DELETE always with WHERE. Idempotency first."
```

The command triggers the work, the skill structures it, the agent executes it with specialized judgment, and the rules apply as persistent context.

---

## When to add what

| I want... | Create... |
|---|---|
| A new type of specialist, for example a dbt reviewer | `agents/dbt-reviewer.md` |
| A new checklist-driven review workflow, for example reviewing a dbt schema | `skills/dbt-schema-review/SKILL.md` |
| Expose that workflow as a slash command | `commands/review-dbt-schema.md` |
| Add a team convention that should always apply | `rules/dbt-style-guide.md` |
| Configure system permissions or hooks | `settings.json` |

---

## Files at the root of `.claude/`

| File | What it does |
|---|---|
| `settings.json` | Tool permissions, pre/post tool-use hooks, harness configuration |
| `README.md` | This file |

Claude's global behavior configuration for this project, including project context, default principles, and stack, lives in `CLAUDE.md` at the repo root, not here.
