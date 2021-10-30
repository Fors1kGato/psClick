@{
ModuleVersion = '1.0.0.0'
RootModule = 'psClick_w32.psm1'
Author = 'Fors1k'
Copyright = '(c) Fors1k / psClick.ru . All rights reserved.'
HelpInfoUri="https://psClick.ru"
PowerShellVersion='5.1'
RequiredAssemblies = @("System.Windows.Forms", "psClick_w32.dll", "System.Drawing")
NestedModules=@(
    "psClick_Mouse.ps1"
    "psClick_Mouse_click.ps1"
    "psClick_Keyboard.ps1"
    "psClick_Windows.ps1"
    "psClick_Send_Key.ps1"
    "psClick_W32functions.ps1"
)
AliasesToExport = @(
    'Clear-KeyState'
)
FunctionsToExport = @(
    # Mouse
    #
    'Move-Cursor'
    'Get-MouseSpeed'
    'Set-MouseSpeed'
    'Click-Mouse'
    'Get-CursorPosition'
    'Drag-WithMouse'
    'Scroll-Mouse'
    'Get-CursorHandle'
    'Set-ArduinoSetting'
    #
    # Keyboard
    #
    'Send-key'
    'Send-Text'
    'Type-Text'
    'Set-Text'
    'Get-KeyState'
    'Get-KeyboardLayout'
    'Get-KeyboardLayouts'
    'Set-KeyboardLayout'
    #
    # Windows
    #
    'Get-ChildWindows'
    'Get-WindowClassName'
    'Set-WindowText'
    'Get-WindowText'
    'Get-ForegroundWindow'
    'Set-ForegroundWindow'
    'Show-Window'
    'Find-Window'
    'Show-MessageBox'
    'Set-WindowTransparency'
    'Move-Window'
    'Get-WindowRectangle'
    'Close-Window'
    'Resize-Window'
    'Get-FocusWindow'
    'Get-WindowState'
    #
    # W32functions
    #
    'Write-ProcessMemory'
    'Read-ProcessMemory'
    'Get-ProcessModules'
    'Get-PointsDistance'
)
}