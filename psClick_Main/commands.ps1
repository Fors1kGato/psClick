function Publish-Image
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory,Position=0)]
        $Image
    )
    $formats = ".png",".jpg",".jpeg",".gif",".jfif",".pjpeg",".pjp"
    if($Image -isnot [Drawing.Image] -and !(Test-Path $Image))
    {throw "Укажите путь существующего файла"}
    if((Get-Item $Image).Extension -notin $formats)
    {throw "Выберите файл допустимого разрешения: `n$formats"}
    if($Image -is [Drawing.Image]){
        $stream = [IO.MemoryStream]::new()
        $Image.Save($stream, [Drawing.Imaging.ImageFormat]::Png)
        $stream.Position = 0
    }
    else{
        $stream = [IO.File]::OpenRead($Image)
    }
    try{
        $result = [psClick.Net]::UploadMedia($stream)
        if($result.Result){$result = $result.Result}
        $stream.Close()
        return $result
    }
    catch{
        $stream.Close()
        throw $_
    }
}

function Get-ClipboardHistory{
    if(!('System.WindowsRuntimeSystemExtensions' -as [Type])){
        [Void][Reflection.Assembly]::LoadWithPartialName("System.Runtime.WindowsRuntime")
    }
    if(!('Windows.ApplicationModel.DataTransfer.Clipboard' -as [Type])){
        [Void][Windows.ApplicationModel.DataTransfer.Clipboard,Windows.ApplicationModel.DataTransfer,ContentType=WindowsRuntime]
    }
    Function Await($WinRtTask, $ResultType){
        ([WindowsRuntimeSystemExtensions].GetMethods()|Where{ 
            $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and 
            $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
        })[0].MakeGenericMethod($ResultType).Invoke($null, @($WinRtTask))|SV netTask
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }

    $cbHistory  = [Collections.Generic.List[String]]::new()
    $asyncTask  = [Windows.ApplicationModel.DataTransfer.Clipboard]::GetHistoryItemsAsync()
    $resultType = [Windows.ApplicationModel.DataTransfer.ClipboardHistoryItemsResult]
    $res = Await $asyncTask $resultType

    ForEach($item in $res.Items){
        $cbHistory.Add((Await $item.Content.GetTextAsync() ([String])))
    }
    return ,$cbHistory
}

function Start-PlaySound
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0)]
        [ValidateScript({Test-Path $_})]
        [String]$Path
        ,
        [ValidateRange(0.0, 1.0)]
        [Double]$Volume = 0.5
        ,
        [Switch]$WaitEnd
    )

    $mediaPlayer = [Windows.Media.MediaPlayer]::new()
    $mediaPlayer.Volume = $Volume 
    $mediaPlayer.open($Path)

    # ожидание когда файл загрузится
    while(!($mediaPlayer.NaturalDuration.TimeSpan)){
        sleep -m 10
    }
    $Duration = [Math]::Round($mediaPlayer.NaturalDuration.TimeSpan.TotalMilliseconds)

    if($WaitEnd){  # ждать когда воспроизведение завершится
        $mediaPlayer.Play()
        Sleep -m $Duration
        $mediaPlayer.Close()
    }
    else{
        $mediaPlayer.Play()
    }
}

function Test-AdminRole
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
    IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

Function Get-LevenshteinDistance 
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    param(
        [Parameter(Mandatory)]
        [String]$String1,
        [Parameter(Mandatory)]
        [String]$String2
    )
    [psClick.Commands]::CalcLevenshteinDistance($String1, $String2)
}

function Send-Message
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    param(
        [IntPtr]$hWnd,
        $Msg,
        $wParam = 0,
        $lParam = 0,
        $rType
    )
    Invoke-WinApi -Return $rType -Override SendMessage(
        $hWnd,
        $Msg,
        $wParam,
        $lParam
    )
}

function Post-Message
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    param(
        [IntPtr]$hWnd,
        $Msg,
        $wParam = 0,
        $lParam = 0,
        $rType
    )
    Invoke-WinApi -Return $rType -Override PostMessage(
        $hWnd,
        $Msg,
        $wParam,
        $lParam
    )
}

