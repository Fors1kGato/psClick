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

function Pause-Script{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory)]
        [UInt64]$Timeout
    )
    $time = (Get-DAte).AddMilliseconds($timeout)
    while((Get-Date) -lt $time){ 
        Start-Sleep -m 2
    }
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
    if($Encoding-eq"ANSI"){$codaPage = [System.Text.Encoding]::GetEncoding('windows-1251')}
    $codaPage.GetString($Bytes)
}

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

function Invoke-Ternary{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [alias('??')]PARAM(
    [parameter(ValueFromPipeline, Mandatory)]
    [Boolean]$bool,
    [parameter(Position = 0,Mandatory=$true)]
    $trueV,
    [parameter(Position = 1,Mandatory=$true)]
    [ValidatePattern(":")]$s,
    [parameter(Position = 2,Mandatory=$true)]
    $falseV
    )if($bool){$val=$trueV}else{$val=$falseV}
    if($val-is[scriptblock]){&$val}else{$val}
}