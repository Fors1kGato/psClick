@{
ModuleVersion = '1.0.0.0'
#RootModule = '.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
AliasesToExport = @("cl","??")
NestedModules = @(
    "Update-Psclick.ps1", 
    "Start-Psclick.ps1",
    "commands.ps1"
    "Timers.ps1"
)
FunctionsToExport = @(
    "Change-Location",
    "Invoke-Ternary",
    "Update-Psclick",
    "Start-Psclick",
    "Get-Bytes",
    "Get-String",
    "Stop-Script",
    "Pause-Script"
    "Pausable"
    "Send-Message"
    "Post-Message"
    "Start-timer"
    "Delete-Timer"
    "Get-Timer"
    "Show-FileDialog"
)
}