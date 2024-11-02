function Get-SymbolsBase 
{
    #.COMPONENT
    #1.3
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
            $cfg = Get-Content ([Environment]::GetFolderPath('MyDocuments')+"\psClick\psClick_UserData\ImageReader_Data\$Base.cfg") -Encoding utf8|ConvertFrom-Json
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
    #5.3
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
        [Parameter(Position=3)]
        [Switch]$WithoutSpaces
        ,
        [Parameter(Position=4)]
        $OffSet = [Drawing.Point]::new(0, 0)
        ,
        [Parameter(Position=5)]
        [Switch]$WithoutNoise
        ,
        [Parameter(Position=6)]
        [Switch]$WithImage
    )
    
    if($Accuracy -gt 0){$checkBoxSkipSymbolsChecked = $true}
    else{$checkBoxSkipSymbolsChecked = $false}

    if($OffSet -isnot [Drawing.Point]){
        try{$OffSet = [Drawing.Point]::new.Invoke($OffSet)}catch{throw $_}
    }

    $line = [Collections.Generic.List[[psClick.Line]]]::new()
    $MinSize = [System.Drawing.Size]::new($Base.config.MinWidth, $Base.config.MinHeight)
    if($Path -is [Drawing.Image]){
        $ImageOutput = [System.Drawing.Bitmap]::new($Path.Width, $Path.Height)
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
            $Base.Config.CheckBoxMergeLines,
            $Base.Config.TypeRus,
            $Base.Config.TypeEn,
            $Base.Config.TypeNum,
            $Base.Config.TypeOther,
            $Base.Config.CheckTextDeviation,
            $Base.Config.CheckFonDeviation,
            $Base.Config.ScrollTextDeviation,
            $Base.Config.ScrollFonDeviation,
            $Base.Config.ScrollIntellect,
            $Base.Config.ScrollIntellectAccuracy,
            $Base.Config.CheckIntellectMerge,
            $Base.Config.CheckIntellectMergeUp,
            $Base.Config.CheckIntellectSplit,
            $Base.Config.CheckIntellectSplitContour,
            $Base.Config.CheckIntellectVersion,
            $Base.Config.CheckIntellectThroughPixel,
            $Base.Config.txtColors.ForEach({"0x$_"}), 
            $Base.Config.bgColors.ForEach({"0x$_"}), 
            $Base.Config.TxtColorsChecked.ForEach({$_}),
            $Base.Config.BgColorsChecked.ForEach({$_}),
            $Base.Base,
            $checkBoxSkipSymbolsChecked,
            $Accuracy,
            [ref]$line,
            [ref]$ImageOutput,
            $WithoutNoise,
            $MinSize,
            $Base.config.Sharpness,
            $Base.config.SharpnessInversion,
            $Base.config.SharpnessScrollBarR,
            $Base.config.SharpnessScrollBarG,
            $Base.config.SharpnessScrollBarB,
            $Base.config.SharpnessRadioButtonNoChange,
            $Base.config.SharpnessRadioButtonBlack,
            $Base.config.SharpnessRadioButtonWhite,
            $Base.config.SharpnessTextBoxCore.ForEach({$_}),
            $Base.Config.ListDoubleSymbols.ForEach({$_})
        )
    }
    else{      
        $img = Get-Image -Path $path
        $ImageOutput = [System.Drawing.Bitmap]::new($img.Width, $img.Height)
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
            $Base.Config.CheckBoxMergeLines,
            $Base.Config.TypeRus,
            $Base.Config.TypeEn,
            $Base.Config.TypeNum,
            $Base.Config.TypeOther,
            $Base.Config.CheckTextDeviation,
            $Base.Config.CheckFonDeviation,
            $Base.Config.ScrollTextDeviation,
            $Base.Config.ScrollFonDeviation,
            $Base.Config.ScrollIntellect,
            $Base.Config.ScrollIntellectAccuracy,
            $Base.Config.CheckIntellectMerge,
            $Base.Config.CheckIntellectMergeUp,
            $Base.Config.CheckIntellectSplit,
            $Base.Config.CheckIntellectSplitContour,
            $Base.Config.CheckIntellectVersion,
            $Base.Config.CheckIntellectThroughPixel,
            $Base.Config.txtColors.ForEach({"0x$_"}), 
            $Base.Config.bgColors.ForEach({"0x$_"}), 
            $Base.Config.TxtColorsChecked.ForEach({$_}),
            $Base.Config.BgColorsChecked.ForEach({$_}),
            $Base.Base,
            $checkBoxSkipSymbolsChecked,
            $Accuracy,
            [ref]$line,
            [ref]$ImageOutput,
            $WithoutNoise,
            $MinSize,
            $Base.config.Sharpness,
            $Base.config.SharpnessInversion,
            $Base.config.SharpnessScrollBarR,
            $Base.config.SharpnessScrollBarG,
            $Base.config.SharpnessScrollBarB,
            $Base.config.SharpnessRadioButtonNoChange,
            $Base.config.SharpnessRadioButtonBlack,
            $Base.config.SharpnessRadioButtonWhite,
            $Base.config.SharpnessTextBoxCore.ForEach({$_}),
            $Base.Config.ListDoubleSymbols.ForEach({$_})
        )       
        $img.Dispose()
    }
    
    if(!$OffSet.IsEmpty){
        [psClick.ReadText]::SymbolsOffSet($result, $OffSet)    
    }
   

    if($WithImage){
        $result = [PSCustomObject]@{
            Symbols = $result
            Text = [psClick.Readtext]::SymbolsToString($result, $Base.Config.SpaceSize, $line, $WithoutSpaces) 
            Line = $line
            ImageOutput = $ImageOutput
        }  
    }
    else{
        $ImageOutput.Dispose();
        $result = [PSCustomObject]@{
            Symbols = $result
            Text = [psClick.Readtext]::SymbolsToString($result, $Base.Config.SpaceSize, $line, $WithoutSpaces) 
            Line = $line
        } 
    }
    $result
}