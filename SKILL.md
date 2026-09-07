---
name: astra-sol-luna-workflow
description: "Use only when explicitly selected or invoked. The current gpt-5.6-sol or gpt-6-astra parent owns decisions and coordinates at most one independent gpt-5.6-luna xhigh/max execution task, with controlled handoffs, context, waiting, verification, and runtime receipts. Tiny tasks may be handled directly; never auto-trigger."
---

# Astra/Sol + Luna Independent Task Workflow

Use this Skill only when the user explicitly enables it with `$astra-sol-luna-workflow`, a direct Skill link, or the UI; `$` does not need to be the first character in the message. In a desktop Skill picker, partial text such as `/astr` only filters the available Skills; the user must select the actual **Astra/Sol + Luna Independent Task** item before sending. Treat the selected Skill item as the explicit invocation, while `$astra-sol-luna-workflow <task>` remains the portable text form. Do not load this Skill when it was not explicitly selected. This Skill does not expand the user's goal or permissions. An explicit invocation may authorize at most one current-request independent Luna task under the bounded rule below; it does not authorize deployments, unrelated external writes, or destructive actions. User instructions, project `AGENTS.md`, safety rules, and higher-priority instructions always take precedence.

## Direct-work boundary and topology

- The parent handles discussion, explanation, planning, and tiny tasks that simultaneously have clear scope and ownership, are local and reversible, have simple verification, and cross no module or sensitive boundary. A small diff does not make a risky task tiny; if any condition is not met, treat the task as complex.
- The parent owns the goal, scope, authorization boundary, stop conditions, architecture and contract reasoning, trade-offs, and every final decision. When independent execution is needed, use one sidebar-visible Luna task. Luna investigates, implements, and verifies, then returns factual evidence and unresolved questions. The parent avoids repeating Luna's full investigation and reviews only the relevant contracts, risks, diff, and evidence.
- After independent execution starts, Luna is the sole executor and file writer. Reuse the same task for every follow-up, wait, and correction; the parent retains read-only review permission and must not edit concurrently. Luna executes the packet, does not run this Skill's coordination workflow, and must not create other tasks or subagents. Do not create parallel, replacement, testing, review, or specialist executors. If Luna becomes unavailable, report the completed state and blocker instead of replacing it automatically.
- Keep the parent on the host-selected `gpt-5.6-sol` or `gpt-6-astra`; this Skill does not switch the parent model. The parent makes decisions at the reasoning effort actually configured by the host. Recommend `high` for ordinary decisions and `max` for architecture, cross-module consistency, schema, authentication, authorization, privacy, providers, deployment, migrations, concurrency, or other high-risk trade-offs. Claim that the effort changed only when the host supports the change and it actually took effect; recommend returning to `high` after the complex decision.
- Create independent Luna work with `create_thread`, explicitly requesting `model: "gpt-5.6-luna"` and an execution-specific `thinking` value. Use `xhigh` for execution turns with a clear target and acceptance criteria, repeatable steps, or batch processing. Use `max` only for difficult implementation diagnosis, test-causality analysis, edge-case inspection, or execution failure investigation, then return to `xhigh` once the implementation conclusion is actionable. Luna `max` never transfers decision ownership: for architecture, stable contracts, security boundaries, or major trade-offs, Luna gathers minimal evidence and waits for the parent to decide before implementing. Do not create a collaboration subagent, use a full-history fork, or pass `fork_turns`. If the runtime rejects the requested combination, report it without silently downgrading or substituting a model.
- Only host runtime fields tied to the target turn confirm the model, effort, or state. Request parameters, static configuration, and Luna's self-report are not proof of runtime selection. A runtime record confirms that turn's configuration, not how many internal reasoning tokens were consumed. If the host cannot expose or set a value, state that limitation and do not claim confirmation.

## Creating and reusing the independent task

The names below refer to Codex app tools and may vary with the current host interface. An explicit invocation of this Skill together with an execution request authorizes at most one independent Luna task for that request when the execution rules require it; do not ask for a second confirmation. This authorization is limited to the current user request and declared scope, does not carry to later unrelated requests, and does not override platform-level tool approval, workspace permissions, safety rules, or higher-priority instructions. Call `create_thread` only when an independent executor is required and no suitable task exists. If the user asks only to edit this Skill, make the configuration change directly and do not create a test task. A task title is not model evidence; a model selector may show current configuration but does not prove which settings a previous turn used.

