function Find-MovesThreeInRow
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0)]
        [char[,]]$Field
    )

    [psClick.ThreeInRow]::FieldMove($Field)
}


function Get-BestMove
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0)]
        $ListMove
        ,
        [Parameter(Mandatory, Position = 1)]
        [ValidateSet("TotalItems", "MAxLengthInRow", "TotalItem")]
        [string]$Criteria
        ,
        [char]$Item = $null
    )

    if($Criteria-eq "TotalItem" -and !$Item){
        throw "Необходимо указать задать параметр Item"
    }

    if($Criteria -eq "TotalItems"){
        [psClick.ThreeInRow]::FindBestMove($ListMove, 0, $null)
    }
    elseif($Criteria -eq "MAxLengthInRow"){
        [psClick.ThreeInRow]::FindBestMove($ListMove, 1, $null)
    }
    else{
        [psClick.ThreeInRow]::FindBestMove($ListMove, 2, $Item)
    }
}


function Show-FieldConsole
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0)]
        [char[,]]$Field
    )

    [psClick.ThreeInRow]::FieldShowConsole($Field)
}