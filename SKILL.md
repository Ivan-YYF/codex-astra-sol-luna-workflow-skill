---
name: astra-sol-luna-workflow
description: "Explicitly enable a gpt-5.6-sol or gpt-6-astra root session to coordinate at most one gpt-5.6-luna executor and sole writer, with controls for context, logs, polling, verification, rework, and verifiable creation receipts. Use only when the user invokes $astra-sol-luna-workflow; never activate automatically."
---

# Luna + Sol/Astra Controlled Workflow

Apply this workflow only to the task where the user explicitly invokes the skill. User instructions, project `AGENTS.md`, authorization boundaries, safety rules, and higher-priority instructions always take precedence. This skill does not grant permission for deployment, external writes, destructive actions, or work outside the user's scope.

## Operating topology

- The current root session should be either `gpt-5.6-sol` or `gpt-6-astra`, acting as the sole coordinator, deep reasoner, and final reviewer. Preserve whichever supported parent model is already active; this skill does not switch the root model. If the actual model cannot be confirmed or selected, state that limitation instead of claiming a model switch.
- Each task may create zero or one `gpt-5.6-luna`. Create Luna only when the task requires repository inspection, search, command execution, file changes, or test execution. Pure discussion, explanation, planning, and read-only reasoning remain with the parent session.
- Create Luna with `fork_turns="none"`, default reasoning effort `high`, save the exact identifier returned by the tool, and reuse the same Luna for every follow-up.
- Immediately after every creation call that returns a verifiable identifier, before any search, command, edit, wait, or other tool call, emit exactly one creation receipt. Use the exact returned identifier: if the tool returns only `task_name`, use that field and do not require an `agent_id`. Use only runtime-confirmed model, effort, status, and parent values; if model or effort appear only as request parameters, label them `requested` and `unverified`. If status is omitted, report `tool did not provide` rather than treating the creation as failed. Do not repeat the receipt for follow-ups, polling, or status reports.
- Never create a second, parallel, replacement, specialist, testing, or review agent. Luna must not create or delegate to any subagent.
- Luna is the sole file writer. The `gpt-5.6-sol` or `gpt-6-astra` parent may inspect relevant files, contracts, diffs, and evidence, but must not edit the shared workspace concurrently.
- If Luna becomes unavailable, do not automatically create a replacement. Report the completed state, remaining work, and blocker; change the topology only after explicit user approval.

## Creation receipt

After every actual subagent creation with a verifiable returned identifier, immediately emit this receipt. Use the exact identifier and any runtime-confirmed fields returned by the creation tool. If it returns `thread_id`, `client_thread_id`, or `task_name`, use that exact field name and full value; never invent an `agent_id`. If model or effort were only requested, write `requested: <value>; unverified`; if status was omitted, write `tool did not provide`. The parent field must contain the runtime-confirmed parent/root model or `unverified`, never a hardcoded Sol claim. Keep the receipt free of task content, code, logs, Token data, secrets, and other sensitive information.

```text
[Agent Creation Receipt]
- identifier: <exact returned field and value, e.g. task_name: ... or thread_id: ...>
- model: <runtime-confirmed model, or requested: ...; unverified>
- reasoning_effort: <runtime-confirmed effort, or requested: ...; unverified>
- role: Luna, sole executor and file writer
- scope: <one-line task scope>
- status: <exact returned status, or tool did not provide>
- parent: <runtime-confirmed parent/root model, or unverified>
- limit: one Luna maximum; nested delegation disabled
```

If creation fails or returns no verifiable identifier, do not emit a success receipt. Emit a concise failure or indeterminate status with the actual error summary and stop further delegation. A missing status alone is not a creation failure when a verifiable identifier was returned.

## Execution Packet

The parent sends Luna the minimum packet needed to complete the task. Target 500-1,500 tokens for ordinary work and never exceed 3,000 tokens; compress before sending if necessary. Include:

1. goal, user-visible result, and acceptance checks;
2. scope, non-goals, single owner, authorization boundary, and stop conditions;
3. relevant paths, symbols, contracts, and invariants;
4. concise known errors, test evidence, attempts, and failure reasons;
5. execution steps and verification commands.

