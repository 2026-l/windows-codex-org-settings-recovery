# Windows Codex 组织设置加载失败恢复工具

[English](README.md)

这是一个注重隐私、可回退的 Windows 排障项目，适用于 ChatGPT/Codex 桌面端卡在 **“Unable to load organization settings（无法加载组织设置）”** 的一种已验证故障情形。

## 先按报错选择指南

| 症状 | 对应指南与 `CODEX_CLI_PATH` 操作 |
| --- | --- |
| `Unable to locate the Codex CLI binary`（或指向 `codex.cmd` 后出现 `spawn EINVAL`） | [原生 CLI 临时解决方案](https://github.com/2026-l/chatgpt-windows-codex-cli-fix/blob/main/README_zh-CN.md)：将**用户级**变量设为已验证的原生 `codex.exe` 路径，而不是 `codex.cmd` 包装脚本。 |
| `Unable to load organization settings`（无法加载组织设置） | [组织设置恢复指南](https://github.com/2026-l/windows-codex-org-settings-recovery/blob/main/README.zh-CN.md)：先诊断；若存在异常的**用户级**覆盖值，先预览修复，再备份并清除该值，**重启 Windows** 后验证。 |

> **不要把两套方案连续执行。** 它们针对不同的已报告症状，对同一个变量的操作恰好相反。设置变量不是组织设置报错的通用修复，清除变量也不是找不到 CLI 的通用修复。组织设置指南仅记录了**一个已确认恢复的案例**，并未证明根因或通用有效性。若报错改变，应重新按对应指南排查，而不是反复设置、清除变量。若该变量由管理员有意配置，修改前先咨询管理员。

## 本项目能够确认什么

在一台实际设备上，用户级 `CODEX_CLI_PATH` 指向 npm 安装目录中的 `codex.exe`。清除这个**用户级**环境变量并重启 Windows 后，ChatGPT 与 Work 均恢复正常。

这是一份经过验证的个案记录，并不表示所有相同提示都由同一原因造成。网络、代理、登录、组织策略、WSL 或应用运行时异常也可能显示相同提示。

本次恢复有两个关键点：

- 只清除当前 PowerShell 进程中的 `CODEX_CLI_PATH`，不会改变 Explorer 已继承的旧环境。
- 因此，从原有 Explorer 进程重新启动应用并不能形成干净的验证；完整重启 Windows 才能做到。

本案例中，重新注册 AppX 包以及发送环境变量变更通知都没有修复问题。

## 安全使用

1. 运行只读诊断：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-CodexCliPath.ps1
   ```

2. 预览修复，不做任何更改：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Repair-CodexCliPath.ps1 -WhatIf
   ```

3. 如果诊断显示**用户级**值异常，再执行修复：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Repair-CodexCliPath.ps1
   ```

4. 保存脚本显示的备份路径，保存工作并重启 Windows。不要只从当前 Explorer 会话重新打开应用后就下结论。

5. 如需回退，使用备份恢复：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Restore-CodexCliPath.ps1 -BackupPath '<备份文件路径.json>'
   ```

修复脚本只会修改用户级 `CODEX_CLI_PATH`；不会删除 Codex 数据、重置应用、修改机器级变量、重启 Explorer 或自动重启 Windows。

## 修改前须知

- 在最终重启前保存并关闭重要工作。
- 不要上传脚本生成的备份文件。备份可能包含本机可执行文件路径，从而暴露 Windows 用户目录名。
- 如果 `CODEX_CLI_PATH` 由单位管理员有意配置，请先咨询管理员。
- 如果用户级和机器级变量都为空，请改看[排查决策树](docs/decision-tree.zh-CN.md)；本项目的核心修复很可能不适用。

## 文件说明

- `scripts/Test-CodexCliPath.ps1`：只读、默认脱敏的诊断脚本。
- `scripts/Repair-CodexCliPath.ps1`：备份并清除用户级变量，支持 `-WhatIf`。
- `scripts/Restore-CodexCliPath.ps1`：从备份恢复，支持 `-WhatIf`。
- `docs/decision-tree.zh-CN.md`：不预设单一根因的排查流程。
- `docs/backup-and-restore.zh-CN.md`：备份格式与回退说明。
- `SECURITY.md`：隐私与安全问题报告指引。
- `DISCLAIMER.md`：适用范围与免责声明。

## 证据边界

**已验证事实：**源案例中的用户级变量指向 npm 安装路径；清除后重启 Windows，ChatGPT 与 Work 恢复。

**源案例中已尝试但无效：**只清除当前 shell、从原有 Explorer 会话重启应用、重新注册 AppX、发送环境变量变更通知。

**推断：**桌面应用或其子进程很可能通过 Explorer 继承了旧的用户级变量。本项目不声称已经证明应用内部的具体失败路径。

## 上游贡献方式

`openai/codex` 当前贡献规范要求社区通过已有 issue 提供复现、根因分析和脱敏诊断，并明确不接受外部 PR。因此，本案例适合在最相关的现有 issue 中补充经过脱敏的恢复记录，而不是提交上游代码或文档 PR。

## 许可证

MIT，见 [LICENSE](LICENSE)。

