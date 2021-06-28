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
        [parameter(Mandatory=$true )]
        [IntPtr]$Handle
        ,
        [parameter(Mandatory=$false)]
        [Text.StringBuilder]$Text = [Text.StringBuilder]::new([int16]::MaxValue)
    )
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

function Show-Window
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory = $true)]
        [IntPtr]$Handle
        ,
        [parameter(Mandatory = $true)]
        [ValidateSet('ShowMaximized', 'Hide', 'ShowNoActivate', 'ShowDefault', 'ShowMinNoActivate', 'ShowNA', 'Show', 'Minimize', 'Restore', 'ShowMinimized', 'ShowNormal', 'Maximize', 'ForceMinimize', 'TopMost', 'Bottom', 'Top', 'NoTopMost')]
        [String]$State
    ) 
       
    $ShowWindow = @{
        HIDE            = 0
        SHOWNORMAL      = 1
        SHOWMINIMIZED   = 2
        MAXIMIZE        = 3
        SHOWMAXIMIZED   = 3
        SHOWNOACTIVATE  = 4
        SHOW            = 5
        MINIMIZE        = 6
        SHOWMINNOACTIVE = 7
        SHOWNA          = 8
        RESTORE         = 9
        SHOWDEFAULT     = 10
        FORCEMINIMIZE   = 11
    }
    $SetWindowPos = @{
        BOTTOM          =  1
        NOTOPMOST       = -2
        TOP             =  0
        TOPMOST         = -1
    }

    if($State -in $ShowWindow.Keys)
    {[w32Windos]::ShowWindow($Handle, $ShowWindow.$State)}
    else
    {[w32Windos]::SetWindowPos($Handle, $SetWindowPos.$State, 0,0,0,0, (0x0001 -bor 0x0002))}
}

function Find-Window
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory=$true,ParameterSetName = 'Title')]
        [String]$Title
        ,
        [Parameter(Mandatory=$true,ParameterSetName = 'Class')]
        [String]$Class 
        ,
        [Parameter(Mandatory,ParameterSetName = 'ProcessName')]
        [String]$ProcessName
        ,
        [Parameter(Mandatory=$true,ParameterSetName =  'wPid')]
        [String]$wPid
        ,
        [Parameter(Mandatory=$false,ParameterSetName ='Title')]
        [Parameter(ParameterSetName = 'ProcessName')]
        [ValidateSet('eq','match','ceq','cmatch')]
        [String]$Option = "eq"
    )

    $res  = [Collections.Generic.List[PSCustomObject]]::new()
    if($Title){
        $hwnd = [w32Windos]::FindWindowEx(0, 0, [NullString]::Value, [NullString]::Value)
        $text = [Text.StringBuilder]::new([int16]::MaxValue)
        $match = [scriptblock]::Create("`$name -$option `$Title")

        while ($hwnd -ne 0){
            if([w32Windos]::GetWindowText($hwnd, $text, [int16]::MaxValue)){
                $name = $text.ToString()
                if(&$match){
                    $res.Add([PSCustomObject]@{handle = $hwnd;title = $name})
                }
            }
            $hwnd = [w32Windos]::FindWindowEx(0, $hwnd, [NullString]::Value, [NullString]::Value)
        }
        return $res
    }

    if($Class){
        $hwnd = [w32Windos]::FindWindowEx(0, 0, $Class, [NullString]::Value)
        $text = [Text.StringBuilder]::new([int16]::MaxValue)

        while ($hwnd -ne 0){
            [Void][w32Windos]::GetWindowText($hwnd, $text, [int16]::MaxValue)
            $name = $text.ToString()
            $res.Add([PSCustomObject]@{handle = $hwnd;title = $name})
            $hwnd = [w32Windos]::FindWindowEx(0, $hwnd, $Class, [NullString]::Value)
        }
        return $res
    }
    if($ProcessName){
        Get-Process|where([scriptblock]::Create("`$_.ProcessName -$option `$ProcessName"))|
        ForEach{$res.Add([PSCustomObject]@{handle = $_.MainWindowHandle;title = $_.MainWindowTitle})}
        return $res
    }
    if($wPid){
        Get-Process -id $wPid|
        ForEach{$res.Add([PSCustomObject]@{handle = $_.MainWindowHandle;title = $_.MainWindowTitle})}
        return $res
    }
}