1. Reuse the `threadId` and `hostId` already recorded for this workflow. Only use `list_threads` for a targeted search when those identifiers are unavailable. Create a task only when no suitable task exists, after applying the direct-work boundary and selecting `xhigh` or `max` by the execution rules above. The explicit Skill invocation supplies the current-request authorization; ask only for a genuinely missing product or scope decision.
2. For repository or directory work, call `list_projects` to obtain the real `projectId` and verify its path, host, and `isGitRepository`. Default Git projects to `environment: {type: "worktree"}`; use `local` for non-Git projects. Follow an explicit request to use the saved project directly. Do not guess a project ID or branch, or substitute a different directory.
3. Start a worktree from the project's default branch unless the user explicitly chooses the current working tree or another branch. If the task depends on uncommitted changes that are absent from the chosen start, resolve the starting-state decision before execution. Resolve a missing project binding instead of using `projectless` to bypass directory permissions; use `projectless` only for genuinely repository-free work.
4. Include the model, thinking effort, verified target, the relationship-first title defined below, and the minimal execution packet in the creation request. An independent task does not inherit the parent's complete history. The packet must name the execution directory and start state, define Luna as the sole writer, prohibit further delegation, and state stop conditions.
5. Save the returned `threadId` and `hostId`. If creation returns only `clientThreadId`, mark the task as pending and do not pass that value to tools that require `threadId`. Wait for host setup and, when necessary, use a bounded `list_threads` lookup to identify the resulting task. If no real identifier can be correlated, report uncertainty and do not create another task. After successful creation, emit any created-task directive required by the host in the final response.

### Independent-task title

Set the independent task title to `[Luna] <root-label> - <scope>` so its role and relationship to the root task remain visible at the start of the sidebar title. Use the root task's current title for `<root-label>` when it is available; otherwise derive a concise two-to-four-word label from the root goal or verified project name without claiming it is the exact title. Normalize whitespace, remove line breaks and structural delimiters, and keep the label to 24 visible characters or fewer, truncating at a word boundary when possible and adding `~`. Keep `<scope>` to a short description of the initially authorized execution unit. Do not copy secrets or sensitive values into the title.

Keep the title stable across ordinary follow-ups, waits, corrections, and effort changes. `[Luna]` identifies the workflow role; do not put the model version, any thinking effort (`high`, `xhigh`, or `max`), runtime state, task identifiers, paths, or other configuration in the title. Do not create a replacement task merely to refresh a title after the root task is renamed.

## Creation receipt and runtime verification

After the creation call returns a verifiable identifier, immediately emit exactly one short receipt before any search, command, edit, wait, or other tool call. Use concise Markdown with one field per line; never produce a semicolon-delimited line of key-value pairs. Use the title "Luna task created" when `threadId` is returned and "Luna task is being created" when only `clientThreadId` is returned. When the creation interface does not return runtime settings, show "Pending verification" and never present requested values as actual values:

```markdown
**Luna task created**

- **Task**: `<threadId or clientThreadId>` (host: `<hostId>`)
- **Requested configuration**: `gpt-5.6-luna` / `<xhigh|max>`
- **Runtime verification**: Pending (the creation interface did not return actual settings)
- **Workspace**: `<short project name>` / `<local|worktree>`
- **Scope**: <one sentence>
```

Keep the actual `threadId`, `clientThreadId`, `hostId`, model, effort, and returned state values complete and untranslated. Show only the short project name and execution environment by default; add a separate path or branch line only when needed to distinguish the execution location. Add a **State** line when the interface returns a state. Omit it when `status` is absent instead of showing low-information text such as "not provided." Independent tasks are peers for coordination purposes; do not invent a runtime parent relationship. If creation explicitly fails or returns no identifier, use the title "Luna task creation failed," report the actual error and uncertain fields one per line, do not claim success, and do not recreate blindly.

Verify the actual turn configuration once the first Luna execution turn starts. Prefer model and effort fields returned directly by the host. Otherwise obtain the exact `threadId`, `hostId`, and `latestTurn.id` from `wait_threads` or `read_thread`. For a local host with readable Codex `sessions` records, run `scripts/verify_thread_effort.ps1 -ThreadId <threadId> -TurnId <turnId> -ExpectedEffort <xhigh|max>`; do not load the complete JSONL into the conversation. The script returns `confirmed: true` only when the session ID, turn ID, `model=gpt-5.6-luna`, and expected effort all match, and emits only minimal evidence and a source line number.

Merge verification into the next normal progress or completion message. Confirmation applies only to the matching turn. Verify a new turn when settings change, the task moves to another host, fields conflict, or another turn must be claimed as confirmed. Use the same readable layout:

```markdown
**Luna runtime configuration verified**

- **Task**: `<threadId>`
- **Turn**: `<turnId>`
- **Actual configuration**: `gpt-5.6-luna` / `<xhigh|max>`
- **Evidence**: `<runtime record path>:<line>`
```

