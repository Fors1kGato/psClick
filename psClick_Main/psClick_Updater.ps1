&{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    $url   = "api.github.com/repos/Fors1kGato/psClick/git/trees/main?recursive=1"
    $psClickPath = [Environment]::GetFolderPath("MyDocuments") + "\psClick"
    $tree  = (Irm $url -useb).tree
    $files = $tree|?{$_.type -ne "tree"}
    $tr    = (gci -file -Recurse $psClickPath).FullName|ForEach{
        $bytes =  [IO.File]::ReadAllBytes($_)
        $blob  = [Text.Encoding]::UTF8.GetBytes("blob $($bytes.Count)`0") + $bytes
        $sha1  = [Security.Cryptography.SHA1Managed]::Create()
        $hash  = $sha1.ComputeHash($blob)
        $hashString = [BitConverter]::ToString($hash).Replace('-','').ToLower()
        [PSCustomObject]@{
            Path = $_.replace("$psClickPath\","").replace("\","/")
            sha = $hashString
        }
        #sleep 50
    }

    ForEach($f in $files){
        $check = $tr.sha.Contains($f.sha)
        if($f.path -eq 'psClick_Main/psClick_Updater.ps1'){continue}
        if(!$check){
            $Path = (Join-path $psClickPath $f.path)
            try{$p = Ni -ea Stop $Path -Force}
            catch{
                Write-Warning (
                    "Не удалось обновить "+$Path+
                    "`nЗакройте программу, которая использует файл в данный момент, и повторите попытку"
                )
                $er = $true
            }
            Irm -useb "github.com/Fors1kGato/psClick/raw/main/$($f.path)" -OutFile $p|out-null
        }
    }
    $HDA = @{
        Path  = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
        Name  = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe"
        Value = "~ HIGHDPIAWARE"
    }
    New-ItemProperty @HDA -Force|Out-Null
    (gci -Recurse $psClickPath -ex "token.ps1" ).FullName.replace("$psClickPath\","").replace("\","/")|
    ?{$tree.path -notcontains $_}|%{
        ri (Join-Path $psClickPath $_) -Recurse -ea 0
    }
    (Get-Command -Module psClick*).Module|ForEach{Remove-Module $_}
    sal ngen (Join-Path ([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe)
    $psClickPath = [Environment]::GetFolderPath("MyDocuments") + "\psClick"
    (gci $psClickPath -rec *.dll).FullName|%{
        #ngen uninstall $_|Out-Null
        ngen install $_ |Out-Null
    }
    if(!$er){Write-Host "Обновление завершено!" -Fore green}
}
