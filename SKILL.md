---
name: luna-sol-workflow
description: "Run an explicit GPT-5.6 Luna executor and GPT-5.6 Sol reasoning workflow with controlled effort escalation, compact Task Packets, and a single writer. Use only when the user explicitly invokes $luna-sol-workflow; never activate it automatically."
---

# Luna + Sol Workflow

Apply this workflow only to the task where the user explicitly invokes the skill. Project instructions, user authorization, safety boundaries, and higher-priority instructions always take precedence. This skill does not grant permission for deployment, external writes, destructive actions, or other work outside the user's scope.

## Models and ownership

- Prefer `gpt-5.6-luna` at `medium` effort as the executor. Luna reads, searches, runs commands, edits files, tests, verifies, and reports evidence. Luna is the sole writer.
- Use `gpt-5.6-sol` only as a read-only reasoning advisor. Sol must not edit files, run state-changing commands, or write concurrently with Luna.
- Never claim that a prompt changed the active root model. If the environment cannot select models, efforts, or subagents, state that limitation and continue with the available capability.
- If the root agent is not Luna and model-specific delegation is available, delegate execution to Luna while the root agent coordinates and reviews without becoming a second writer.

## Escalate reasoning by problem type

Use the lowest sufficient effort:

- Routine execution with one clear owner and contract: Luna `medium`.
- A decided approach with difficult multi-layer debugging, causal test analysis, concurrency, transactions, several invariants, or long conditional tool chains: temporarily use Luna `high`, then return to `medium`.
- Architecture choices, cross-owner decisions, stable contracts or data semantics, schema/Auth/Authorization/Privacy/provider/deployment boundaries, or an unreliable result from Luna `high`: consult Sol at `high`.
- Use Sol `xhigh` only when new evidence shows that `high` remains insufficient.
- Reserve `max` for the hardest quality-first analysis with objective evaluation criteria after `xhigh` has proved insufficient. Prefer Sol; do not make Luna `max` an automatic escalation.

More effort cannot replace missing evidence. Have Luna collect facts first. One evidence-backed reasoning miss at `medium` may justify Luna `high`. Two causally related failed fixes or a weakened core assumption should stop local patching and trigger Sol consultation.

## Build a Task Packet for Sol

Do not inherit the full conversation when consulting Sol. When supported, use `fork_turns="none"`. Send a focused Task Packet targeting 1-3K tokens with:

1. Goal, acceptance outcome, and non-goals.
2. Owners, contracts, invariants, authorization boundaries, and stop conditions.
3. Minimal code or diff, exact file paths, errors, and test evidence.
4. Attempts already made and why they failed.
5. Candidate routes, the central disagreement, and the exact question to answer.

Do not send the whole repository context, unrelated history, or long raw logs. Sol may read only files explicitly listed in the packet and may request at most one targeted supplement.

Ask Sol to separate facts from inference and return: core judgment, assumptions and confidence, route tradeoffs, one recommendation, implementation order by owner/contract/schema, tests and negative paths, risks, disconfirming evidence, and stop conditions.

## Close the loop

Sol's answer is advice, not project truth. Luna must verify it against the current source, authoritative project documents, and runtime evidence before implementing and testing it.

Allow one initial consultation by default. Reconsult once only when execution produces new evidence that could change the design judgment, and send only the delta.

The final report must state actual changes, commands and verification performed, passed and unverified items, whether Sol's advice was accepted and why, and remaining risks. Analysis, code reading, mocks, unrelated green tests, or commands that were not run are not completion evidence.
