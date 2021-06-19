function Move-Cursor
{
    #.COMPONENT
    #2.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [Int]$X
        ,
        [parameter(Mandatory=$true)]
        [Int]$Y
        ,
        [IntPtr]$Handle
        ,
        [Switch]$Event
    )
    if($event -and !$handle){
        Write-Error "-Event: Требуется указать handle окна";return
    }
    if($Event){
        if(![w32]::PostMessage($handle, 0x0200, 0, ($x + 0x10000 * $y))){
            [w32]::SendMessage($handle, 0x0200, 0, ($x + 0x10000 * $y))|Out-Null 
        }
    }
    else{
        if($handle){
            $pt = [Drawing.Point]::new($x, $y)
            [Void][w32Windos]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$pt, 1)
            $x = $pt.X ; $y = $pt.Y
        }
        [Windows.Forms.Cursor]::Position = [Drawing.Point]::new($x, $y)
    }
}

function Get-MouseSpeed
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    [w32Mouse]::getMSpeed()
}

function Set-MouseSpeed
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        $speed
    )
    [w32Mouse]::setMSpeed($speed)
}

function Get-CursorPosition
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    [Windows.Forms.Cursor]::Position
}

function Drag-WithMouse
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [Int[]]$From
        ,
        [parameter(Mandatory=$true)]
        [Int[]]$To
        ,
        [IntPtr]$Handle
        ,
        [Switch]$Event
        ,
        [Int]$Delay = 64
    )
    #region Params Validating 
    if($event -and !$handle){
        Write-Error "-Event: Требуется указать handle окна";return
    }
    #endregion
    #region Kleft 
    if(!$event){
        $button = "left"
        if($Handle){
            $pt = [Drawing.Point]::new($From[0], $From[1])
            [Void][w32Windos]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$pt, 1)
            $to[0]  , $to[1]   = ($pt[0].X+$to[0]-$from[0]), ($pt[0].Y+$to[1]-$from[1])
            $from[0], $from[1] = $pt[0].X, $pt[0].Y
        }
        Move-Cursor $from[0] $from[1]
        [w32Mouse]::mouse_event([w32Mouse+MouseEventFlags]::MOUSEEVENTF_LEFTDOWN,0,0,0,0)

        Move-Cursor $to[0] $to[1]
        sleep -m $Delay
        [w32Mouse]::mouse_event([w32Mouse+MouseEventFlags]::MOUSEEVENTF_LEFTUP,  0,0,0,0)
    }
    #endregion
    #region left 
    else{   
        if ([w32]::PostMessage($handle, 0x0201, $wParams, ($From[0] + 0x10000 * $From[1]))){
            [w32]::PostMessage($handle, 0x0200, $wParams, ($to[0]   + 0x10000 * $to[1]  ))|Out-Null
            [w32]::PostMessage($handle, 0x0202, $wParams, ($to[0]   + 0x10000 * $to[1]  ))|Out-Null 
        }
        else{
            [w32]::SendMessage($handle, 0x0201, $wParams, ($From[0] + 0x10000 * $From[1]))|Out-Null
            [w32]::SendMessage($handle, 0x0200, $wParams, ($to[0]   + 0x10000 * $to[1]  ))|Out-Null
            [w32]::SendMessage($handle, 0x0202, $wParams, ($to[0]   + 0x10000 * $to[1]  ))|Out-Null
        }
    }
    #endregion
}