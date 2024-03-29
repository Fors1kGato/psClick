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
    "..\psClick_Main\psClick.dll"
    "..\psClick_Main\Libs\SharpDX\SharpDX.dll"
    "..\psClick_Main\Libs\SharpDX\SharpDX.DXGI.dll"
    "..\psClick_Main\Libs\SharpDX\SharpDX.Direct3D11.dll"
    "..\psClick_Main\Libs\zxing.dll"
)
NestedModules = @("Find-Image.ps1", "psClick_Color.ps1", "psClick_ImageReader.ps1")
FunctionsToExport = @(
    "Find-Image"
    "Get-Color"
    "Get-Image"
    "Cut-Image"
    "New-Color"
    "Show-Hint"
    "Close-Hint"
    "Get-Hint"
    "Compare-Color"
    "Draw-Rectangle"
    "Get-CursorImage"
    "Compare-Cursor"
    "Recognize-Text"
    "Get-SymbolsBase"
    "Get-RectangleFromScreen"
    "Show-WindowThumbnail"
    "Hide-WindowThumbnail"
    "Close-WindowThumbnail"
    "Find-HeapColor"
    "Find-Color"
    "Merge-Images"
    "Find-DynamicAreas"
    "Read-QRcode"
)
}