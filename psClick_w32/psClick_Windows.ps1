function Get-ScreenSize
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Switch]$All
    )
    if($All){
        [Windows.Forms.Screen]::AllScreens.Bounds
    }
    else{
        [Windows.Forms.Screen]::PrimaryScreen.Bounds
    }
}

Function Get-WindowState
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [IntPtr]$Handle
    )

    $GWL_EXSTYLE = -20
    $WS_EX_TOPMOST = 0x00000008

    [PSCustomObject]@{
        isForeground = [w32Windos]::GetForegroundWindow() -eq $Handle
        isVisible    = [w32Windos]::IsWindowVisible($Handle)
        isMinimized  = [w32Windos]::IsIconic($Handle)
        isMaximized  = [w32Windos]::IsZoomed($Handle)
        isTopMost    = [bool]([Int64][w32Windos]::GetWindowLongPtr($Handle, $GWL_EXSTYLE) -band $WS_EX_TOPMOST)
    }
}

function Get-WindowRectangle
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    param(
        [Parameter(Mandatory)]
        [IntPtr]$Handle
        ,
        [Switch]$Withborder
    )
    $wInfo = [w32Windos]::GetWindowInformation($Handle)
    if(!$Withborder){
        [Drawing.Rectangle]::new(
            $wInfo.rcClient.Left,
            $wInfo.rcClient.Top,
            $wInfo.rcClient.Right -$wInfo.rcClient.Left,
            $wInfo.rcClient.Bottom-$wInfo.rcClient.Top
        )
    }
    else{
        [Drawing.Rectangle]::new(
            $wInfo.rcWindow.Left,
            $wInfo.rcWindow.Top,
            $wInfo.rcWindow.Right -$wInfo.rcWindow.Left,
            $wInfo.rcWindow.Bottom-$wInfo.rcWindow.Top
        )
    }
}

function Get-FocusWindow
{
    #.COMPONENT
    #1.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    $lpdw = 0
    $thisPrc = [w32]::GetCurrentThreadId()
    $target  = [w32Windos]::GetWindowThreadProcessId(
        (Get-ForegroundWindow), [ref]$lpdw
    )
    [Void][w32]::AttachThreadInput($thisPrc, $target, $true)
    $focus = [w32Windos]::GetFocus()
    [Void][w32]::AttachThreadInput($thisPrc, $target, $false)
    $focus
}

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
    [Void][w32Windos]::SetLayeredWindowAttributes($handle, [IntPtr]::Zero, $transparency, $LWA_ALPHA)
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
    [Void][w32Windos]::SetWindowPos($Handle, [IntPtr]::Zero, $Position.X, $Position.Y, 0, 0, (0x0001 -bor 0x0004))
}

function Resize-Window
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory,Position=0)]
        $Size
        ,
        [parameter(Mandatory,Position=1)]
        [IntPtr]$Handle
    )
    $SWP_NOZORDER = 0x0004
    $SWP_NOMOVE   = 0x0002
    if($Size -isnot [Drawing.Size]){
        try{$Size = [Drawing.Size]::new.Invoke($Size)}catch{throw $_}
    }
    [Void][w32Windos]::SetWindowPos($Handle, [IntPtr]::Zero, 0, 0, $Size.Width, $Size.Height, ($SWP_NOZORDER -bor $SWP_NOMOVE))
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
    #2.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [IntPtr]$Handle
        ,
        [String]$Text
        ,
        [Switch]$ToControl
    )
    if($ToControl){
        $ptr = [Runtime.InteropServices.Marshal]::StringToHGlobalAuto($text)
        [Void][w32]::SendMessage($Handle, 0x000C, 0, $ptr)
        [Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)
    }
    else{
        [Void][w32Windos]::SetWindowText($Handle, $Text)
        [Void][w32Windos]::InvalidateRect($Handle, [IntPtr]::Zero, $true)
    }
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
    [Void][w32Windos]::SetForegroundWindow($Handle)
}

function Show-Window
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory, Position = 0)]
        [IntPtr]$Handle
        ,
        [parameter(Position = 1)]
        [ValidateSet('ShowMaximized', 'Hide', 'ShowNoActivate', 'ShowDefault', 'ShowMinNoActivate', 'ShowNA', 'Show', 'Minimize', 'Restore', 'ShowMinimized', 'ShowNormal', 'Maximize', 'ForceMinimize', 'TopMost', 'Bottom', 'Top', 'NoTopMost')]
        [String]$State = 'ShowNormal'
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
    {[Void][w32Windos]::ShowWindow($Handle, $ShowWindow.$State)}
    else
    {[Void][w32Windos]::SetWindowPos($Handle, $SetWindowPos.$State, 0,0,0,0, (0x0001 -bor 0x0002))}
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
        return ,$res
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
        return ,$res
    }
    if($ProcessName){
        Get-Process|where([scriptblock]::Create("`$_.ProcessName -$option `$ProcessName"))|
        ForEach{$res.Add([PSCustomObject]@{handle = $_.MainWindowHandle;title = $_.MainWindowTitle})}
        return ,$res
    }
    if($wPid){
        Get-Process -id $wPid|
        ForEach{$res.Add([PSCustomObject]@{handle = $_.MainWindowHandle;title = $_.MainWindowTitle})}
        return ,$res
    }
}

function Show-MessageBox
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory = $true , Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]$Text
        ,
        [Parameter(Mandatory = $false, Position = 1)]
        [String]$Title='psClick'
        ,
        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateSet('OK','OKCancel','AbortRetryIgnore','YesNoCancel','YesNo','RetryCancel')]
        [String]$Buttons='OK'
        ,
        [Parameter(Mandatory = $false, Position = 3)]
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

function Close-Window
{
    #.COMPONENT
    #3
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory,Position=0)]
        [IntPtr]$Handle
        ,
        [Parameter(ParameterSetName = 'Force')]
        [Switch]$Force
        ,
        [Parameter(ParameterSetName = 'Wait')]
        [Switch]$Wait
        ,
        [Parameter(ParameterSetName = 'SuperForce')]
        [Switch]$SuperForce
    )
    $WM_DESTR = 0x0002
    $WM_CLOSE = 0x0010
    $re = [IntPtr]::Zero
    if($Force){
        [Void][w32]::PostMessage($Handle, $WM_DESTR, 0, 0)
        [Void][w32]::SendMessageTimeout($Handle, $WM_CLOSE, 0, 0, 0x0002, 0x8, [ref]$re)
    }
    elseif($Wait){
        [Void][w32]::SendMessage($Handle, $WM_CLOSE, 0, 0)
    }
    elseif($SuperForce){
        [Void][w32Windos]::EndTask($Handle, $false, $true)
    }
    else{
        [Void][w32]::PostMessage($Handle, $WM_CLOSE, 0, 0)
    }
}