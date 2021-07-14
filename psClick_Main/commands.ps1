function Get-Bytes{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory=$true ,Position=0)]
        [String]$Text
        ,
        [Parameter(Mandatory=$false,Position=1)]
        [ValidateSet('UTF8','ANSI','ASCII','BigEndianUnicode','Unicode','UTF32')]
        [String]$Encoding = "UTF8"
    )
    $codaPage = [System.Text.Encoding]::$Encoding
    if($Encoding-eq"ANSI"){$codaPage = [System.Text.Encoding]::GetEncoding('windows-1251')}
    $codaPage.GetBytes($text)
}

function Get-String{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory=$true ,Position=0)]
        [Byte[]]$Bytes
        ,
        [ValidateSet('UTF8','ANSI','ASCII','BigEndianUnicode','Unicode','UTF32')]
        [String]$Encoding = "UTF8"
    )
    $codaPage = [System.Text.Encoding]::$Encoding
    if($Encoding-eq"ANSI"){$codaPage = [System.Text.Encoding]::GetEncoding('windows-1251')}
    $codaPage.GetString($Bytes)
}