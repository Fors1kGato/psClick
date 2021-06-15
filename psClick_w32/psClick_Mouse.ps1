function Move-Cursor
{
    #.COMPONENT
    #2
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
    if($handle){
        $pt = [Drawing.Point]::new($x, $y)
        [Void][w32Windos]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$pt, 1)
        $x = $pt.X ; $y = $pt.Y
    }
    if($Event){
        if(![w32]::PostMessage($handle, 0x0200, 0, ($x + 0x10000 * $y))){
            [w32]::SendMessage($handle, 0x0200, 0, ($x + 0x10000 * $y))|Out-Null 
        }
    }
    else{
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