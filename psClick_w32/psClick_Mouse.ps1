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
        [parameter(Mandatory=$true)]
        [Int]$X,
        [parameter(Mandatory=$true)]
        [Int]$Y,
        [IntPtr]$HWnd,
        [Switch]$Event
    )
    if(!$event){
        if($hWnd){Write-Warning "При указании handle требуется параметр -Event";return}
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
    else{
        if(!$hWnd){
            Write-Warning "Укажите handle окна";return
        }
        if ([w32]::SendMessage($hWnd, 0x0201, 0, ($y * 0x10000 + $x))){
            [Void][w32]::SendMessage($hWnd, 0x0202, 0, ($y * 0x10000 + $x))
        }
        else{
            [Void][w32]::PostMessage($hWnd, 0x0201, 0, ($y * 0x10000 + $x))
            [Void][w32]::PostMessage($hWnd, 0x0202, 0, ($y * 0x10000 + $x))
        }
    }
}

function Click-MouseRight
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [Int]$X,
        [parameter(Mandatory=$true)]
        [Int]$Y,
        [IntPtr]$HWnd,
        [Switch]$Event
    )
    if(!$event){
        if($hWnd){Write-Warning "При указании handle требуется параметр -Event";return}
        Move-Cursor $x $y
        [w32Mouse]::mouse_event(
            [w32Mouse+MouseEventFlags]::MOUSEEVENTF_RIGHTDOWN,
            $x,
            $y,
            0,
            0
        )
        [w32Mouse]::mouse_event(
            [w32Mouse+MouseEventFlags]::MOUSEEVENTF_RIGHTUP,
            $x,
            $y,
            0,
            0
        )
    }
    else{
        if(!$hWnd){
            Write-Warning "Укажите handle окна";return
        }
        if ([w32]::SendMessage($hWnd, 0x0008, 0, ($y * 0x10000 + $x))){
            [Void][w32]::SendMessage($hWnd, 0x0010, 0, ($y * 0x10000 + $x))
        }
        else{
            [Void][w32]::PostMessage($hWnd, 0x0008, 0, ($y * 0x10000 + $x))
            [Void][w32]::PostMessage($hWnd, 0x0010, 0, ($y * 0x10000 + $x))
        }
    }
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