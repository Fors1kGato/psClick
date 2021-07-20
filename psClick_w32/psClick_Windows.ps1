function Set-WindowTransparency
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory,Position=0)]
        [Byte]$Transparency
        ,
        [parameter(Mandatory,Position=1)]
        [IntPtr]$Handle
    )
    $LWA_ALPHA = 2
    $GWL_EXSTYLE = -20
    $WS_EX_LAYERED = 0x80000

    $WindowStyle = [w32Windos]::GetWindowLongPtr($handle, $GWL_EXSTYLE)
    [Void][w32Windos]::SetWindowLongPtr($handle, $GWL_EXSTYLE, ($WindowStyle -bor $WS_EX_LAYERED))
    [w32Windos]::SetLayeredWindowAttributes($handle, [IntPtr]::Zero, $transparency, $LWA_ALPHA)
}

function Move-Window
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory,Position=0)]
        $Position
        ,
        [parameter(Mandatory,Position=1)]
        [IntPtr]$Handle
    )
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
    }
    [w32Windos]::SetWindowPos($Handle, [IntPtr]::Zero, $Position.X, $Position.Y, 0, 0, (0x0001 -bor 0x0004))
}

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

function Get-WindowClassName
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
    [Void][w32Windos]::GetClassName($handle, $text, [int16]::MaxValue)
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
        [Int]$wPid
        ,
        [Parameter(Mandatory=$false,ParameterSetName ='Title')]
        [Parameter(ParameterSetName = 'ProcessName')]
        [ValidateSet('EQ','match','cEQ','cMatch')]
        [String]$Option = "match"
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

function Show-MessageBox
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory = $true  , Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]$Text
        ,
        [Parameter(Mandatory = $false , Position = 1)]
        [String]$Title='psClick'
        ,
        [Parameter(Mandatory = $false , Position = 2)]
        [ValidateSet('OK','OKCancel','AbortRetryIgnore','YesNoCancel','YesNo','RetryCancel')]
        [String]$Buttons='OK'
        ,
        [Parameter(Mandatory = $false , Position = 3)]
        [ValidateSet('None','Hand','Error','Stop','Question','Exclamation','Warning','Asterisk','Information')]
        [String]$Icon='None'
        ,
        [Switch]$Topmost
    )
    [Windows.Forms.MessageBox]::Show(
        [Windows.Forms.Form]@{Topmost = $Topmost.IsPresent}, 
        [System.String]$Text, 
        [System.String]$Title, 
        [Windows.Forms.MessageBoxButtons]::$Buttons, 
        [Windows.Forms.MessageBoxIcon]::$Icon
    )
}