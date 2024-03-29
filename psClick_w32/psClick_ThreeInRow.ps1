function Find-MovesThreeInRow
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0)]
        [char[,]]$Field
        ,
        [Switch]$WithoutRecursion
    )
    if($WithoutRecursion){
        [psClick.ThreeInRow]::FieldMove($Field, $false)
    }
    else{
        [psClick.ThreeInRow]::FieldMove($Field, $true)
    }
}


function Get-BestMove
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0)]
        $ListMoves
        ,
        [Parameter(Mandatory, Position = 1)]
        [ValidateSet("TotalItems", "MAxLengthInRow", "TotalItem", "Intersection", "Bottom")]
        [string]$Criteria
        ,
        [char]$Item = $null
    )

    if($Criteria-eq "TotalItem" -and !$Item){
        throw "Необходимо указать задать параметр Item"
    }

    if($Criteria -eq "TotalItems"){
        [psClick.ThreeInRow]::FindBestMove($ListMoves, 0, $null)
    }
    elseif($Criteria -eq "MAxLengthInRow"){
        [psClick.ThreeInRow]::FindBestMove($ListMoves, 1, $null)
    }
    elseif($Criteria -eq "TotalItem"){
        [psClick.ThreeInRow]::FindBestMove($ListMoves, 2, $Item)
    }
    elseif($Criteria -eq "Intersection"){
        [psClick.ThreeInRow]::FindBestMove($ListMoves, 3, $null)
    }
    else{
        [psClick.ThreeInRow]::FindBestMove($ListMoves, 4, $null)
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