# Codex Astra/Sol + Luna 工作流 Skill

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a>
</p>

这是一个仅在显式选择或调用时启用的 Codex Skill：当前 `gpt-5.6-sol` 或 `gpt-6-astra` 根任务负责决策，并协调最多一个在侧边栏可见、独立运行的 `gpt-5.6-luna` 执行任务。

```text
当前 Sol 或 Astra 根任务
|-- 负责范围、授权边界、决策和审查
|-- 直接处理讨论和非常小、低风险的修改
`-- 创建或复用最多一个独立 Luna 任务
    `-- 作为唯一执行者调查、修改、测试和验证
```

该工作流使用独立 Codex 任务，而不是协作子智能体。Luna 任务会显示在侧边栏中，后续操作复用同一个任务，并可以验证对应本地运行时轮次的模型和思考强度。

## 思考强度路由

- 当前 Sol/Astra 根任务负责架构、稳定合约、范围、授权边界、安全边界、权衡和所有最终决定。
- 根任务使用主会话实际配置的思考强度。普通决策建议使用 `high`；架构、跨模块一致性、模式、认证、授权、隐私、供应商、部署、迁移、并发或其他高风险权衡，在主机会提供时使用 `max`。决策完成后回到 `high`。
- Luna 使用 `xhigh` 执行目标清晰、验收标准明确、步骤可重复或需要批量处理的任务。
- Luna 只在困难的实现诊断、测试因果分析、边界检查或执行失败调查时使用 `max`。实现结论明确后，后续 Luna 轮次回到 `xhigh`。
- Luna 使用 `max` 时仍不拥有决策权。遇到未解决的架构、稳定合约、安全边界或重大设计决定，先收集最小证据并等待 Sol/Astra 根任务决定。
- 当范围和所有权明确、变更局部且可逆、验证简单且不涉及敏感边界时，根任务可以直接处理纯讨论和非常小的任务。

更高的思考强度不能替代缺失的证据或父任务决定；运行时配置记录也不能证明消耗了多少内部思考 token。

## 独立任务规则

当用户显式调用本 Skill 并附带执行请求时，该调用授权当前请求内最多一个独立任务，不需要第二次 Skill 层确认。协调器使用 `create_thread`，并设置：

- `model: "gpt-5.6-luna"`；
- 根据 Luna 执行路由选择 `thinking: "xhigh"` 或 `"max"`；
- 已验证的项目和合适的 `local` 或 `worktree` 环境；
- 最小执行数据包；
- 一个 Luna 作为唯一执行者和文件写入者。

后续等待和修正都复用同一个任务。Luna 不得继续创建任务或子智能体。协调器可以检查相关合约、差异和证据，但不能并行编辑。父任务拥有的未决决定是停止条件：Luna 可以调查，但在父任务决定前不得实现受影响的合约或高风险边界。

当前请求的授权不会延续到无关的新请求。平台级工具审批、工作区权限、用户指令和安全边界仍然有效。由于隐式调用已关闭，后续根任务轮次需要继续使用本工作流时，应再次显式调用 Skill；这一步只是重新加载规则，不会授权创建第二个 Luna 任务。Luna 独立任务内部不应调用本 Skill。

## 可读的创建回执

创建回执使用简洁 Markdown，并将每个字段单独占一行。请求设置与运行时确认设置必须分开显示：

```markdown
**Luna task created**

- **Task**: `<threadId or clientThreadId>` (host: `<hostId>`)
- **Requested configuration**: `gpt-5.6-luna` / `<xhigh|max>`
- **Runtime verification**: Pending (the creation interface did not return actual settings)
- **Workspace**: `<short project name>` / `<local|worktree>`
- **Scope**: <one sentence>
```

缺少的状态字段应省略，不要使用“未提供”等低信息文本。任务标识符、模型名称、思考强度和返回状态必须保持完整。

## 运行时思考强度验证

当本地任务的 Codex 会话日志可读时，不要把完整 JSONL 加载到对话中，而是验证准确的任务和轮次：

```powershell
.\scripts\verify_thread_effort.ps1 `
  -ThreadId <threadId> `
  -TurnId <turnId> `
  -ExpectedEffort xhigh
```

需要验证 `max` 轮次时，将 `-ExpectedEffort` 改为 `max`。只有当会话 ID、轮次 ID、`gpt-5.6-luna` 模型和预期思考强度全部匹配时，脚本才会成功退出。远程、云端或受限主机可能无法提供这些证据；此时应报告运行时验证不可用。

## Token 使用控制

- 最多创建一个 Luna 任务并持续复用。
- 只发送会改变执行结果的上下文。
- 不要复制 Luna 可以在其工作区读取的文件、完整会话历史、完整差异或长日志。
- 使用增量补充和增量回执。
- 只有在缺少决定或验收结果时才读取任务历史。
- 纯讨论或符合直接处理条件的小任务不要创建 Luna 任务。

## 安装

将仓库克隆到 Codex skills 目录。

macOS 或 Linux：

```bash
git clone https://github.com/Ivan-YYF/codex-astra-sol-luna-workflow-skill.git \
  "${CODEX_HOME:-$HOME/.codex}/skills/astra-sol-luna-workflow"
```

Windows PowerShell：

```powershell
git clone https://github.com/Ivan-YYF/codex-astra-sol-luna-workflow-skill.git `
  "$env:USERPROFILE\.codex\skills\astra-sol-luna-workflow"
```

打开新的 Codex 任务或重新加载应用，使 Skill 发现结果刷新。

## 使用

### 桌面 Skill 选择器

1. 输入 `/astr` 等部分文字过滤可用 Skill。
2. 选择 **Astra/Sol + Luna Independent Task**。
3. 添加任务说明并发送消息。

输入 `/astr` 只会过滤选择器；只有选中建议项后，Skill 才算显式调用。

### 可移植的显式文本调用

当选择器不可用，或需要在不同 Codex 客户端之间共享提示词时，使用完整 Skill 名称：

```text
$astra-sol-luna-workflow 修复这个问题，实现修改并完成验证。
```

如果没有选中 Skill 项，也没有使用 `$astra-sol-luna-workflow`，该 Skill 不会自动注入：

```yaml
policy:
  allow_implicit_invocation: false
```

## 要求与限制

- 显式调用本 Skill 并附带执行请求时，当前请求内最多一个独立任务无需再次进行 Skill 层确认。
- 无关的新请求需要重新显式调用 Skill。
- Skill 不能静默改变当前根任务的模型或思考强度；无法选择或确认时，应报告主机实际设置。
- 本地运行时验证需要可读取的 Codex 会话记录。
- 项目指令、用户授权和安全边界始终优先。
- Skill 不授予部署、外部写入、破坏性操作或生产环境权限。

## 仓库结构

```text
.
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
|-- scripts/
|   `-- verify_thread_effort.ps1
|-- README.md
|-- README.zh-CN.md
`-- LICENSE
```

## 许可证

MIT License。详见 [LICENSE](LICENSE)。
