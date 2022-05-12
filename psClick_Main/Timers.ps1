function Start-Timer
{
    #.COMPONENT
    #3
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
        [ScriptBlock]$Action
    )
    if($Global:timers.$name){
        $err = "Таймер с таким именем уже запущен"
        throw $err
    }
    if(!(gv timers -Scope global -ea 0)){@{}|nv timers -Option Constant -Scope global}
    $removeTimer = [ScriptBlock]::Create("`$Global:timers.Remove('$name');Unregister-Event -SourceIdentifier $name")
    $Action = [ScriptBlock]::Create("if(`$Global:timers.$name.timer.Enabled){`$Global:timers.$name.event=`$event;`n$Action}")
    $Global:timers.$name = @{Timer = [System.Timers.Timer]::new($Interval)}

    Unregister-Event -SourceIdentifier "kill$name" -ea 0
    Register-ObjectEvent -SourceIdentifier $name -InputObject $Global:timers.$name.Timer -EventName Elapsed  -Action $Action|Out-Null
    Register-ObjectEvent -SourceIdentifier "kill$name" -InputObject $Global:timers.$name.Timer -EventName Disposed -Action $removeTimer|Out-Null
    $Global:timers.$name.Timer.Start()
}

function Delete-Timer
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0)]
        [String]$Name
        ,
        [Switch]$Force
    )
    if(!$Global:timers.ContainsKey($name)){
        return
    }
    $Global:timers.$name.Timer.Dispose()
    $Global:timers.$name.Remove('Timer')
    if($Force){
        $Global:timers.$name.event.messagedata.foo.Enabled = $false
    }
}

function Get-Timer
{
    #.COMPONENT
    #2
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
        [bool]$Global:timers.$name.Timer
    }
    else{
        $Global:timers.Keys
    }
}