# Troubleshooting decision tree

Start with `scripts/Test-CodexCliPath.ps1`. Do not upload its output without reviewing it.

```text
“Unable to load organization settings” on Windows
|
+-- Is a User-scoped CODEX_CLI_PATH configured?
|   |
|   +-- Yes
|   |   |
|   |   +-- Is it expected and administrator-managed?
|   |       +-- Yes -> Stop and ask the administrator.
|   |       +-- No  -> Preview repair (-WhatIf), back up, clear User value,
|   |                 restart Windows, then retest.
|   |
|   +-- No
|       -> Do not apply this project's targeted repair.
|
+-- After a full restart, did ChatGPT/Codex and Work recover?
    |
    +-- Yes -> Keep the backup private; document only sanitized facts.
    +-- No  -> The shared dialog may have another cause. Check app version,
              account sign-in, network/proxy behavior, Windows/WSL mode,
              and current upstream issues. Avoid destructive cleanup.
```

## Why a restart is part of the test

Windows processes inherit environment variables from their parent. Removing a variable in one PowerShell process affects that process, not an Explorer process that already holds the previous environment. An app launched from the existing Explorer session can therefore inherit the stale value. A restart creates a clean inheritance chain.

## When this path does not fit

Do not force this repair when:

- User and Machine scopes are already empty.
- the value is intentionally managed;
- the app only fails in WSL mode;
- logs point to a network-policy, proxy, authentication, or runtime failure; or
- the problem began after moving application data or altering package files.

The same UI message is a generic startup gate, not a unique diagnosis.

