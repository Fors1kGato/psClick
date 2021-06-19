function Start-Psclick{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    start "$psscriptroot\psCLick.exe" -WorkingDirectory $psscriptroot
}
