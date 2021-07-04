@{
ModuleVersion = '1.0.0.0'
#RootModule = '.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
#AliasesToExport = @()
RequiredAssemblies = @("System.Windows.Forms", "psClick_w32.dll", "System.Drawing")
NestedModules=@("psClick_Mouse.ps1", "psClick_Mouse_click.ps1", "psClick_Keyboard.ps1","psClick_Windows.ps1")
FunctionsToExport = @(
    # Mouse
    #
    'Move-Cursor'
    'Get-MouseSpeed'
    'Set-MouseSpeed'
    'Click-Mouse'
    'Get-CursorPosition'
    'Drag-WithMouse'
    #
    # Keyboard
    #
    'Send-key'
    'Send-Text'
    'Type-Text'
    'Get-KeyState'
    #
    # Windows
    #
    'Get-ChildWindows'
    'Get-WindowClass'
    'Set-WindowText'
    'Get-WindowText'
    'Get-ForegroundWindow'
    'Set-ForegroundWindow'
    'Show-Window'
    'Find-Window'
    #
)
}