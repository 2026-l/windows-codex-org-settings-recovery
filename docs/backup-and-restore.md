# Backup and restore

`Repair-CodexCliPath.ps1` writes a small JSON backup before clearing the User value. The default directory is:

```text
%LOCALAPPDATA%\CodexOrgSettingsRecovery\backups
```

The backup contains the original path, a UTC timestamp, the variable name, the scope, and a schema version. It contains no token or application log, but the path may reveal the Windows profile name. Keep it private and do not commit it.

Preview a repair with `-WhatIf`. To roll back, pass the exact backup file to `Restore-CodexCliPath.ps1`; preview the restore with `-WhatIf` first if desired. Restart Windows after either operation.

The scripts refuse to restore a backup that does not identify schema version 1, `CODEX_CLI_PATH`, and User scope.

