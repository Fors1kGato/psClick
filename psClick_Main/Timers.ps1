function Start-timer
{
    #.COMPONENT
    #2
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
    if($Global:timers.$name){
        $err = "Таймер с таким именем уже существует"
        throw $err
    }
    if(!(gv timers -Scope global -ea 0)){
        @{}|nv timers -Option Constant -Scope global
    }
    $Action = [scriptblock]::Create("if(`$Global:timers.$name.Enabled){$Action}")
    $timer = [System.Timers.Timer]::new($Interval)
    $Global:timers.$name = $timer

    $removeTimer = [scriptblock]::Create("
        Unregister-Event -SourceIdentifier $name
    ")
    Unregister-Event -SourceIdentifier "kill$name" -ea 0
    Register-ObjectEvent -SourceIdentifier $name -InputObject $Global:timers.$name -EventName Elapsed  -Action $Action|Out-Null
    Register-ObjectEvent -SourceIdentifier "kill$name" -InputObject $Global:timers.$name -EventName Disposed -Action $removeTimer|Out-Null
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
    $Global:timers.$name.Dispose()
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