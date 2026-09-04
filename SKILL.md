---
name: luna-sol-workflow
description: "Explicitly enable a GPT-5.6 Sol root session to coordinate at most one GPT-5.6 Luna executor and sole writer, with controls for context, logs, polling, verification, and rework Token usage. Use only when the user invokes $luna-sol-workflow; never activate automatically."
---

# Luna + Sol Controlled Workflow

Apply this workflow only to the task where the user explicitly invokes the skill. User instructions, project `AGENTS.md`, authorization boundaries, safety rules, and higher-priority instructions always take precedence. This skill does not grant permission for deployment, external writes, destructive actions, or work outside the user's scope.

## Operating topology

- The current root session should be `gpt-5.6-sol`, acting as the sole coordinator, deep reasoner, and final reviewer. If the actual model cannot be confirmed or selected, state that limitation instead of claiming a model switch.
- Each task may create zero or one `gpt-5.6-luna`. Create Luna only when the task requires repository inspection, search, command execution, file changes, or test execution. Pure discussion, explanation, planning, and read-only reasoning remain with Sol.
- Create Luna with `fork_turns="none"`, default reasoning effort `high`, save its Agent ID, and reuse the same Luna for every follow-up.
- Never create a second, parallel, replacement, specialist, testing, or review agent. Luna must not create or delegate to any subagent.
- Luna is the sole file writer. Sol may inspect relevant files, contracts, diffs, and evidence, but must not edit the shared workspace concurrently.
- If Luna becomes unavailable, do not automatically create a replacement. Report the completed state, remaining work, and blocker; change the topology only after explicit user approval.

## Execution Packet

Sol sends Luna the minimum packet needed to complete the task. Target 500-1,500 tokens for ordinary work and never exceed 3,000 tokens; compress before sending if necessary. Include:

1. goal, user-visible result, and acceptance checks;
2. scope, non-goals, single owner, authorization boundary, and stop conditions;
3. relevant paths, symbols, contracts, and invariants;
4. concise known errors, test evidence, attempts, and failure reasons;
5. execution steps and verification commands.

Prefer paths, symbols, and decisions. Do not copy complete files, the full repository, the full conversation, complete specifications, complete diffs, or long raw logs that Luna can read from the shared workspace.

## Reasoning effort

- Sol uses `high` by default.
- Sol may use `max` for one decision cycle only when architecture, cross-module consistency, schema/Auth/Authorization/Privacy/provider/deployment boundaries, migration risk, concurrency, or repeated causally related failure requires it. Return to `high` after the decision is formed.
- Luna uses `high` by default. Temporarily use `xhigh` for difficult type, framework, test-causality, or implementation diagnosis, then return to `high`.
- Luna should return architecture or stable-contract questions to Sol with minimal evidence instead of compensating for missing facts with higher effort.

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
- include only when Sol must decide
```

## Verification budget

Use progressive verification: smallest causally relevant check, affected-module checks, necessary integration or end-to-end checks, then one full required gate near completion. Do not rerun an identical check without a relevant code, configuration, environment, or evidence change. Keep successful output concise and expand only causally relevant failures.

## Waiting and polling

Use event-based waiting, the longest reasonable wait window, and an incremental cursor when available. While status is unchanged, do not repeatedly wake Sol, reread context, or emit status messages. Wake Sol only for completion, failure, required user input, a new high-risk boundary, or a conflict between the packet and repository facts.

## Review and correction

Sol performs a targeted review of changed contracts, high-risk code, failure paths, and verification evidence. Do not reread the entire ordinary implementation. Allow one normal correction round, send it to the same Luna, and keep the correction packet under 1,000 tokens.

If the same root cause remains unresolved, stop incremental patching. Sol must reassess the owner, contract, first failing boundary, and evidence; do not create another Luna. Continue only when new evidence changes the design judgment.

## Long-session control

At meaningful milestones, maintain a concise Working Summary containing the current goal, confirmed facts, changed files, actual verification, unresolved issues, and next step. Later packets reference the latest summary and task-specific facts only. The skill cannot erase history already accumulated by the root session; when old context materially reduces efficiency, recommend a new Sol task with a 1-3K-token Handoff Packet, without creating that task automatically.

## Final delivery

Sol reports actual changes, commands and verification performed, passed and unverified items, remaining risks, and whether the user-visible goal is complete. Analysis, code reading, mocks, unrelated green tests, or commands that were not run are not completion evidence.
