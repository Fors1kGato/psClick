function Update-Psclick{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    $url   = "api.github.com/repos/Fors1kGato/psClick/git/trees/main?recursive=1"
    $tree  = (Irm $url -useb).tree
    $files = $tree|?{$_.type -ne "tree"}
    $tr = gc "$env:USERPROFILE\Documents\psClick\psClick.sha"|ConvertFrom-Json

    $files|%{
        $check = $tr.sha.Contains($_.sha)
        if(!$check){
            Irm -useb "github.com/Fors1kGato/psClick/raw/main/$($_.path)" -OutFile `
            (ni (join-path "$env:USERPROFILE\Documents\psClick" $_.path) -Force)
        }
    }

    (gci -Recurse "$env:USERPROFILE\Documents\psClick").FullName.replace("$env:USERPROFILE\Documents\psClick\","").replace("\","/")|
    ?{$tree.path -notcontains $_}|%{
        ri (Join-Path "$env:USERPROFILE\Documents\psClick" $_) -Recurse -ea 0
    }
    $tree|select path, sha|ConvertTo-Json|out-file "$env:USERPROFILE\Documents\psClick\psClick.sha"
    (Get-Command -Module psClick*).Module|ForEach{Remove-Module $_}
}