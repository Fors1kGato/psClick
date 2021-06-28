function Get-Color{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [int]$X,
        [int]$Y,
        [IntPtr]$Handle = [IntPtr]::Zero
    )
    if($handle){
        $pt = [Drawing.Point]::new($x, $y)
        [Void][w32Windos]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$pt, 1)
        $x = $pt.X ; $y = $pt.Y
    }
    [psClickColor]::GetColor($x, $y, $handle)
}