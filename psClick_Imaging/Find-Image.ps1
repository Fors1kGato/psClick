function Find-Image
{
    #.COMPONENT
    #3
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [Alias('Find-Color')][CmdletBinding(DefaultParameterSetName = 'Screen_FullSize')]
    Param
    (
        [Parameter(Mandatory,Position=0)][Object]$Target
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_Rect'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_FullSize')]
        [IntPtr]$Handle
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_Rect'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_FullSize')]
        [switch]$Screen
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_EndPoint'  )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_Size'      )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_Rect'      )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_FullSize'  )]
        [ValidateScript({Test-Path $_})]
        [String]$Path
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_EndPoint'  )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Size'      )]
        $StartPos
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_EndPoint'  )]
        $EndPos
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_Size'      )]
        $Size
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Rect'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Rect'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Rect'      )]
        [System.Drawing.Rectangle]$Rect
        ,
        [Int16]$Count = 1
        ,
        [ValidateRange(0.0, 1.0)]
        [Double]$Deviation = 0.0
        ,
        [ValidateRange(0, 100)]
        [Int]$Accuracy = 100
    )

    if($Target -isnot [Drawing.Bitmap]){
        if($Target -isnot [color]){
            try{
                $color = New-Color $Target
            }
            catch{
                throw "Неверно указана цель поиска"
            }
        }
        $smallBmp = [System.Drawing.Bitmap]::new(1,1)
        $smallBmp.SetPixel(0, 0, ([Drawing.Color]::FromArgb.Invoke([Object[]]$color.RGB)))
        $Accuracy = 100
    }
    else{
        $smallBmp = $Target
    }

    Switch -Wildcard ($PSCmdlet.ParameterSetName)
    {
        '*_Size'
        {
            if($StartPos -isnot [Drawing.Point]){try{$StartPos = [Drawing.Point]::new.Invoke($StartPos)}catch{throw $_}}
            if($Size-isnot[Drawing.Size]){try{$Size=[Drawing.Size]::new.Invoke($Size)}catch{throw $_}}
            $rect = [Drawing.Rectangle]::new($StartPos, $Size)
        }
        '*EndPoint'
        {
            if($StartPos -isnot [Drawing.Point]){try{$StartPos = [Drawing.Point]::new.Invoke($StartPos)}catch{throw $_}}
            if($EndPos -isnot [Drawing.Point]){try{$EndPos = [Drawing.Point]::new.Invoke($EndPos)}catch{throw $_}}
            $rect = [Drawing.Rectangle]::new($StartPos.x, $StartPos.y, ($EndPos.X-$StartPos.X), ($EndPos.Y-$StartPos.Y))
        }
        'Window*'
        {
            if($rect){
                $bigBmp = Cut-Image ([psClickColor]::GetImage($handle)) $rect
            }
            else{
                $bigBmp = [psClickColor]::GetImage($handle)
            }
        }
        'Screen*'
        {
            if(!$rect){$rect = [Windows.Forms.Screen]::PrimaryScreen.Bounds}
            $bigBmp = [System.Drawing.Bitmap]::new($Rect.Width, $Rect.Height)
            $gfx = [System.Drawing.Graphics]::FromImage($bigBmp)
            $gfx.CopyFromScreen($rect.Location,[Drawing.Point]::Empty,$rect.Size)
            $gfx.Dispose()
        }
        'File*'
        {
            if($rect){
                $bigBmp = Cut-Image ([System.Drawing.Bitmap]::new($path)) $rect
            }
            else{
                $bigBmp = [System.Drawing.Bitmap]::new($path)
            }
        }
    }

    $res = @([ImgSearcher]::searchBitmap($smallBmp, $bigBmp, $deviation, $accuracy, $count))
    if($PSCmdlet.ParameterSetName -notmatch "FullSize" -and $res.Count){
        0..($res.Count-1)|%{$res[$_].location.X+=$rect.x;$res[$_].location.Y+=$rect.Y}
        if($Target -is [Drawing.Bitmap]){
            0..($res.Count-1)|%{$res[$_].firstPixel.X+=$rect.x;$res[$_].firstPixel.Y+=$rect.Y}
        }
    }
    if($Target -isnot [Drawing.Bitmap]){$smallBmp.Dispose()}
    $bigBmp.Dispose()
    return ,$res
}