#!/usr/bin/pwsh
param(
    [String]$SettingsPath,
    [String]$FileToAnalyze
)
Invoke-ScriptAnalyzer -Settings $SettingsPath -Path $FileToAnalyze