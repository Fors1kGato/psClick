function Find-Image
{
    #.COMPONENT
    #8.2
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    Param
    (
        [Parameter(Mandatory,Position=0)]
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
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Source_EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Source_Size'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Source_Rect'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Source_FullSize')]
        [Drawing.Bitmap]$Source
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_EndPoint' )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_EndPoint' )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_EndPoint'   )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Source_EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Size'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Size'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Size'       )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Source_Size'    )]
        $StartPos
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_EndPoint' )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_EndPoint' )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_EndPoint'   )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Source_EndPoint')]
        $EndPos
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_Size'     )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_Size'     )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_Size'       )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Source_Size'    )]
        $Size
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Rect'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Rect'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Rect'       )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Source_Rect'    )]
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
        [ValidateRange(0, 100)]
        [Int]$Deviation = 0
        ,
        [ValidateRange(0, 100)]
        [Int]$Accuracy = 100
        ,
        [Int]$Attempts = 0
        ,
        $BgColor = -1
        ,
        [Switch]$withDuplicates
        ,
        [Switch]$V2
        ,
        [Switch]$WithoutStartPos
        ,
        [ValidateSet(2, 4, 6, 8, 10)]
        [Int]$Threads = 0
    )
    if(!$V2 -and ($MyInvocation.BoundParameters.Keys.Contains("Attempts"))){
        throw "Для использования параметров -Attempts и -BgColor требуется указывать параметр -v2"
    }
    if($Image -isnot [Drawing.Bitmap]){
        if($Image -isnot [Drawing.Color]){
            try{
                $color = New-Color $Image
            }
            catch{
                throw "Неверно указана цель поиска"
            }
        }
        else{
            $color = $Image
        }
        $smallBmp = [System.Drawing.Bitmap]::new(1,1)
        $smallBmp.SetPixel(0, 0, ([Drawing.Color]::FromArgb.Invoke([Object[]]$color.RGB)))
        $Accuracy = 100
    }
    else{
        $smallBmp = $Image
    }
    
    if(($V2 -or $Threads -gt 0) -and -1 -ne $BgColor){
        if($BgColor -isnot [Drawing.Color]){
            try{
                $BgColor = New-Color $BgColor
            }
            catch{
                throw "Неверно указан цевет фона"
            }
        }
        $BgColor = [Drawing.ColorTranslator]::ToWin32([Drawing.Color]::FromArgb.Invoke([Object[]]$BgColor.RGB))
    }
    elseif($BgColor -is [Drawing.Color]){
        $BgColor = New-Color $BgColor -raw
    }
    else{
        $BgColor = $null
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
                    $bigBmp = Cut-Image ([psClick.Imaging]::GetImage($handle)) -Rect $rect
                }
                else{
                    $bigBmp = [psClick.Imaging]::GetImage($handle)
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
        'Source*'
        {
            if($rect){
                $bigBmp = Cut-Image $Source -Rect $rect -New
            }
            else{
                $bigBmp = $Source
            }
        }
    }


    if($smallBmp-eq$null){
        throw "Искомое изображение null"
    }
    if($bigBmp-eq$null){
        throw "Изображение, на котором искать null"   
    }


    if($V2 -and $smallBmp.PixelFormat -ne [Drawing.Imaging.PixelFormat]::Format32bppArgb){
        $smallBmp = $smallBmp.Clone(
            [Drawing.Rectangle]::new(0, 0, $smallBmp.Width, $smallBmp.Height), 
            [Drawing.Imaging.PixelFormat]::Format32bppArgb
        )
    }
    if($V2 -and $bigBmp.PixelFormat -ne [Drawing.Imaging.PixelFormat]::Format32bppArgb){
        $bigBmp = $bigBmp.Clone(
            [Drawing.Rectangle]::new(0, 0, $bigBmp.Width, $bigBmp.Height), 
            [Drawing.Imaging.PixelFormat]::Format32bppArgb
        )
    }

    if($v2){
        if($Threads -gt 0){
            $res = [psClick.FindImage]::FindBitmapMultiThreading(
                $smallBmp, 
                $bigBmp,
                $Count, 
                $Accuracy, 
                ($Deviation*2.55), 
                $Attempts, 
                $BgColor, 
                $Threads,
                $false,
                $false,
                2
            )
        }
        else{
            $res = [psClick.FindImage]::FindBitmap(
                $smallBmp, 
                $bigBmp, 
                $Count, 
                $Accuracy, 
                ($Deviation*2.55), 
                $Attempts, 
                $BgColor
            )
        }
    }
    else{
        if($Threads -gt 0){
            $res = [psClick.FindImage]::FindBitmapMultiThreading(
                $smallBmp, 
                $bigBmp,
                $Count, 
                $Accuracy, 
                ($Deviation/100.0), 
                0, 
                $BgColor, 
                $Threads,
                $withDuplicates,
                $true,
                1
            )
        }
        else{
            $res = [psClick.FindImage]::SearchBitmap(
                $smallBmp, 
                $bigBmp, 
                ($Deviation/100.0), 
                $Accuracy, 
                $Count,
                $BgColor,
                $withDuplicates,
                $true
            )
        }
    }
    

    <#
    if($PSCmdlet.ParameterSetName -notmatch "FullSize" -and $res.Count){
        0..($res.Count-1)|%{$res[$_].location.X+=$rect.x;$res[$_].location.Y+=$rect.Y}
        if($Image -is [Drawing.Bitmap]){
            0..($res.Count-1)|%{$res[$_].firstPixel.X+=$rect.x;$res[$_].firstPixel.Y+=$rect.Y}
        }
    }
    #>

    if(!$WithoutStartPos -and $PSCmdlet.ParameterSetName -notmatch "FullSize" -and $res.Count){
        [psClick.FindImage]::AddStartPos([ref]$res, $rect.Location, 0)
        if($Image -is [Drawing.Bitmap]){
            [psClick.FindImage]::AddStartPos([ref]$res, $rect.Location, 1)
        }
    }

    if($Image -isnot [Drawing.Bitmap]){$smallBmp.Dispose()}
    if(!$Source){$bigBmp.Dispose()}
    return ,$res
}
