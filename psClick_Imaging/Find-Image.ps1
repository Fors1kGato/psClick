function Find-Image
{
    #.COMPONENT
    #6
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
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
        #[Parameter(Mandatory,Position=1,ParameterSetName = 'Second_Way'      )]
        [IntPtr]$Handle
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_EndPoint' )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_Size'     )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_Rect'     )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_FullSize' )]
        #[Parameter(Mandatory,Position=1,ParameterSetName = 'Second_Way'      )]
        [Switch]$Screen
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_EndPoint'   )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_Size'       )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_Rect'       )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_FullSize'   )]
        #[Parameter(Mandatory,Position=1,ParameterSetName = 'Second_Way'      )]
        [ValidateScript({Test-Path $_})]
        [String]$Path
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Picture_EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Picture_Size'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Picture_Rect'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Picture_FullSize')]
        #[Parameter(Mandatory,Position=1,ParameterSetName = 'Second_Way'      )]
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
        #[Parameter(Mandatory,Position=2,ParameterSetName = 'Second_Way'      )]
        $StartPos
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_EndPoint' )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_EndPoint' )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_EndPoint'   )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Picture_EndPoint')]
        #[Parameter(Mandatory,Position=3,ParameterSetName = 'Second_Way'      )]
        $EndPos
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_Size'     )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_Size'     )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_Size'       )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Picture_Size'    )]
        #[Parameter(Mandatory,Position=3,ParameterSetName = 'Second_Way'      )]
        $Size
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Rect'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Rect'     )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Rect'       )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Picture_Rect'    )]
        #[Parameter(Mandatory,Position=2,ParameterSetName = 'Second_Way'      )]
        [Drawing.Rectangle]$Rect
        ,
        [Parameter(ParameterSetName = 'Window_EndPoint' )]
        [Parameter(ParameterSetName = 'Window_Size'     )]
        [Parameter(ParameterSetName = 'Window_Rect'     )]
        [Parameter(ParameterSetName = 'Window_FullSize' )]
        #[Parameter(ParameterSetName = 'Second_Way'      )]
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
        #[Parameter(ParameterSetName = 'Second_Way')]
        [Int]$Attempts = 0
        ,
        #[Parameter(ParameterSetName = 'Second_Way')]
        $BgColor = -1
        ,
        #[Parameter(Mandatory,ParameterSetName = 'Second_Way')]
        [Switch]$V2
    )
    if(!$V2 -and ($MyInvocation.BoundParameters.Keys.Contains("Attempts"))){
        throw "Для использования параметров -Attempts и -BgColor требуется указывать параметр -v2"
    }
    if($Image -isnot [Drawing.Bitmap]){
        if($Image -isnot [Color]){
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
    #
    if($V2 -and -1 -ne $BgColor){
        if($BgColor -isnot [Color]){
            try{
                $BgColor = New-Color $BgColor
            }
            catch{
                throw "Неверно указан цевет фона"
            }
        }
        $BgColor = [Drawing.ColorTranslator]::ToWin32([Drawing.Color]::FromArgb.Invoke([Object[]]$BgColor.RGB))
    }
    elseif($BgColor -is [Color]){
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
    else{
        $res = [psClick.FindImage]::SearchBitmap(
            $smallBmp, 
            $bigBmp, 
            ($Deviation/100.0), 
            $Accuracy, 
            $Count,
            $BgColor
        )
    }
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