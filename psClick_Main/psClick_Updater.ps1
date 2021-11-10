&{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    cls
    $bufSize = $host.ui.RawUI.BufferSize
    $winSize = $host.ui.RawUI.WindowSize
    $bufSize.Height = 3000
    $bufSize.Width  = 120
    $winSize.Width  = 120
    $winSize.Height = 30
    $host.ui.RawUI.BufferSize = $bufSize
    $host.ui.RawUI.WindowSize = $winSize
    $Host.UI.RawUI.WindowTitle="psClick© Updater"
    write-host '
                                             ###############################
                                             ##          psClick          ##
                                             ##            by             ##
                                             ##          Fors1k           ##
                                             ##           ****            ##
                                             ##     https://psClick.ru    ##
                                             ###############################
                                                     Идет обновление     
    ' -ForegroundColor cyan;
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
    "","_ise"|%{'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0" xmlns:asmv3="urn:schemas-microsoft-com:asm.v3">
      <asmv3:application>
        <asmv3:windowsSettings>
          <dpiAware xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">true</dpiAware>
          <dpiAwareness xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">PerMonitorV2</dpiAwareness>
        </asmv3:windowsSettings>
      </asmv3:application>
    </assembly>'|Out-File "C:\Windows\System32\WindowsPowerShell\v1.0\powershell$_.exe.manifest" -Encoding UTF8}

    $pPath = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
    $profile = (gc $pPath -raw -ea 0)-as [String]
    if(!$profile.Contains("Contains('ISE')")){
        "if(`$Host.Name.Contains('ISE')){
            [Void]`$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add(
                'Запустить psClick',
                {Start-Psclick},
                `$null
            )
        }
        $profile".Trim()|Out-File $pPath
    }
    $params = @{
        Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\SideBySide'
        Name = 'PreferExternalManifest'
        PropertyType = 'DWORD'
        Value = 1
        ErrorAction = 'Stop'
    }
    New-ItemProperty @params -Force| Out-Null
    (gci -Recurse $psClickPath -ex "token.ps1" ).FullName.replace("$psClickPath\","").replace("\","/")|
    ?{$tree.path -notcontains $_}|%{
        ri (Join-Path $psClickPath $_) -Recurse -ea 0
    }
    #(Get-Command -Module psClick*).Module|ForEach{Remove-Module $_}
    sal ngen (Join-Path ([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe)
    $psClickPath = [Environment]::GetFolderPath("MyDocuments") + "\psClick"
    (gci $psClickPath -rec *.dll).FullName|%{
        #ngen uninstall $_|Out-Null
        ngen install $_ |Out-Null
    }
    if(!$er){Write-Host "Обновление завершено!" -Fore green}
}
