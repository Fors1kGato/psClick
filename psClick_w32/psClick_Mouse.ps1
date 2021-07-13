function Move-Cursor
{
    #.COMPONENT
    #3
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory,Position=0)]
        $Position
        ,
        [IntPtr]$Handle
        ,
        [Switch]$Event
    )
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
    }
    if($event -and !$handle){
        Write-Error "-Event: Требуется указать handle окна";return
    }
    if($Event){
        if(![w32]::PostMessage($handle, 0x0200, 0, ($Position.X + 0x10000 * $Position.Y))){
            [w32]::SendMessage($handle, 0x0200, 0, ($Position.X + 0x10000 * $Position.Y))|Out-Null 
        }
    }
    else{
        if($handle){
            [Void][w32Windos]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$Position, 1)
        }
        [Windows.Forms.Cursor]::Position = $Position
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
        $From
        ,
        [parameter(Mandatory=$true)]
        $To
        ,
        [IntPtr]$Handle
        ,
        [Switch]$Event
        ,
        [Int]$Delay = 64
    )
    #region Params Validating
    if($From -isnot [Drawing.Point]){
        try{$From = [Drawing.Point]::new.Invoke($From)}catch{throw $_}
    }
    if($To -isnot [Drawing.Point]){
        try{$To = [Drawing.Point]::new.Invoke($To)}catch{throw $_}
    }
    if($event -and !$handle){
        Write-Error "-Event: Требуется указать handle окна";return
    }
    #endregion
    #region Kleft 
    if(!$event){
        $button = "left"
        if($Handle){
            $pt = [Drawing.Point]::new($From.X, $From[1])
            [Void][w32Windos]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$pt, 1)
            $to.X  , $to.Y   = ($pt[0].X+$to.X-$from.X), ($pt[0].Y+$to.Y-$from.Y)
            $from.X, $from.Y = $pt[0].X, $pt[0].Y
        }
        Move-Cursor $from
        [w32Mouse]::mouse_event([w32Mouse+MouseEventFlags]::MOUSEEVENTF_LEFTDOWN, 0,0,0,0)

        Move-Cursor $to
        sleep -m $Delay
        [w32Mouse]::mouse_event([w32Mouse+MouseEventFlags]::MOUSEEVENTF_LEFTUP,   0,0,0,0)
    }
    #endregion
    #region left 
    else{   
        if ([w32]::PostMessage($handle, 0x0201, $wParams, ($From.X + 0x10000 * $From.Y))){
            [w32]::PostMessage($handle, 0x0200, $wParams, ($to.X   + 0x10000 * $to.Y  ))|Out-Null
            [w32]::PostMessage($handle, 0x0202, $wParams, ($to.X   + 0x10000 * $to.Y  ))|Out-Null 
        }
        else{
            [w32]::SendMessage($handle, 0x0201, $wParams, ($From.X + 0x10000 * $From.Y))|Out-Null
            [w32]::SendMessage($handle, 0x0200, $wParams, ($to.X   + 0x10000 * $to.Y  ))|Out-Null
            [w32]::SendMessage($handle, 0x0202, $wParams, ($to.X   + 0x10000 * $to.Y  ))|Out-Null
        }
    }
    #endregion
}