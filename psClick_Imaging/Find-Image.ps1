function Find-Image
{
    #.COMPONENT
    #3.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [Alias('Find-Color')][CmdletBinding(DefaultParameterSetName = 'Screen_FullSize')]
    Param
    (
        [Parameter(Mandatory,Position=0)][Alias("Color")]
        $Image
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_EndPoint' )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_Size'     )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_Rect'     )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_FullSize' )]
        [IntPtr]$Handle
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_EndPoint' )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_Size'     )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_Rect'     )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_FullSize' )]
        [Switch]$Screen
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_EndPoint'   )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_Size'       )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_Rect'       )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_FullSize'   )]
        [ValidateScript({Test-Path $_})]
        [String]$Path
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Picture_EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Picture_Size'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Picture_Rect'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Picture_FullSize')]
        [Drawing.Bitmap]$Picture
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_EndPoint' )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_EndPoint' )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_EndPoint'   )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Picture_EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Size'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Size'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Size'       )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Picture_Size'    )]
        $StartPos
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_EndPoint' )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_EndPoint' )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_EndPoint'   )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Picture_EndPoint')]
        $EndPos
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_Size'     )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_Size'     )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_Size'       )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Picture_Size'    )]
        $Size
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Rect'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Rect'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Rect'       )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Picture_Rect'    )]
        [Drawing.Rectangle]$Rect
        ,
        [Parameter(ParameterSetName = 'Window_EndPoint' )]
        [Parameter(ParameterSetName = 'Window_Size'     )]
        [Parameter(ParameterSetName = 'Window_Rect'     )]
        [Parameter(ParameterSetName = 'Window_FullSize' )]
        [Switch]$Visible
        ,
        [UInt16]$Count = 1
        ,
        [ValidateRange(0.0, 1.0)]
        [Double]$Deviation = 0.0
        ,
        [ValidateRange(0, 100)]
        [Int]$Accuracy = 100
    )

    if($Image -isnot [Drawing.Bitmap]){
        if($Image -isnot [color]){
            try{
                $color = New-Color $Image
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
        $smallBmp = $Image
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
            if($Visible){
                $wRect = Get-WindowRectangle $Handle
                if($rect){
                    $wRect = [System.Drawing.Rectangle]::new(($wRect.x+$Rect.x), ($wRect.y+$Rect.y), $Rect.Width, $Rect.Height)
                }
                $scr = [System.Drawing.Bitmap]::new($wRect.Width, $wRect.Height, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
                $gfx = [System.Drawing.Graphics]::FromImage($scr)
                $gfx.CopyFromScreen($wRect.Location,[Drawing.Point]::Empty,$wrect.Size)
                $gfx.Dispose()
                $bigBmp = $scr
            }
            else{
                if($rect){
                    $bigBmp = Cut-Image ([psClickColor]::GetImage($handle)) -Rect $rect
                }
                else{
                    $bigBmp = [psClickColor]::GetImage($handle)
                }
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
                $bigBmp = Cut-Image ([System.Drawing.Bitmap]::new($path)) -Rect $rect
            }
            else{
                $bigBmp = [System.Drawing.Bitmap]::new($path)
            }
        }
        'Picture*'
        {
            if($rect){
                $bigBmp = Cut-Image $Picture -Rect $rect -New
            }
            else{
                $bigBmp = $Picture
            }
        }
    }

    $res = [ImgSearcher]::searchBitmap($smallBmp, $bigBmp, $deviation, $accuracy, $count)
    if($PSCmdlet.ParameterSetName -notmatch "FullSize" -and $res.Count){
        0..($res.Count-1)|%{$res[$_].location.X+=$rect.x;$res[$_].location.Y+=$rect.Y}
        if($Image -is [Drawing.Bitmap]){
            0..($res.Count-1)|%{$res[$_].firstPixel.X+=$rect.x;$res[$_].firstPixel.Y+=$rect.Y}
        }
    }
    if($Image -isnot [Drawing.Bitmap]){$smallBmp.Dispose()}
    if(!$Picture){$bigBmp.Dispose()}
    return ,$res
}