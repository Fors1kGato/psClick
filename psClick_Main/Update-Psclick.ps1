function Update-Psclick
{
    #.COMPONENT
    #3
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    [System.Diagnostics.Process]::Start(@{
        FileName  = "powershell";Verb = "runas"
        Arguments = "irm 'github.com/Fors1kGato/psClick/raw/main/psClick_Main/psClick_Updater.ps1'|iex;pause"
    }).WaitForExit();Get-Module psClick*|ForEach-Object{Remove-Module $_}
}
