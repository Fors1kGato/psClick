@{
ModuleVersion = '1.0.0.0'
#RootModule = '.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
#AliasesToExport = @()
RequiredAssemblies = @()
NestedModules=@("psClick_bot.ps1","token.ps1")
FunctionsToExport = @(
    # Mouse
    #
    'Send-TelegramMessage'
    #
)
}