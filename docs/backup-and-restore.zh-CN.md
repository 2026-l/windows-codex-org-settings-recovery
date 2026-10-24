# 备份与恢复

`Repair-CodexCliPath.ps1` 会在清除用户级值之前写入一个小型 JSON 备份。默认目录为：

```text
%LOCALAPPDATA%\CodexOrgSettingsRecovery\backups
```

备份包含原始路径、UTC 时间、变量名、作用域和格式版本，不包含 token 或应用日志；但路径可能暴露 Windows 用户目录名。请保留在本机，不要提交到仓库。

修复前可使用 `-WhatIf` 预览。回退时，把准确的备份文件路径传给 `Restore-CodexCliPath.ps1`；也可以先用 `-WhatIf` 预览恢复。无论清除还是恢复，都应在完成后重启 Windows。

若备份未明确标记格式版本 1、变量 `CODEX_CLI_PATH` 和 User 作用域，恢复脚本会拒绝执行。

