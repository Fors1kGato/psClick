function Find-Image{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        $smallPath,
        $bigPath,
        $deviation = 0,
        $accuracy  = 100
    )

    if(-not ('Drawing.Bitmap'-as [Type]))
    {[Void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")}
    if(-not ('ImgSearcher'-as [Type]))
    {[Void][Reflection.Assembly]::Loadfile("$PSScriptRoot\psClick_SearchImage.dll")}

    $small = [Drawing.Bitmap]::new($smallPath)
    $big   = [Drawing.Bitmap]::new($bigPath)

    $res = [ImgSearcher]::searchBitmap($small, $big, $deviation, $accuracy)

    $small.Dispose()
    $big.Dispose()
    return $res
}