# Codex Luna + Sol Workflow Skill

An explicit-only Codex skill that uses GPT-5.6 Luna for repository execution and GPT-5.6 Sol for focused, read-only reasoning.

It keeps routine work fast, escalates effort only when evidence justifies it, and prevents two agents from editing the same workspace at the same time.

## What it does

```text
Routine execution                     Luna medium
Hard execution with a decided route   Luna high
Architecture or design uncertainty    Sol high
High remains insufficient             Sol xhigh
Hardest quality-first analysis         Sol max
```

- Luna is the sole writer and owns commands, edits, tests, and verification.
- Sol receives a compact 1-3K token Task Packet instead of the full project history.
- Sol is read-only and returns a structured recommendation.
- Luna verifies the recommendation against source code, project truth, and runtime evidence.
- The skill never activates implicitly.

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

## Task Packet

When Sol is needed, Luna sends only the context that can change the decision:

- goal, acceptance outcome, and non-goals;
- owners, contracts, invariants, and authorization boundaries;
- minimal code, exact paths, errors, and test evidence;
- attempted fixes and their failure reasons;
- candidate routes and one precise question.

The workflow allows one initial consultation and, only when new design-level evidence appears, one incremental reconsultation.

## Requirements and limitations

- The best experience requires a Codex environment that supports model-specific subagents and reasoning-effort selection.
- A skill prompt cannot silently change the active root model. When model selection is unavailable, the skill requires the agent to state that limitation.
- Project instructions, user authorization, and safety boundaries always take precedence.
- This skill does not grant deployment, external-write, destructive-action, or production permissions.

## Repository layout

```text
.
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
`-- README.md
```

The public repository contains the installable skill at its root.

## License

MIT License. See [LICENSE](LICENSE).
