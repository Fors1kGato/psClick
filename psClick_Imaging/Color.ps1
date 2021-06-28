function Get-Color{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [int]$x,
        [int]$y,
        [IntPtr]$handle = [IntPtr]::Zero
    )
    [psClickColor]::GetColor($x, $y, $handle)
}