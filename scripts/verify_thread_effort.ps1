[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9-]+$')]
    [string]$ThreadId,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9-]+$')]
    [string]$TurnId,

    [ValidateNotNullOrEmpty()]
    [string]$ExpectedModel = 'gpt-5.6-luna',

    [Parameter(Mandatory = $true)]
    [ValidateSet('xhigh', 'max')]
    [string]$ExpectedEffort,

    [string]$SessionsRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($SessionsRoot)) {
    $codexBase = if ($env:CODEX_HOME) {
        $env:CODEX_HOME
    }
    else {
        Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex'
    }
    $SessionsRoot = Join-Path $codexBase 'sessions'
}

$resolvedRoot = (Resolve-Path -LiteralPath $SessionsRoot).Path
$sessionFiles = @(Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Filter "*$ThreadId*.jsonl")

if ($sessionFiles.Count -ne 1) {
    throw "Expected exactly one session file for thread '$ThreadId'; found $($sessionFiles.Count)."
}

$sessionId = $null
$turnMatches = @()
$lineNumber = 0

Get-Content -LiteralPath $sessionFiles[0].FullName | ForEach-Object {
    $lineNumber++
    $entry = $_ | ConvertFrom-Json

    if ($entry.type -eq 'session_meta') {
        $sessionId = $entry.payload.id
    }

    if ($entry.type -eq 'turn_context' -and $entry.payload.turn_id -eq $TurnId) {
        $turnMatches += [pscustomobject]@{
            line = $lineNumber
            model = $entry.payload.model
            effort = $entry.payload.effort
            settings_model = $entry.payload.collaboration_mode.settings.model
            settings_effort = $entry.payload.collaboration_mode.settings.reasoning_effort
        }
    }
}

if ($sessionId -ne $ThreadId) {
    throw "Session metadata does not match thread '$ThreadId'."
}

if ($turnMatches.Count -ne 1) {
    throw "Expected exactly one turn_context for turn '$TurnId'; found $($turnMatches.Count)."
}

$turn = $turnMatches[0]
$confirmed = $turn.model -eq $ExpectedModel -and $turn.effort -eq $ExpectedEffort

[pscustomobject]@{
    confirmed = $confirmed
    thread_id = $ThreadId
    turn_id = $TurnId
    model = $turn.model
    effort = $turn.effort
    settings_model = $turn.settings_model
    settings_effort = $turn.settings_effort
    evidence_path = $sessionFiles[0].FullName
    evidence_line = $turn.line
} | ConvertTo-Json -Compress

if (-not $confirmed) {
    exit 2
}
