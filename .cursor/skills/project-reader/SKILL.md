---
name: project-reader
description: Reads README, implementation plan, functions.txt, and .cursor/rules at conversation start so the agent has full project context. Use at the beginning of a session or when the user wants the agent to read the project or get context.
---

# Project Reader

## When to use

- At the **start** of a conversation about this project.
- When the user asks to "read the project", "get context", or "understand the plan".

## What to read (in order)

1. **README.md** — project overview and purpose.
2. **docs/implementation_plan.md** (or **implementation_plan.md** if at repo root) — full implementation plan.
3. **functions.txt** — if it exists; source of truth for all functions.
4. **.cursor/rules/** — every rule file in this directory (e.g. `.mdc` or `.md`), so agent behavior and project conventions are clear.

## After reading

- Summarize briefly what the project is and what the plan says.
- Use this context for all following steps; refer to the plan and rules when giving instructions or evaluating output.
