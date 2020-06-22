#!/usr/bin/pwsh
param(
    [String]$SettingsPath,
    [String]$FileToAnalyze
)
$ScriptAnalyzerResults = Invoke-ScriptAnalyzer -EnableExit -Settings $SettingsPath -Path $FileToAnalyze