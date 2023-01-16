function Get-IniContent ($filePath){
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    $ini = @{}
    switch -regex -file $FilePath{
        '^\[(.+)\]' # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        '^(;.*)$' # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        }
        '(.+?)\s*=(.*)' # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}
function Out-IniFile($InputObject, $FilePath){
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    $outFile = New-Item -ItemType file -Path $Filepath -Force
    foreach ($i in $InputObject.keys){
        if (!($($InputObject[$i].GetType().Name) -eq "Hashtable")){
            #No Sections
            Add-Content -Path $outFile -Value "$i=$($InputObject[$i])"
        }
        else{
            #Sections
            Add-Content -Path $outFile -Value "[$i]"
            Foreach ($j in ($InputObject[$i].keys | Sort-Object)){
                if ($j -match "^Comment[\d]+") {
                    Add-Content -Path $outFile -Value "$($InputObject[$i][$j])"
                }
                else {
                    Add-Content -Path $outFile -Value "$j=$($InputObject[$i][$j])"
                }
            }
            Add-Content -Path $outFile -Value ""
        }
    }
} 
function Update-Psclick
{
    #.COMPONENT
    #3.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    [Net.ServicePointManager]::
    SecurityProtocol='SSL3,TLS,TLS11,TLS12'
    [System.Diagnostics.Process]::Start(@{
        FileName  = "powershell";Verb = "runas"
        Arguments = "[Net.ServicePointManager]::SecurityProtocol='SSL3,TLS,TLS11,TLS12';irm 'github.com/Fors1kGato/psClick/raw/main/psClick_Main/psClick_Updater.ps1'|iex;pause"
    }).WaitForExit();Remove-Module -Name psClick*
}
