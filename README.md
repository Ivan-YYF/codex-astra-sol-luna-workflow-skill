# Codex Astra/Sol + Luna Workflow Skill

An explicit-only Codex skill for a current `gpt-5.6-sol` or `gpt-6-astra` task coordinating at most one sidebar-visible, independent `gpt-5.6-luna` execution task.

```text
Current Sol or Astra task
├── owns scope, authorization, decisions, and review
├── handles discussion and very small, low-risk edits directly
└── creates or reuses at most one independent Luna task
    └── investigates, edits, tests, and verifies as the sole writer
```

The workflow uses an independent Codex task, not a collaboration subagent. It keeps Luna work inspectable in the sidebar, reuses the same task for follow-ups, and can verify the model and reasoning effort of a matching local runtime turn.

## Effort routing

- The current Sol/Astra task owns architecture, stable contracts, scope, authorization, safety boundaries, trade-offs, and every final decision.
- Use the parent task's actual configured effort for decisions. `high` is the normal recommendation; use `max`, when the host makes it available, for architecture, cross-module consistency, schema, authentication, authorization, privacy, providers, deployment, migrations, concurrency, or other high-risk trade-offs. Return to `high` after the decision.
- Use Luna `high` for execution with a clear target and acceptance criteria, repeatable steps, or batch processing.
- Use Luna `max` only for difficult implementation diagnosis, test-causality analysis, edge-case inspection, or execution failure investigation. Return later Luna turns to `high` after the implementation conclusion is clear.
- Luna `max` never transfers decision ownership. If Luna encounters an unresolved architecture, stable-contract, security-boundary, or major design decision, it gathers minimal evidence and waits for the Sol/Astra parent to decide before implementing that boundary.
- Handle pure discussion and very small tasks directly in the current Sol/Astra task when scope and ownership are clear, the change is local and reversible, verification is simple, and no sensitive boundary is involved.

Higher effort cannot replace missing evidence or an absent parent decision, and a runtime configuration record does not prove how many internal reasoning tokens were consumed.

## Independent task rules

When the user explicitly authorizes an independent task, the coordinator uses `create_thread` with:

- `model: "gpt-5.6-luna"`;
- `thinking: "high"` or `"max"` according to the Luna execution routing rules;
- the verified saved project and appropriate `local` or `worktree` environment;
- a minimal execution packet;
- one Luna as the sole executor and file writer.

Follow-ups and corrections reuse the same task. Luna must not create additional tasks or subagents. The coordinator may inspect relevant contracts, diffs, and evidence, but does not edit concurrently. An unresolved parent-owned decision is a stop condition: Luna may investigate it, but must not implement the affected contract or high-risk boundary until the parent decides.

## Readable creation receipt

The creation receipt uses Chinese Markdown with one field per line. Requested settings remain visibly separate from runtime-confirmed settings:

```markdown
**Luna 任务已创建**

- **任务**：`<threadId 或 clientThreadId>`（主机：`<hostId>`）
- **请求配置**：`gpt-5.6-luna` · `<high|max>`
- **运行时核验**：待核验（创建接口未返回实际配置）
- **工作区**：`<项目短名>` · `<local|worktree>`
- **任务范围**：<一句话>
```

Missing status is omitted instead of being shown as low-information noise. Full task identifiers, model names, effort values, and returned statuses are preserved.

## Runtime effort verification

For local tasks whose Codex session logs are readable, verify the exact task and turn without loading the complete JSONL into the conversation:

```powershell
.\scripts\verify_thread_effort.ps1 `
  -ThreadId <threadId> `
  -TurnId <turnId> `
  -ExpectedEffort high
```

Use `-ExpectedEffort max` for a max turn. The script exits successfully only when the session ID, turn ID, `gpt-5.6-luna` model, and expected effort all match. Remote, cloud, or restricted hosts may not expose this evidence; in that case the workflow reports that runtime verification is unavailable.

## Token discipline

- Create at most one Luna task and reuse it.
- Send only the context that can change execution.
- Do not copy files, full conversation history, complete diffs, or long logs Luna can read from its workspace.
- Use incremental follow-ups and reports.
- Read task history only when a decision or acceptance result is missing.
- Do not create a Luna task for pure discussion or qualifying very small work.

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

Invoke the skill explicitly:

```text
$astra-sol-luna-workflow Fix this issue, implement the change, and verify it.
```

Without `$astra-sol-luna-workflow`, the skill is not injected automatically:

```yaml
policy:
  allow_implicit_invocation: false
```

## Requirements and limitations

- A Skill cannot silently change the active root model or reasoning effort; report the host's actual setting when it cannot be selected or confirmed.
- Creating an independent task requires explicit user authorization.
- Local runtime verification requires readable Codex session records.
- Project instructions, user authorization, and safety boundaries always take precedence.
- The skill does not grant deployment, external-write, destructive-action, or production permissions.

## Repository layout

```text
.
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
|-- scripts/
|   `-- verify_thread_effort.ps1
|-- README.md
`-- LICENSE
```

## License

MIT License. See [LICENSE](LICENSE).
