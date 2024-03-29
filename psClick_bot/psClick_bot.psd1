﻿@{
ModuleVersion = '1.0.0.0'
RootModule = 'psClick_bot.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
AliasesToExport = @('Send-TelegramAudio', 'Send-TelegramVideo', 'Send-TelegramPhoto')
RequiredAssemblies = @("System.Drawing", "..\psClick_Main\psClick.dll")
NestedModules=@("psClick_bot.ps1","..\psClick_UserData\bot\token.ps1")
FunctionsToExport = @(
    #
    'Send-TelegramMessage'
    'Send-TelegramDocument'
    #
)
}
