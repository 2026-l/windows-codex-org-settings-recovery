[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$BackupPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolved = Resolve-Path -LiteralPath $BackupPath
$backup = Get-Content -LiteralPath $resolved -Raw | ConvertFrom-Json

if ($backup.schemaVersion -ne 1 -or $backup.variable -ne 'CODEX_CLI_PATH' -or $backup.scope -ne 'User') {
    throw 'This file is not a supported CODEX_CLI_PATH User-scope backup.'
}

if ([string]::IsNullOrWhiteSpace([string]$backup.value)) {
    throw 'The backup does not contain a non-empty value.'
}

if ($PSCmdlet.ShouldProcess('User environment variable CODEX_CLI_PATH', "Restore from '$resolved'")) {
    [Environment]::SetEnvironmentVariable('CODEX_CLI_PATH', [string]$backup.value, 'User')
    $restored = [Environment]::GetEnvironmentVariable('CODEX_CLI_PATH', 'User')
    if ($restored -ne [string]$backup.value) {
        throw 'Verification failed: the restored value does not match the backup.'
    }

    Write-Host 'User-scoped CODEX_CLI_PATH was restored from the selected backup.'
    Write-Warning 'Save your work and restart Windows so new processes inherit the restored value.'
}

