function Get-ChildWindows
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [IntPtr]$Handle
    )
    [w32Windos]::GetChildWindows($Handle)
}

function Set-WindowText
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [IntPtr]$Handle
        ,
        [String]$Text
    )
    [w32Windos]::SetWindowText($Handle, $Text)
}

function Get-WindowText
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [IntPtr]$Handle
    )
    $Text = [Text.StringBuilder]::new()
    [Void][w32Windos]::GetWindowText($Handle, $Text, [Int16]::MaxValue)
    $Text.ToString()
}

function Get-ForegroundWindow
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    [w32Windos]::GetForegroundWindow()
}

function Set-ForegroundWindow
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [IntPtr]$Handle
    )
    [w32Windos]::SetForegroundWindow($Handle)
}
