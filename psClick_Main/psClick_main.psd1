@{
ModuleVersion = '1.0.0.0'
#RootModule = '.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
AliasesToExport = @("cl","??")
NestedModules=@("Change-Location.ps1","Invoke-Ternary.ps1","Update-Psclick.ps1", "psClick.ps1")
FunctionsToExport = @("Change-Location","Invoke-Ternary","Update-Psclick","psClick")
}