function Get-Color{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [int]$X,
        [int]$Y,
        [IntPtr]$Handle = [IntPtr]::Zero
    )
    [psClickColor]::GetColor($x, $y, $handle)
}