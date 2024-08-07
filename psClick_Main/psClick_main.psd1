@{
ModuleVersion = '1.0.0.0'
RootModule = 'psClick_main.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
AliasesToExport = @("cl","??")
RequiredAssemblies = @("System.Windows.Forms", "PresentationCore","psClick.dll")
NestedModules = @(
    "commands.ps1"
    "Timers.ps1"
)
FunctionsToExport = @(
    "Change-Location"
    "Invoke-Ternary"
    "Start-Psclick"
    "Get-Bytes"
    "Get-String"
    "Stop-Script"
    "Pause-Script"
    "Pausable"
    "Send-Message"
    "Post-Message"
    "Start-timer"
    "Delete-Timer"
    "Get-Timer"
    "Show-FileDialog"
    "Show-FolderDialog"
    "Uninstall-Psclick"
    "Start-TimeWatcher"
    "Get-LevenshteinDistance"
    "Test-AdminRole"
    "Start-PlaySound"
    "Get-ClipboardHistory"
    "Publish-Image"
    "Add-DllToExe"
    "Install-Interception"
    "Remove-Interception"
)
}