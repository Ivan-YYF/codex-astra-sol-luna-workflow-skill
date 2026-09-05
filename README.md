# Codex Astra/Sol + Luna Workflow Skill

An explicit-only Codex skill for a `gpt-5.6-sol` or `gpt-6-astra` root session coordinating at most one `gpt-5.6-luna` executor.

```text
Current `gpt-5.6-sol` or `gpt-6-astra` session
├── coordinates, reasons, and reviews
└── at most one Luna
    └── reads, searches, runs commands, edits, tests, and verifies
```

Luna is the sole writer. The parent session and Luna share the workspace, but they do not edit concurrently. The same Luna is reused for follow-up corrections; Luna cannot create subagents.

## What it controls

- One active Luna maximum per task; no parallel or replacement agents.
- An immediate, verifiable creation receipt after every successful agent-creation call.
- `fork_turns="none"` and a compact 500-1,500 token Execution Packet, hard-capped at 3,000 tokens.
- `gpt-5.6-sol` or `gpt-6-astra` parent `high` by default; one temporary `max` decision cycle only for genuinely difficult design or failure analysis.
- Luna `high` by default; temporary `xhigh` only for difficult implementation diagnosis.
- Narrow repository discovery and filtered command output.
- Incremental reports instead of repeated files, diffs, or logs.
- Progressive verification and one normal correction round.
- Event-first waiting with bounded no-feedback windows; see [Waiting and polling](SKILL.md#waiting-and-polling) for the exact intervals, diagnostic rule, and cursor requirements.

## Effort policy

```text
Routine repository execution       Luna high
Hard implementation diagnosis      Luna xhigh
Architecture or contract decision  Parent high
High still insufficient            Parent max for one decision cycle
```

Higher effort cannot replace missing evidence. Luna collects implementation facts; the `gpt-5.6-sol` or `gpt-6-astra` parent handles architecture and contract decisions.

## Creation receipt

Immediately after creating Luna, before any other tool call, emit one receipt using the exact values returned by the creation tool. The receipt may use a returned `thread_id`, `client_thread_id`, or `task_name` as its identifier; model/effort are `requested` and `unverified` when they were not runtime-confirmed, and an omitted status is `tool did not provide`:

```text
[Agent Creation Receipt]
- identifier: <exact returned field and value>
- model: <runtime-confirmed model, or requested: ...; unverified>
- reasoning_effort: <runtime-confirmed effort, or requested: ...; unverified>
- role: Luna, sole executor and file writer
- scope: <one-line task scope>
- status: <exact returned status, or tool did not provide>
- parent: <runtime-confirmed parent/root model, or unverified>
- limit: one Luna maximum; nested delegation disabled
```

Use the exact identifier field returned by the tool, including `task_name` when that is all it provides. Do not invent identifiers or repeat receipts for follow-ups and polling. A failed or indeterminate creation with no verifiable identifier must be reported as such and must not trigger another delegation; missing status alone is not a failure.

## Install

Clone the repository into your Codex skills directory.

macOS or Linux:

```bash
git clone https://github.com/Ivan-YYF/codex-astra-sol-luna-workflow-skill.git \
  "${CODEX_HOME:-$HOME/.codex}/skills/astra-sol-luna-workflow"
```

Windows PowerShell:

```powershell
git clone https://github.com/Ivan-YYF/codex-astra-sol-luna-workflow-skill.git `
  "$env:USERPROFILE\.codex\skills\astra-sol-luna-workflow"
```

Open a new Codex task or reload the app so skill discovery refreshes.

## Use

Invoke it explicitly:

```text
$astra-sol-luna-workflow Fix this issue, implement the change, and verify it.
```

Without `$astra-sol-luna-workflow`, the skill is not injected automatically:

```yaml
policy:
  allow_implicit_invocation: false
```

## Execution Packet

When Luna is needed, the parent sends only the context that can change execution:

- goal, visible result, acceptance checks, and non-goals;
- scope, owner, contracts, invariants, authorization, and stop conditions;
- relevant paths and symbols;
- concise errors, attempts, and test evidence;
- execution steps and verification commands.

The workflow keeps packets under 3,000 tokens, avoids copying files Luna can read locally, and allows one normal correction round sent to the same Luna.

## Requirements and limitations

- The best experience requires a Codex environment with model-specific subagents, reasoning-effort selection, shared workspace access, and event-based waiting.
- A Skill prompt cannot silently change the active root model. If the root is neither `gpt-5.6-sol` nor `gpt-6-astra`, or model selection is unavailable, state the actual limitation.
- The Skill can limit future duplication, but cannot erase context already accumulated by the root session. For a materially bloated session, start a new `gpt-5.6-sol` or `gpt-6-astra` task with a concise handoff.
- Project instructions, user authorization, and safety boundaries always take precedence.
- This skill does not grant deployment, external-write, destructive-action, or production permissions.

## Repository layout

```text
.
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
|-- README.md
`-- LICENSE
```

The public repository contains the installable skill at its root.

## License

MIT License. See [LICENSE](LICENSE).
