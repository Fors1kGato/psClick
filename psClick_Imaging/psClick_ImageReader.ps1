function Get-SymbolsBase 
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    [CmdletBinding()]Param()
    DynamicParam {
        $attribute = [Management.Automation.ParameterAttribute]@{Mandatory = $true;Position = 1}
        $collection = [Collections.ObjectModel.Collection[System.Attribute]]::new()
        $collection.Add($attribute)

        $validationSet = [String[]](Get-ChildItem ([Environment]::GetFolderPath('MyDocuments')+'\psClick\psClick_UserData\ImageReader_Data')|Select BaseName -Unique).BaseName
        $collection.Add(([Management.Automation.ValidateSetAttribute]::new($validationSet)))  

        $param = [Management.Automation.RuntimeDefinedParameter]::new('Name', [string], $collection)
        $dictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
        $dictionary.Add('Name', $param)  
        return $dictionary
    }
    end{
        try{
            $Base = $PSBoundParameters.Name
            $BaseSymbol = [psClick.Readtext]::LoadSymbolBase(([Environment]::GetFolderPath('MyDocuments')+"\psClick\psClick_UserData\ImageReader_Data\$Base.pssb"))
            $cfg = Get-Content ([Environment]::GetFolderPath('MyDocuments')+"\psClick\psClick_UserData\ImageReader_Data\$Base.cfg")|ConvertFrom-Json
        }
        catch{
            throw $_
        }
        [PSCustomObject]@{
            Name   = $Base
            Base   = $BaseSymbol
            Config = $cfg
        }
    }
}

function Recognize-Text 
{
    #.COMPONENT
    #1.2
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][Alias("Image")]
        $Path,
        [Parameter(Mandatory,Position=1)]
        $Base
    )
    if($Path -is [Drawing.Image]){
        $result = [psClick.Readtext]::Recognize(
            $Path, 
            $Base.Config.Settings, 
            $Base.Config.txtColors.ForEach({"0x$_"}), 
            $Base.Config.bgColors.ForEach({"0x$_"}), 
            $Base.Base
        )
    }
    else{
        $img = Get-Image -Path $path
        $result = [psClick.Readtext]::Recognize(
            $img, 
            $Base.Config.Settings, 
            $Base.Config.txtColors.ForEach({"0x$_"}), 
            $Base.Config.bgColors.ForEach({"0x$_"}), 
            $Base.Base
        )
        $img.Dispose()
    }
    [PSCustomObject]@{
        Symbols     = $result
        Text        = [psClick.Readtext]::SymbolsToString($result, $Base.Config.SpaceSize)
        ImageOutput = [psClick.Readtext]::Output
    }
}