Prefer paths, symbols, and decisions. Do not copy complete files, the full repository, the full conversation, complete specifications, complete diffs, or long raw logs that Luna can read from the shared workspace.

## Reasoning effort

- The `gpt-5.6-sol` or `gpt-6-astra` parent uses `high` by default.
- The parent may use `max` for one decision cycle only when architecture, cross-module consistency, schema/Auth/Authorization/Privacy/provider/deployment boundaries, migration risk, concurrency, or repeated causally related failure requires it. Return to `high` after the decision is formed.
- Luna uses `high` by default. Temporarily use `xhigh` for difficult type, framework, test-causality, or implementation diagnosis, then return to `high`.
- Luna should return architecture or stable-contract questions to the parent with minimal evidence instead of compensating for missing facts with higher effort.

## Luna execution and output discipline

- Check Git boundaries and authoritative project sources first. Search narrowly for relevant paths, symbols, and call sites before reading files.
- Skip dependency directories, generated code, build artifacts, large lockfiles, and unrelated specifications unless they directly affect the task.
- Limit command output before returning it. For successful commands, report only the command, exit status, and concise statistics. For failures, report the first causally relevant error and minimum supporting context.
- Report incremental changes only. Do not resend the packet, unchanged findings, complete files, complete diffs, complete test logs, or already reported results.

Keep Luna's completion report around 300-800 tokens:

```markdown
## Changed
- path: behavior changed

## Verified
- command: PASS/FAIL; key result

## Remaining
- unverified items and residual risks

## Decision needed
- include only when the parent must decide
```

## Verification budget

Use progressive verification: smallest causally relevant check, affected-module checks, necessary integration or end-to-end checks, then one full required gate near completion. Do not rerun an identical check without a relevant code, configuration, environment, or evidence change. Keep successful output concise and expand only causally relevant failures.

## Waiting and polling

Prefer events over polling and use a real cursor or event token when the tool provides one; never fabricate a cursor. The first no-feedback check window is 120 seconds. If that window returns with no state change, use 300 seconds for the next no-feedback check window. These are adjustable default no-event check intervals, not mandatory delays, and the skill cannot guarantee precise timing or a hard Token cap: completion, failure, required user input, a new high-risk boundary, or a packet/repository conflict must return immediately.

Respect each tool's single-call limit and any higher-priority host communication requirement. If a tool cannot wait for the full interval, split the wait using the same real cursor/event token; do not reread the complete state or logs after every segment. While the state is unchanged, do not repeatedly wake the parent, reread context, or emit status messages.

Track effective progress, not polling success. After approximately 10 minutes without effective progress, perform one read-only diagnostic. A diagnostic does not reset that timer merely because polling succeeded or the task is still running; new effective progress does reset it. During the same silent period, do not repeat deep diagnostics. If there is no terminal state, resume event-based waiting.

For tests or builds with a known long expected duration, wait according to the estimate. Silence is not evidence of failure: do not interrupt, restart, or nudge Luna during a silent interval. Do not create a timer or recurring automation for this workflow.

## Review and correction

The parent performs a targeted review of changed contracts, high-risk code, failure paths, and verification evidence. Do not reread the entire ordinary implementation. Allow one normal correction round, send it to the same Luna, and keep the correction packet under 1,000 tokens.

If the same root cause remains unresolved, stop incremental patching. The parent must reassess the owner, contract, first failing boundary, and evidence; do not create another Luna. Continue only when new evidence changes the design judgment.

## Long-session control

At meaningful milestones, maintain a concise Working Summary containing the current goal, confirmed facts, changed files, actual verification, unresolved issues, and next step. Later packets reference the latest summary and task-specific facts only. The skill cannot erase history already accumulated by the root session; when old context materially reduces efficiency, recommend a new task using `gpt-5.6-sol` or `gpt-6-astra` with a 1-3K-token Handoff Packet, without creating that task automatically.

## Final delivery

The parent reports actual changes, commands and verification performed, passed and unverified items, remaining risks, and whether the user-visible goal is complete. Analysis, code reading, mocks, unrelated green tests, or commands that were not run are not completion evidence.
