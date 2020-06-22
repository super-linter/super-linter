#!/usr/bin/pwsh
param(
    [String]$SettingsPath,
    [String]$FileToAnalyze
)
Invoke-ScriptAnalyzer -EnableExit -Settings $SettingsPath -Path $FileToAnalyze
