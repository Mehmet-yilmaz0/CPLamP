# evaluate-output

When this command runs:

1. **Use the output-evaluator skill** — compare the user's output or verification to what the current step required.
2. **If correct:** Confirm briefly, say what was achieved in one sentence, then move on (or give next step). No long recap.
3. **If wrong or incomplete:** Say what is wrong and why it matters; ask for one concrete correction. Do **not** give the next step until the user fixes it and you evaluate again.

Keep the reply short. One main issue per turn; wait for corrected output before advancing.
