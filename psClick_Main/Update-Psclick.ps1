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
    $tr    = (gci -file -Recurse "$env:USERPROFILE\Documents\psClick").FullName|ForEach{
        $bytes =  [IO.File]::ReadAllBytes($_)
        $blob  = [Text.Encoding]::UTF8.GetBytes("blob $($bytes.Count)`0") + $bytes
        $sha1  = [Security.Cryptography.SHA1Managed]::Create()
        $hash  = $sha1.ComputeHash($blob)
        $hashString = [BitConverter]::ToString($hash).Replace('-','').ToLower()
        [PSCustomObject]@{
            Path = $_.replace("$env:USERPROFILE\Documents\psClick\","").replace("\","/")
            sha = $hashString
        }
        #sleep 50
    }

    $files|%{
        $check = $tr.sha.Contains($_.sha)
        if(!$check){
            $Path = (Join-path "$env:USERPROFILE\Documents\psClick" $_.path)
            try{$p = Ni -ea Stop $Path -Force}
            catch{
                Write-Warning (
                    "Не удалось обновить "+$Path+
                    "`nЗакройте программу, которая использует файл в данный момент, и повторите попытку"
                )
                $er = $true
            }
            Irm -useb "github.com/Fors1kGato/psClick/raw/main/$($_.path)" -OutFile $p|out-null
        }
    }

    (gci -Recurse "$env:USERPROFILE\Documents\psClick").FullName.replace("$env:USERPROFILE\Documents\psClick\","").replace("\","/")|
    ?{$tree.path -notcontains $_}|%{
        ri (Join-Path "$env:USERPROFILE\Documents\psClick" $_) -Recurse -ea 0
    }
    (Get-Command -Module psClick*).Module|ForEach{Remove-Module $_}
    if(!$er){Write-Host "Обновление завершено!" -Fore green}
}