For a remote, cloud, restricted host, or script failure, use the title "Luna runtime configuration unavailable" and show **Requested configuration**, **Missing evidence**, and an actionable reason on separate lines. Do not expand permissions or substitute Luna's self-report for missing evidence.

## Follow-up and waiting

- Send incremental packets to the same `threadId` and `hostId` with `send_message_to_thread`. Omit `model` and `thinking` when the execution class is unchanged. When Luna moves between clear or batch execution and difficult implementation diagnosis, explicitly request `thinking: "xhigh"` or `thinking: "max"` for the new turn and verify it. When a new parent-owned decision boundary appears, stop the affected implementation, let the parent decide, and then send the decision in an incremental packet. If the user directly changes the executor's settings or gives conflicting instructions, follow the latest user choice and coordinate scope before sending more work.
- Creation is asynchronous. After dispatch, use `wait_threads`; use `timeoutMs: 0` for an immediate snapshot and carry forward the returned cursor as `targets[].afterCursor`. Split waits to respect the host's per-call and communication limits; do not reread the whole task after each segment.
- Start with a 120-second no-event window and use 300 seconds after an unchanged result, split as required by the host's maximum wait. Handle completion, failure, new user input, or new risk immediately. Silence does not prove failure. After roughly ten minutes without meaningful progress, perform one read-only diagnostic; do not repeat diagnostics, nudges, or task creation during the same silent period.
- Use `read_thread` only when a decision or acceptance result is missing. Limit `turnLimit` and `maxOutputCharsPerItem`, and include outputs only when needed. Forward approval and user-input requests instead of deciding for the user. Collect a concise completion report before reading targeted evidence.
- Worktree changes belong to the actual worktree path and branch. Review them there instead of assuming they appear in the original checkout. At delivery, identify the modification location and integration state. Commit, merge, push, handoff, and archive only with the required user authorization.

## Execution packet and reports

Send only the minimum packet needed to complete the task; there is no minimum token count and no fixed template to fill. As needed, preserve the goal, user-visible result, acceptance criteria, scope, non-goals, ownership, authorization, stop conditions, parent-approved design and contract decisions, relevant paths, symbols, invariants, known errors, factual evidence, execution plan, and verification plan. Unresolved parent-owned decisions are stop conditions: Luna may investigate them but must not modify the corresponding contract or high-risk boundary until the parent decides. Paths must refer to Luna's real environment. Do not copy complete files, repositories, conversations, specifications, diffs, or long logs that Luna can read from the workspace.

Luna reports only deltas. A completion report should include the changed paths and behavior, commands actually run and their results, factual evidence, unverified items, remaining risk, and decisions required from the parent. Do not repeat the packet, unchanged facts, complete diffs, or complete logs; later reports contain only new information.

## Investigation, logs, and context

- Confirm the Git boundary and authoritative project source first. Start from the task directory and known paths, use `rg` for targeted path, symbol, and call-graph searches, and read only related files. Expand the search only for concrete evidence. Skip dependencies, generated files, build artifacts, large lock files, and unrelated specifications by default; inspect diff statistics first. Do not load or modify unrelated files or Skills.
- For successful commands, report the command, exit status, and concise statistics. For failed commands, retain the first causal error and the minimum necessary context. Save large logs to an appropriate file after checking for secrets and personal data and redacting when necessary. Return only key evidence and its location, without truncating away the root cause.
- Do not create a timer or recurring automation for this workflow. Apart from the one user-authorized Luna task, do not create other tasks automatically. A short phase summary may be maintained, but it does not erase history. Only suggest a new coordinator task with a minimal handoff summary when old context has become materially stale and is reducing effectiveness; never create it automatically.

## Verification, review, and delivery

Expand verification in proportion to impact and required gates: start with the smallest causal check, then the affected module, required integration or E2E checks, and finally the complete required gate. Do not rerun the same check without a code, configuration, environment, or relevant evidence change; new evidence triggers a rerun. Never weaken a safety or acceptance requirement.

The parent performs a targeted review of changed contracts, high-risk paths, failure paths, and verification evidence. Allow one normal correction round and keep it with the same Luna. If the same root cause remains unresolved, stop incremental patching and reassess ownership, contracts, the first failing boundary, and current evidence; do not create another Luna.

The final delivery must distinguish actual changes, commands actually run and their results, passed checks, unverified items, remaining risk, and whether the user's goal is complete. Analysis, code reading, mocks, unrelated green tests, and commands that were not run are not completion evidence.
