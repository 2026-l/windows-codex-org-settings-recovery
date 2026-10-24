# Windows Codex organization-settings recovery

[简体中文](README.zh-CN.md)

A privacy-conscious recovery kit for one Windows failure mode where the ChatGPT/Codex desktop app stops at **“Unable to load organization settings.”**

## What this project establishes

In one confirmed case, a user-scoped `CODEX_CLI_PATH` pointed to an npm-installed `codex.exe`. Removing the **User** environment variable and then restarting Windows restored both ChatGPT and Work.

This is a field report, not proof that every identical dialog has the same cause. The same message can also be caused by networking, proxy, authentication, policy, WSL, or app/runtime problems.

Two details mattered in the confirmed recovery:

- Removing `CODEX_CLI_PATH` only from the current PowerShell process did not change the environment already inherited by Explorer.
- Launching the app from that existing Explorer process therefore did not provide a clean test. A full Windows restart did.

Re-registering the AppX package and sending an environment-change notification did not resolve this case.

## Safe quick start

1. Run the read-only diagnostic:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-CodexCliPath.ps1
   ```

2. Preview the repair. This makes no changes:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Repair-CodexCliPath.ps1 -WhatIf
   ```

3. If the diagnostic shows an unexpected **User** value, apply the repair:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Repair-CodexCliPath.ps1
   ```

4. Save the displayed backup path, close your work, and restart Windows. Do not judge the result by relaunching from the same Explorer session.

5. If necessary, restore the saved value:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Restore-CodexCliPath.ps1 -BackupPath '<path-to-backup.json>'
   ```

The repair script changes only the user-scoped `CODEX_CLI_PATH`. It does not delete Codex data, reset the app, edit machine-wide variables, restart Explorer, or reboot Windows.

## Before you change anything

- Close or save work before the eventual restart.
- Do not publish the generated backup. It may contain a local executable path and therefore a Windows user-profile name.
- If `CODEX_CLI_PATH` is intentionally managed by your employer or administrator, stop and ask them before changing it.
- If both User and Machine scopes are empty, use the [decision tree](docs/decision-tree.md); this particular repair is unlikely to help.

## Files

- `scripts/Test-CodexCliPath.ps1` — read-only, redacted diagnosis.
- `scripts/Repair-CodexCliPath.ps1` — backs up and clears the User value; supports `-WhatIf`.
- `scripts/Restore-CodexCliPath.ps1` — restores from a backup; supports `-WhatIf`.
- `docs/decision-tree.md` — triage flow that avoids assuming one universal root cause.
- `docs/backup-and-restore.md` — backup format and rollback instructions.
- `SECURITY.md` — privacy and vulnerability-reporting guidance.
- `DISCLAIMER.md` — scope and limitations.

## Evidence boundaries

**Verified in the source case:** the User value pointed into an npm installation; clearing it and restarting Windows restored ChatGPT and Work.

**Observed but ineffective in the source case:** clearing only the current shell, relaunching from the existing Explorer session, AppX re-registration, and an environment-change notification.

**Inference:** the desktop app or a child process likely inherited the stale User value through Explorer. This project does not claim to establish the app's internal failure path.

## Upstream contribution

The `openai/codex` contribution guide asks the community to use existing issues for bug reports and root-cause analysis and states that external pull requests are not accepted. A sanitized field report should therefore be added to the most relevant existing issue rather than proposed as an upstream code or documentation PR.

## License

MIT. See [LICENSE](LICENSE).

