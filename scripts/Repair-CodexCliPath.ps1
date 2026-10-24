[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [string]$BackupDirectory = (Join-Path $env:LOCALAPPDATA 'CodexOrgSettingsRecovery\backups')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$userValue = [Environment]::GetEnvironmentVariable('CODEX_CLI_PATH', 'User')
if ([string]::IsNullOrWhiteSpace($userValue)) {
    Write-Host 'No User-scoped CODEX_CLI_PATH is configured. Nothing was changed.'
    exit 0
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupPath = Join-Path $BackupDirectory "codex-cli-path-$timestamp.json"
$backup = [ordered]@{
    schemaVersion = 1
    createdAt     = (Get-Date).ToUniversalTime().ToString('o')
    variable      = 'CODEX_CLI_PATH'
    scope         = 'User'
    value         = $userValue
}

if ($PSCmdlet.ShouldProcess('User environment variable CODEX_CLI_PATH', "Back up to '$backupPath' and clear")) {
    New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
    $backup | ConvertTo-Json | Set-Content -LiteralPath $backupPath -Encoding UTF8
    [Environment]::SetEnvironmentVariable('CODEX_CLI_PATH', $null, 'User')

    if (-not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable('CODEX_CLI_PATH', 'User'))) {
        throw 'The User-scoped value is still present. No success is claimed; use the backup path shown below.'
    }

    Write-Host 'User-scoped CODEX_CLI_PATH was cleared.'
    Write-Host "Backup: $backupPath"
    Write-Warning 'The backup contains the original local path. Do not publish or attach it to an issue.'
    Write-Warning 'Save your work and restart Windows before testing the desktop app.'
    Write-Host 'Starting the app from the existing Explorer process is not a clean verification.'
}

