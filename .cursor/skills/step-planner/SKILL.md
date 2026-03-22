---
name: step-planner
description: Breaks plans into a single small step per turn. Use when the user or agent has a multi-step plan and only one concrete, actionable task should be given at a time.
---

# Step Planner

## Purpose

Splits any plan into **one small step** per response. Each turn delivers exactly one concrete task so the user can do it, report back, then receive the next step.

## When to Use

- User shares a plan or goal and wants to work through it step-by-step
- A task has multiple sub-steps and should be executed one at a time
- User asks to "break this down" or "what do I do next"

## Rules for One Step

A single step must be:

1. **One action** — e.g. "add this function to this file", "run this command", "create this file with this content"
2. **Concrete** — no vague instructions; the user knows exactly what to do and where
3. **Small** — completable in one go without sub-decisions
4. **Reason included** — one short sentence explaining why this step comes now

## What to Output

Give **only**:

- The **next single step** (what to do and where)
- A **one-sentence reason** why this step is next

Do **not** list the full plan or future steps in the same message unless the user asks. After the user completes the step and reports back, give the next step.

## Example

**User:** "I want to add login to the app."

**Agent (one step):**  
"Create a new file `src/auth/login.cpp` with a function `bool validate_credentials(const std::string& user, const std::string& pass)` that returns true for now. Reason: we need a single place for auth logic before wiring it to the API."

**User:** "Done."

**Agent (next step):**  
"Add a call to `validate_credentials` in `src/api/handlers.cpp` inside the POST /login handler. Reason: connect the HTTP layer to the auth logic we just added."
