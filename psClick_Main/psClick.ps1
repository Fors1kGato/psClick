function psClick{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    start "$psscriptroot\psCLick.exe" -WorkingDirectory (split-path "$psscriptroot\psCLick.exe")
}
