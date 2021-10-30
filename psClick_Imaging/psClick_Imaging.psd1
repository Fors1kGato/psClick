@{
ModuleVersion = '1.0.0.0'
RootModule = 'psClick_Imaging.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
AliasesToExport = @("Find-Color")
RequiredAssemblies = @(
    "System.Windows.Forms",
    "System.Drawing", 
    "psClick_Imaging.dll"
)
NestedModules = @("Find-Image.ps1", "Color.ps1")
FunctionsToExport = @(
    "Find-Image",
    "Get-Color",
    "Get-Image"
    "Cut-Image"
    "New-Color"
    "Show-Hint"
    "Close-Hint"
    "Get-Hint"
    "Compare-Color"
)
}