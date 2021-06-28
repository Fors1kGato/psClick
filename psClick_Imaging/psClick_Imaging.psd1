@{
ModuleVersion = '1.0.0.0'
#RootModule = '.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
#AliasesToExport = @()
RequiredAssemblies = @(
"System.Windows.Forms",
"System.Drawing", 
"psClick_Imaging.dll"
)
NestedModules = @("Find-Image.ps1", "Color.ps1")
FunctionsToExport = @("Find-Image","Get-Color")
}