function Pausable
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        $key = "Escape"
    )
    if(Get-EventSubscriber -ea 0 -SourceIdentifier pausable){return}
    $timer = [System.Timers.Timer]::new(100)
    $mwh = (Get-Process -id $pid).MainWindowHandle
    $timerAction = [scriptblock]::Create("
        
        `$playPause = {(Get-KeyState $key) -and (Get-ForegroundWindow) -eq $mwh}

        if(.`$playPause){
            Write-Warning 'Скрипт приостановлен'
            sleep -m 400
            while(!(.`$playPause)){
                sleep -m 4
            }
            Write-Host 'Работа скрипта возобновлена' -ForegroundColor DarkGreen
            sleep -m 400
        }
    ")

    Register-ObjectEvent -SourceIdentifier pausable -InputObject $timer -EventName Elapsed -Action $timerAction|Out-Null 
    Get-KeyState $key|Out-Null
    $timer.Start()
}

function Pause-Script
{
    #.COMPONENT
    #2.1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory, Position=0)]
        [UInt32[]]$Timeout
    )
    if($Timeout.Count -gt 1){ 
        [Int64]$Timeout = Get-Random -Minimum $Timeout[0] -Maximum $Timeout[1] 
    }
    $timer = [Diagnostics.Stopwatch]::StartNew()
    while($timer.ElapsedMilliseconds -lt $Timeout[0]-5){ 
        Start-Sleep -m 2
    }
    $timer.Stop()
}

function Stop-Script{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    Break "ThisScript!"
}

function Start-TimeWatcher
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    [Diagnostics.Stopwatch]::StartNew()
}

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
    if($Encoding-eq"ANSI"){$codaPage = [System.Text.Encoding]::GetEncoding(1251)}
    ,$codaPage.GetBytes($text)
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
    if($Encoding-eq"ANSI"){$codaPage = [System.Text.Encoding]::GetEncoding(1251)}
    $codaPage.GetString($Bytes)
}

function Change-Location{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [alias("cl")]Param(
        $Path
    )
    Set-Location $Path
    [Environment]::CurrentDirectory = $Path
}

function Uninstall-Psclick{
    split-path $psscriptroot|ri -force -rec -ea 0
}

function Show-FileDialog
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [String]$Title
        ,
        [String]$InitialDirectory = "$env:HOMEDRIVE\"
        ,
        [String]$Filter = "All Files (*.*)|*.*|Text Files (*.txt)|*.txt"
        ,
        [Switch]$Name
        ,
        [Parameter(ParameterSetName = 'Open')]
        [Switch]$MultiSelect
        ,
        [Parameter(ParameterSetName = 'Save')]
        [String]$DefaultExt
        ,
        [Parameter(Mandatory,ParameterSetName = 'Save')]
        [Switch]$Save
        ,
        [Parameter(ParameterSetName = 'Save')]
        [Switch]$OverwritePrompt       
    )

    if($Save){
        $Dialog = [System.Windows.Forms.SaveFileDialog]::new()
        $Dialog.OverwritePrompt = $OverwritePrompt
        $Dialog.DefaultExt = $DefaultExt
    }
    else{
        $Dialog = [System.Windows.Forms.OpenFileDialog]::new()
        $Dialog.Multiselect = $Multiselect
    }
    $Dialog.Title = $Title
    $Dialog.InitialDirectory= $InitialDirectory
    $Dialog.Filter = $Filter

    $result = $Dialog.ShowDialog()
    $Dialog.Dispose()
    if($result -ne "OK"){ return } 
      
    if($Save){
        if($Name){
            return ($Dialog.FileName|Split-Path -Leaf)
        }
        else{
            return $Dialog.FileName
        }
    }
    if($Name){
        return $Dialog.SafeFileNames
    }
    else{
        return $Dialog.FileNames
    }
}

function Show-FolderDialog
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    Param(
        [ValidateSet('AdminTools','ApplicationData','CDBurning','CommonAdminTools','CommonApplicationData','CommonDesktopDirectory','CommonDocuments','CommonMusic','CommonOemLinks','CommonPictures','CommonProgramFiles','CommonProgramFilesX86','CommonPrograms','CommonStartMenu','CommonStartup','CommonTemplates','CommonVideos','Cookies','Desktop','DesktopDirectory','Favorites','Fonts','History','InternetCache','LocalApplicationData','LocalizedResources','MyComputer','MyDocuments','MyMusic','MyPictures','MyVideos','NetworkShortcuts','PrinterShortcuts','ProgramFiles','ProgramFilesX86','Programs','Recent','Resources','SendTo','StartMenu','Startup','System','SystemX86','Templates','UserProfile','Windows')]
        [String]$RootFolder = "Desktop",
        [String]$Description    
    )

    $Dialog = [System.Windows.Forms.FolderBrowserDialog]::new()
    $Dialog.RootFolder  = $RootFolder
    $Dialog.Description = $Description
    $result = $Dialog.ShowDialog([Windows.Forms.Form]@{Topmost = $true;TopLevel = $true})
    $Dialog.Dispose()
    if($result -eq "OK"){ 
        $Dialog.SelectedPath
    }
}

function Start-Psclick
{ 
    #.COMPONENT
    #2.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    try{
        Start-ScheduledTask "Start_psClick" -ErrorAction Stop
    }
    catch{
        $Action = New-ScheduledTaskAction -Execute "$psscriptroot\psCLick.exe" -WorkingDirectory $psscriptroot
        $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
        Register-ScheduledTask -TaskName "Start_psClick" -Action $Action -Settings $Settings|Out-Null
    }
    finally{
        Start-ScheduledTask "Start_psClick"
    }
}

function Invoke-Ternary{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [Alias('??')]PARAM(
    [parameter(ValueFromPipeline, Mandatory)]
    [Boolean]$Bool,
    [parameter(Position = 0,Mandatory=$true)]
    $TrueV,
    [parameter(Position = 1,Mandatory=$true)]
    [ValidatePattern(":")]$S,
    [parameter(Position = 2,Mandatory=$true)]
    $FalseV
    )if($Bool){$val=$TrueV}else{$val=$FalseV}
    if($val-is[ScriptBlock]){&$val}else{$val}
}