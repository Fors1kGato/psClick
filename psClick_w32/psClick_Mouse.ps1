function Move-Cursor
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        $x, $y
    )
    [Windows.Forms.Cursor]::Position = [Drawing.Point]::new($x, $y)
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

function Click-MouseLeft
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        $x, $y
    )
    Move-Cursor $x $y
    [w32Mouse]::mouse_event(
        [w32Mouse+MouseEventFlags]::MOUSEEVENTF_LEFTDOWN,
        $x,
        $y,
        0,
        0
    )
    [w32Mouse]::mouse_event(
        [w32Mouse+MouseEventFlags]::MOUSEEVENTF_LEFTUP,
        $x,
        $y,
        0,
        0
    )

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