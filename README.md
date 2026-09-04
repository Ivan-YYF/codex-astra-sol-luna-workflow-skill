# Codex Luna + Sol Workflow Skill

An explicit-only Codex skill for a `gpt-5.6-sol` root session coordinating at most one `gpt-5.6-luna` executor.

```text
Current Sol session
├── coordinates, reasons, and reviews
└── at most one Luna
    └── reads, searches, runs commands, edits, tests, and verifies
```

Luna is the sole writer. Sol and Luna share the workspace, but they do not edit concurrently. The same Luna is reused for follow-up corrections; Luna cannot create subagents.

## What it controls

- One active Luna maximum per task; no parallel or replacement agents.
- `fork_turns="none"` and a compact 500-1,500 token Execution Packet, hard-capped at 3,000 tokens.
- Sol `high` by default; one temporary `max` decision cycle only for genuinely difficult design or failure analysis.
- Luna `medium` by default; temporary `high` only for difficult implementation diagnosis.
- Narrow repository discovery and filtered command output.
- Incremental reports instead of repeated files, diffs, or logs.
- Progressive verification and one normal correction round.
- Event-based waiting with incremental cursors instead of high-frequency polling.

## Effort policy

```text
Routine repository execution       Luna medium
Hard implementation diagnosis      Luna high
Architecture or contract decision  Sol high
High still insufficient            Sol max for one decision cycle
```

Higher effort cannot replace missing evidence. Luna collects implementation facts; Sol handles architecture and contract decisions.

## Install

Clone the repository into your Codex skills directory.

macOS or Linux:

```bash
git clone https://github.com/Ivan-YYF/codex-luna-sol-workflow-skill.git \
  "${CODEX_HOME:-$HOME/.codex}/skills/luna-sol-workflow"
```

Windows PowerShell:

```powershell
git clone https://github.com/Ivan-YYF/codex-luna-sol-workflow-skill.git `
  "$env:USERPROFILE\.codex\skills\luna-sol-workflow"
```

Open a new Codex task or reload the app so skill discovery refreshes.

## Use

Invoke it explicitly:

```text
$luna-sol-workflow Fix this issue, implement the change, and verify it.
```

Without `$luna-sol-workflow`, the skill is not injected automatically:

```yaml
policy:
  allow_implicit_invocation: false
```

## Execution Packet

When Luna is needed, Sol sends only the context that can change execution:

- goal, visible result, acceptance checks, and non-goals;
- scope, owner, contracts, invariants, authorization, and stop conditions;
- relevant paths and symbols;
- concise errors, attempts, and test evidence;
- execution steps and verification commands.

The workflow keeps packets under 3,000 tokens, avoids copying files Luna can read locally, and allows one normal correction round sent to the same Luna.

## Requirements and limitations

- The best experience requires a Codex environment with model-specific subagents, reasoning-effort selection, shared workspace access, and event-based waiting.
- A Skill prompt cannot silently change the active root model. If the root is not Sol or model selection is unavailable, state the actual limitation.
- The Skill can limit future duplication, but cannot erase context already accumulated by the root session. For a materially bloated session, start a new Sol task with a concise handoff.
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
