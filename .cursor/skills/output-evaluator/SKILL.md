---
name: output-evaluator
description: Evaluates the output or verification result the user provides after a step. If correct, confirm briefly and proceed; if incorrect, explain what is wrong and ask for correction without advancing. Use when the user shares step output, verification results, or asks to check their result.
---

# Output Evaluator

## Purpose

Check the user's output or verification against what was expected for the current step. Decide whether to proceed or ask for a correction.

## Instructions

1. **Evaluate**
   - Compare the user's output to the expected outcome of the current step.
   - Consider: Does it satisfy the step's goal? Are there missing parts, errors, or contradictions?

2. **If the output is correct**
   - Confirm briefly (e.g. "Correct.", "That works.").
   - State in one sentence what was achieved.
   - Then give the next step or move on. Do not repeat long explanations.

3. **If the output is wrong or incomplete**
   - Say clearly what is wrong (e.g. wrong value, missing file, failed command).
   - Explain in one sentence why it matters for the task.
   - Ask for a correction (e.g. "Please fix X and share the result again.").
   - Do **not** give the next step until the output is correct.

## Rules

- Be short and direct. No vague praise or vague criticism.
- One correction request per turn: focus on the main issue.
- Do not assume the user will fix it; wait for their corrected output before advancing.

## Example

**User:** "I ran the command and got: Build failed, error in line 12."

**Agent (wrong output):** "The build is still failing. Line 12 is the problem — the step required a successful build before we continue. Please fix the error on line 12, run the build again, and paste the result."

**User:** "Fixed. Build succeeded."

**Agent (correct output):** "Correct. Build is successful. Next step: add the function to `src/parser.cpp` as described in the plan. Why: we need it before implementing the next phase."
