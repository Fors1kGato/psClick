function Change-Location{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [alias("cl")]Param(
        $path
    )
    cd $path
    [Environment]::CurrentDirectory = $path
}