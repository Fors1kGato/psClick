@{
ModuleVersion = '1.0.0.0'
RootModule = 'psClick_notification.psm1'
Author = 'Joshua (Windos) King'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
AliasesToExport = @()
RequiredAssemblies = @(".\lib\Microsoft.Toolkit.Uwp.Notifications\Microsoft.Toolkit.Uwp.Notifications.dll")
FunctionsToExport = @(
    'Show-Notification'
)
}