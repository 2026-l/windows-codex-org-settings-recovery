[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Protect-LocalPath {
    param([AllowNull()][string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return '<not set>'
    }

    $protected = $Value
    $replacements = [ordered]@{
        $env:USERPROFILE = '%USERPROFILE%'
        $env:LOCALAPPDATA = '%LOCALAPPDATA%'
        $env:APPDATA = '%APPDATA%'
    }

    foreach ($entry in $replacements.GetEnumerator()) {
        if (-not [string]::IsNullOrWhiteSpace($entry.Key)) {
            $protected = $protected.Replace($entry.Key, $entry.Value)
        }
    }

    return $protected
}

function Get-ScopeResult {
    param([ValidateSet('Process', 'User', 'Machine')][string]$Scope)

    $value = [Environment]::GetEnvironmentVariable('CODEX_CLI_PATH', $Scope)
    $exists = $false
    if (-not [string]::IsNullOrWhiteSpace($value)) {
        $exists = Test-Path -LiteralPath $value -PathType Leaf
    }

    [pscustomobject]@{
        Scope      = $Scope
        Configured = -not [string]::IsNullOrWhiteSpace($value)
        FileExists = $exists
        Value      = Protect-LocalPath $value
    }
}

Write-Host 'CODEX_CLI_PATH diagnosis (read-only; local paths are redacted)'
$results = 'Process', 'User', 'Machine' | ForEach-Object { Get-ScopeResult $_ }
$results | Format-Table -AutoSize

$userValue = [Environment]::GetEnvironmentVariable('CODEX_CLI_PATH', 'User')
if ([string]::IsNullOrWhiteSpace($userValue)) {
    Write-Host 'Result: no User-scoped CODEX_CLI_PATH is configured.'
    Write-Host "This project's targeted repair is unlikely to apply. Follow the decision tree."
} else {
    Write-Warning 'A User-scoped CODEX_CLI_PATH is configured.'
    if ($userValue -match '(?i)[\\/]npm[\\/].*@openai[\\/]codex') {
        Write-Warning 'The value appears to point into an npm-installed Codex package.'
    }
    Write-Host 'Preview the reversible repair with Repair-CodexCliPath.ps1 -WhatIf.'
}

Write-Host 'Important: an existing Explorer process may still hold an older environment until Windows is restarted.'

