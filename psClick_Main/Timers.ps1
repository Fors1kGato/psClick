function Start-timer
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0)]
        [String]$Name
        ,
        [Parameter(Mandatory, Position = 1)]
        [UInt64]$Interval
        ,
        [Parameter(Mandatory, Position = 2)]
        [Scriptblock]$Action
    )
    if(Get-EventSubscriber $Name -ea 0){
        Write-Warning "Такое имя для таймера уже использовалось"
        $name = [regex]::new("_?\d*$").Replace(
            $name,     
            {
                [int]$c = "$args"-replace"_"
                $c++
                "_$c"
            },
            1
        )
        Write-Host "Будет использовано имя $name" -ForegroundColor Red
    }
    if(!(gv timers -Scope global -ea 0)){
        @{}|nv timers -Option Constant -Scope global
    }
    $timer = [System.Timers.Timer]::new($Interval)
    $Global:timers.$name = $timer

    Register-ObjectEvent -SourceIdentifier $name -InputObject $Global:timers.$name -EventName Elapsed  -Action $Action|Out-Null
    
    $timer.Start()
}

function Delete-Timer
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0)]
        [String]$name
    )
    if(!$Global:timers.ContainsKey($name)){
        return
    }
    $event = (Get-EventSubscriber $name)
    $event.SourceObject.Stop()
    $event.SourceObject.Dispose()
    $event.Action.Dispose()
    $Global:timers.Remove($name)
}

function Get-Timer
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0,ParameterSetName = "Name")]
        [String]$Name
        ,
        [Parameter(Mandatory, Position = 0,ParameterSetName = "All")]
        [Switch]$All
    )
    if($Name){
        if($Global:timers.ContainsKey($name)){
            $Name
        }
    }
    else{
        $Global:timers.Keys
    }
}