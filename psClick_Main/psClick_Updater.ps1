cls
$Host.UI.RawUI.WindowTitle="psClick© Updater"
$bufSize = $host.ui.RawUI.BufferSize
$winSize = $host.ui.RawUI.WindowSize
$bufSize.Height = 3000
$bufSize.Width  = 120
$winSize.Width  = 120
$winSize.Height = 30
$host.ui.RawUI.BufferSize = $bufSize
$host.ui.RawUI.WindowSize = $winSize
    
write-host "






                                             ###############################
                                             ##          psClick          ##
                                             ##            by             ##
                                             ##          Fors1k           ##
                                             ##           ****            ##
                                             ##     https://psClick.ru    ##
                                             ###############################
                                                 Выполняется  обновление
    " -ForegroundColor cyan;
if(!$env:psClick){
    [Environment]::SetEnvironmentVariable("psClick", 
    [Environment]::GetFolderPath("MyDocuments") + 
    "\psClick", [EnvironmentVariableTarget]::User)
    $Env:psClick = [Environment]::GetFolderPath("MyDocuments") + 
    "\psClick"
}
$vc = Test-Path "$env:windir\System32\vcruntime140d.dll"
if(!$vc -and ![Environment]::GetEnvironmentVariable("Path", "User").Contains("$env:psClick\psClick_Main\x32")){
    [Environment]::SetEnvironmentVariable("Path",
    [Environment]::GetEnvironmentVariable("Path","User")+
    [IO.Path]::PathSeparator+"$env:psClick\psClick_Main\x32","User")
}
if(!$vc -and ![Environment]::GetEnvironmentVariable("Path", "User").Contains("$env:psClick\psClick_Main\x64")){
    [Environment]::SetEnvironmentVariable("Path",
    [Environment]::GetEnvironmentVariable("Path","User")+
    [IO.Path]::PathSeparator+"$env:psClick\psClick_Main\x64","User")
}
[Net.ServicePointManager]::SecurityProtocol='SSL3,TLS,TLS11,TLS12'
$url   = "api.github.com/repos/Fors1kGato/psClick/git/trees/main?recursive=1"
$tree  = (Irm $url -useb).tree
$files = $tree|?{$_.type -ne "tree"}
$tr    = (gci -file -Recurse $env:psClick).FullName|ForEach{
    $bytes =  [IO.File]::ReadAllBytes($_)
    $blob  = [Text.Encoding]::UTF8.GetBytes("blob $($bytes.Count)`0") + $bytes
    $sha1  = [Security.Cryptography.SHA1Managed]::Create()
    $hash  = $sha1.ComputeHash($blob)
    $hashString = [BitConverter]::ToString($hash).Replace('-','').ToLower()
    [PSCustomObject]@{
        Path = $_.replace("$env:psClick\","").replace("\","/")
        sha = $hashString
    }
    #sleep 50
}

ForEach($f in $files){
    $check = $tr.sha.Contains($f.sha)
    if($f.path -eq 'psClick_Main/psClick_Updater.ps1'){continue}
    if($vc -and $t.path -like "psClick_Main/x*/*d.dll"){continue}
    if(!$check){
        $Path = (Join-path $env:psClick $f.path)
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

$toProfile = @'
#region psClick
#
if($psISE){
    [Void]$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add(
        'Запустить psClick',
        {Start-Psclick},
        $null
    )
}
#
#endregion

'@

$pPath = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
$pfile = (gc $pPath -raw -ea 0) -as [String]
$pfile -replace "(\#region\ psClick[\s\S]+?\#endregion`r?`n|^)", $toProfile|Out-File $pPath

$params = @{
    Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\SideBySide'
    Name = 'PreferExternalManifest'
    PropertyType = 'DWORD'
    Value = 1
    ErrorAction = 'Stop'
}
New-ItemProperty @params -Force| Out-Null
(gci -Recurse $env:psClick|Where{!$_.FullName.Contains("psClick_UserData")}).FullName.Replace("$env:psClick\","").replace("\","/")|
?{$tree.path -notcontains $_}|%{
    ri (Join-Path $env:psClick $_) -Recurse -ea 0
}
Remove-Module -Name psClick*
sal ngen (Join-Path ([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe)
(gci $env:psClick -rec *.dll).FullName|%{ngen install $_ |Out-Null}
if(!$er){
    cls;write-host "






                                             ###############################
                                             ##          psClick          ##
                                             ##            by             ##
                                             ##          Fors1k           ##
                                             ##           ****            ##
                                             ##     https://psClick.ru    ##
                                             ###############################
                                                         Готово!
    " -ForegroundColor Green
}
