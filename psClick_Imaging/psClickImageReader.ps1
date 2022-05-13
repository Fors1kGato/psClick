function Start-psClickImageReader
{ 
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    start "$psscriptroot\psClick — ImageReader.exe" -WorkingDirectory $psscriptroot
}

function Recognize-Text 
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][Alias("Image")]
        $Path
    )
    DynamicParam {
        $attribute = [Management.Automation.ParameterAttribute]@{Mandatory = $true;Position = 1}
        $collection = [Collections.ObjectModel.Collection[System.Attribute]]::new()
        $collection.Add($attribute)

        $validationSet = [String[]](Get-ChildItem "$PSScriptRoot\ImageReader_Data"|Select BaseName -Unique).BaseName
        $collection.Add(([Management.Automation.ValidateSetAttribute]::new($validationSet)))  

        $param = [Management.Automation.RuntimeDefinedParameter]::new('Base', [string], $collection)
        $dictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
        $dictionary.Add('Base', $param)  
        return $dictionary
    }
    end{
        try{
            $Base = $PSBoundParameters.Base
            $BaseSymbol = [psClick.Readtext]::LoadSymbolBase("$PSScriptRoot\ImageReader_Data\$Base.pssb")
            $cfg = Get-Content "$PSScriptRoot\ImageReader_Data\$Base.cnfg"|ConvertFrom-Json
        }
        catch{
            throw $_
        }
        if($Path -is [System.Drawing.Image]){
            $result = [psClick.Readtext]::Recognize($Path, $cfg.Settings, $cfg.txtColors, $cfg.bgColors, $BaseSymbol)
            $Path.Dispose()
        }
        else{
            $img = Get-Image -Path $path
            $result = [psClick.Readtext]::Recognize($img, $cfg.Settings, $cfg.txtColors, $cfg.bgColors, $BaseSymbol)
        }
        [PSCustomObject]@{
            Symbols = $result
            Text    = [psClick.Readtext]::SymbolsToString($result, $cfg.SpaceSize)
            ImageR  = [psClick.Readtext]::Output
        }
    }
}