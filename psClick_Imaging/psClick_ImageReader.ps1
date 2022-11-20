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
    #3
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][Alias("Image")]
        $Path
        ,
        [Parameter(Mandatory,Position=1)]
        $Base
        ,
        [Parameter(Position=2)][ValidateRange(0, 100)]
        $Accuracy = 0
        ,
        [Parameter(Position=3)][ValidateRange(0, 100)]
        $UseIntellect = -1
    )
    
    if($Path -is [Drawing.Image]){
        $result = [psClick.Readtext]::Recognize(
            $Path, 
            $Base.config.ScrollBarFilter,
            $Base.Config.ScrollBarR,
            $Base.Config.ScrollBarG,
            $Base.Config.ScrollBarB,
            $Base.Config.CheckSmoothing,
            $Base.Config.ScrollSmoothingLevel,
            $Base.Config.ScrollSmoothingGaus,
            $Base.Config.ScrollSmoothingFilter,
            $Base.Config.CheckDeleteLineHorizontal,
            $Base.Config.ScrollDeleteLineHorizontal,
            $Base.Config.CheckDeleteLineVertical,
            $Base.Config.ScrollDeleteLineVertical,
            $Base.Config.CheckRemoveNoise,
            $Base.Config.ScrollRemoveNoise,
            $Base.Config.CheckRemoveNoiseLineHorizontal,
            $Base.Config.ScrollRemoveNoiseHorizontal,
            $Base.Config.CheckRemoveNoiseVertical,
            $Base.Config.ScrollRemoveNoiseVertical,
            $Base.Config.Inversion,
            $Base.Config.TypeRus,
            $Base.Config.TypeEn,
            $Base.Config.TypeNum,
            $Base.Config.TypeOther,
            $Base.Config.CheckTextDeviation,
            $Base.Config.CheckFonDeviation,
            $Base.Config.ScrollTextDeviation,
            $Base.Config.ScrollFonDeviation,
            $Base.Config.CheckIntellect,
            $Base.Config.ScrollIntellect,
            $Base.Config.txtColors.ForEach({"0x$_"}), 
            $Base.Config.bgColors.ForEach({"0x$_"}), 
            $Base.Base
        )
    }
    else{
        $img = Get-Image -Path $path
        $result = [psClick.Readtext]::Recognize(
            $img, 
            $Base.Config.ScrollBarFilter,
            $Base.Config.ScrollBarR,
            $Base.Config.ScrollBarG,
            $Base.Config.ScrollBarB,
            $Base.Config.CheckSmoothing,
            $Base.Config.ScrollSmoothingLevel,
            $Base.Config.ScrollSmoothingGaus,
            $Base.Config.ScrollSmoothingFilter,
            $Base.Config.CheckDeleteLineHorizontal,
            $Base.Config.ScrollDeleteLineHorizontal,
            $Base.Config.CheckDeleteLineVertical,
            $Base.Config.ScrollDeleteLineVertical,
            $Base.Config.CheckRemoveNoise,
            $Base.Config.ScrollRemoveNoise,
            $Base.Config.CheckRemoveNoiseLineHorizontal,
            $Base.Config.ScrollRemoveNoiseHorizontal,
            $Base.Config.CheckRemoveNoiseVertical,
            $Base.Config.ScrollRemoveNoiseVertical,
            $Base.Config.Inversion,
            $Base.Config.TypeRus,
            $Base.Config.TypeEn,
            $Base.Config.TypeNum,
            $Base.Config.TypeOther,
            $Base.Config.CheckTextDeviation,
            $Base.Config.CheckFonDeviation,
            $Base.Config.ScrollTextDeviation,
            $Base.Config.ScrollFonDeviation,
            $Base.Config.CheckIntellect,
            $Base.Config.ScrollIntellect,
            $Base.Config.txtColors.ForEach({"0x$_"}), 
            $Base.Config.bgColors.ForEach({"0x$_"}), 
            $Base.Base
        )
        $img.Dispose()
    }
     
    $result = [PSCustomObject]@{
        Symbols = $result
        Text = [Regex]::Replace(
            [psClick.Readtext]::SymbolsToString($result, $Base.Config.SpaceSize), 
            "^[`r`n]+", '', 
            [Text.RegularExpressions.RegexOptions]::Multiline
        )
        ImageOutput = [psClick.Readtext]::Output
    }
  

     
        
     

    if ($UseIntellect -ne -1)
    {     
        if($Path -is [Drawing.Image]){
            $img = Cut-Image -Image $Path -StartPos 0, 0 -Size $Path.Size -New
        }
        else{
            $img = Get-Image -Path $Path 
        }


        $LastValueIntellect = $Base.Config.CheckIntellect
        $Base.Config.CheckIntellect = 1 
              
        for ($i = 0; $i -lt $result.Symbols.Count; $i++){         
            if ($result.Symbols.Rectangle.Size.Width[$i] -eq 0 -or $result.Symbols.Rectangle.Size.Height[$i] -eq 0){continue}
                                    
            if($result.Symbols.Percent[$i] -le $UseIntellect / 100)
            {                                                                                      
                $img2 = Cut-Image -Image $img -rect $result.Symbols.Rectangle[$i] -New               
                $tmp = [psClick.Readtext]::Recognize(
                    $img2, 
                    $Base.config.ScrollBarFilter,
                    $Base.Config.ScrollBarR,
                    $Base.Config.ScrollBarG,
                    $Base.Config.ScrollBarB,
                    $Base.Config.CheckSmoothing,
                    $Base.Config.ScrollSmoothingLevel,
                    $Base.Config.ScrollSmoothingGaus,
                    $Base.Config.ScrollSmoothingFilter,
                    $Base.Config.CheckDeleteLineHorizontal,
                    $Base.Config.ScrollDeleteLineHorizontal,
                    $Base.Config.CheckDeleteLineVertical,
                    $Base.Config.ScrollDeleteLineVertical,
                    $Base.Config.CheckRemoveNoise,
                    $Base.Config.ScrollRemoveNoise,
                    $Base.Config.CheckRemoveNoiseLineHorizontal,
                    $Base.Config.ScrollRemoveNoiseHorizontal,
                    $Base.Config.CheckRemoveNoiseVertical,
                    $Base.Config.ScrollRemoveNoiseVertical,
                    $Base.Config.Inversion,
                    $Base.Config.TypeRus,
                    $Base.Config.TypeEn,
                    $Base.Config.TypeNum,
                    $Base.Config.TypeOther,
                    $Base.Config.CheckTextDeviation,
                    $Base.Config.CheckFonDeviation,
                    $Base.Config.ScrollTextDeviation,
                    $Base.Config.ScrollFonDeviation,
                    $Base.Config.CheckIntellect,
                    $Base.Config.ScrollIntellect,
                    $Base.Config.txtColors.ForEach({"0x$_"}), 
                    $Base.Config.bgColors.ForEach({"0x$_"}), 
                    $Base.Base
                )                                      
                $img2.Dispose()

                if($tmp.Count -eq 1){                                                     
                     if($tmp[0].Percent -ge $result.Symbols.Percent[$i]){  
                        $tmp[0].Rectangle.Location.Offset($result.Symbols.Rectangle.Location[$i]) 
                        $result.Symbols.RemoveAt($i)
                        $result.Symbols.Insert($i, $tmp[0])
                        $result.Text = $result.Text.Remove($i, 1)
                        $result.Text = $result.Text.Insert($i, $tmp[0].Symbol)
                    }                    
                }
                elseif($tmp.Count -eq 2){                   
                    if($tmp[0].Percent -ge $result.Symbols.Percent[$i] -and $tmp[1].Percent -ge $result.Symbols.Percent[$i]){   
                        $tmp[0].Rectangle.Offset($result.Symbols.Rectangle.Location[$i])                  
                        $tmp[1].Rectangle.Offset($result.Symbols.Rectangle.Location[$i])
                        $result.Symbols.RemoveAt($i)
                        $result.Symbols.Insert($i, $tmp[0])
                        $result.Symbols.Insert($i+1, $tmp[1])                        
                        $result.Text = $result.Text.Remove($i, 1)
                        $result.Text = $result.Text.Insert($i, $tmp[0].Symbol + $tmp[1].Symbol)
                    }                                
                }       
                                                        
            }
        }
        $img.Dispose()
        $Base.Config.CheckIntellect = $LastValueIntellect
    }
    
    if($Accuracy -gt 0){
        for($i=$result.Symbols.Count-1; $i -ge 0; $i--)
        {
            if($result.Symbols.Percent[$i] -lt $Accuracy/100)
            {
                $result.Symbols.RemoveAt($i)
                $result.Text = $result.Text.Remove($i, 1)
            }
        }
    }    
    $result
}