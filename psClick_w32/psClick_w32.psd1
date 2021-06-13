@{
ModuleVersion = '1.0.0.0'
#RootModule = '.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
#AliasesToExport = @()
RequiredAssemblies = @("System.Windows.Forms", "w32.dll")
NestedModules=@("Mouse.ps1")
FunctionsToExport = @(
    'Move-Cursor'
    'Get-MouseSpeed'
    'Set-MouseSpeed'
    'Click-MouseLeft'
    'Get-CursorPosition'
)
}