function Start-psClick_ImageReader{ 
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    start "$psscriptroot\psClick — ImageReader.exe" -WorkingDirectory $psscriptroot
}