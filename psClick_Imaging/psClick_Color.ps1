function Find-Color
{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    Param
    (
        [Parameter(Mandatory,Position=0)]
        $Color
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
        [Alias("Picture")]
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
        [Switch]$WithoutStartPos
    )

    if($Color -isnot [Drawing.Color]){
        try{
            $Color = ([Drawing.Color]::FromArgb.Invoke([Object[]](New-Color $Color).RGB))
        }
        catch{
            throw "Неверно указана цель поиска"
        }
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
                $scr = [System.Drawing.Bitmap]::new($wRect.Width, $wRect.Height, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
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


    if($bigBmp.PixelFormat -ne [Drawing.Imaging.PixelFormat]::Format32bppArgb){
        $bigBmp = $bigBmp.Clone(
            [Drawing.Rectangle]::new(0, 0, $bigBmp.Width, $bigBmp.Height), 
            [Drawing.Imaging.PixelFormat]::Format32bppArgb
        )
    }

    $res = [psClick.FindImage]::FindColor(
        $Color,
        $bigBmp, 
        $Count,
        $Deviation*2.55    
    )
    
       
    if(!$WithoutStartPos -and $PSCmdlet.ParameterSetName -notmatch "FullSize" -and $res.Count){
        [psClick.FindImage]::AddStartPos([ref]$res, $rect.Location, 0)
    }

    if(!$Source){$bigBmp.Dispose()}
    return ,$res
}

function Find-HeapColor
{
    #.COMPONENT
    #1.0
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
 
    [CmdletBinding()]   
    param(
        [Parameter(Mandatory,Position=0)][Alias("Image")]
        $Path
        ,
        [Parameter(Mandatory,Position=1)]
        [Object[]]$ListColor
        ,
        [Parameter(Mandatory,Position=2)]
        $SizeObject
        ,
        $SizeNoSearch = $SizeObject
        ,
        [ValidateRange(0, 100)]
        [Int]$Deviation = 0
        ,
        [Int]$MinColor = 0
        ,
        [Int]$MinPixel = 0
        ,
        [Int]$MaxPixel = 0
        ,
        [Int]$Count = 0
    )
    
    if($SizeObject-isnot[Drawing.Size]){try{$SizeObject=[Drawing.Size]::new.Invoke($SizeObject)}catch{throw $_}}
    if($SizeNoSearch-isnot[Drawing.Size]){try{$SizeNoSearch=[Drawing.Size]::new.Invoke($SizeNoSearch)}catch{throw $_}}    

    $ListColor2 = [Collections.Generic.List[Drawing.Color]]::new()
    $ListColorMin2 = [Collections.Generic.List[int]]::new()

    if($ListColor[0].GetType().Name -eq "String"){
        if($MinColor -eq 0){ $MinColor = 1}
        $Color = New-Color -Color $ListColor[0]      
        $ListColor2.Add([Drawing.Color]::FromArgb($Color.RGB[0], $Color.RGB[1], $Color.RGB[2]))
        $ListColorMin2.Add([int]$ListColor[1])    
    }
    else{
        if($MinColor -eq 0){ $MinColor = $ListColor.Count}
        foreach($Item in $ListColor){
            $Color = New-Color -Color $Item[0]       
            $ListColor2.Add([Drawing.Color]::FromArgb($Color.RGB[0], $Color.RGB[1], $Color.RGB[2]))
            $ListColorMin2.Add([int]$Item[1])
        }
    }
 

    if($Path -is [Drawing.Image]){
        $res = [psClick.Imaging]::FindHeapColor($Path, $ListColor2, $ListColorMin2, $Deviation, $MinColor, $SizeObject, $SizeNoSearch, $MinPixel, $MaxPixel, $Count)                
    }               
    else{
        $img = Get-Image -Path $Path
        $res = [psClick.Imaging]::FindHeapColor($img, $ListColor2, $ListColorMin2, $Deviation, $MinColor, $SizeObject, $SizeNoSearch, $MinPixel, $MaxPixel, $Count)
        $img.Dispose()        
    }

    return $res
}

function Get-RectangleFromScreen
{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        $Hint = "Выделите область на экране"
        ,
        $HintColor = [Drawing.Color]::Black
        ,
        $RectColor = [Drawing.Color]::Cyan
    )
    if($RectColor -isnot [Drawing.Color]){
        try{
            $RectColor = New-Color $RectColor -raw
        }
        catch{
            throw "Неверно указан цевет прямоугольника"
        }
    }
    if($HintColor -isnot [Drawing.Color]){
        try{
            $HintColor = New-Color $HintColor -raw
        }
        catch{
            throw "Неверно указан цевет текста"
        }
    }

    $form = [psClick.FormRectangle]::new($Hint, $HintColor)
    $form.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
    $form.BackColor = $RectColor
    Set-WindowTransparency -Handle $form.Handle -Transparency 150
    $form.ShowDialog()|Out-null

    [psClick.FormRectangle]::ResultForm
}

function Get-CursorImage
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    param(   
    )
    [Drawing.Icon]::FromHandle((Get-CursorHandle)).ToBitmap()
}

function Compare-Cursor
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus ; Link: https://psClick.ru
    param(    
        [Parameter(Mandatory)]
        [Drawing.Bitmap]$ImageCursor
    )
    $cursor = [System.Drawing.Icon]::FromHandle((Get-CursorHandle))
    $bitmap = $cursor.ToBitmap()
 
    $result = $false
    if((Find-Image $ImageCursor -Picture $bitmap)){
        $result = $true    
    }     
    $cursor.Dispose()
    $bitmap.Dispose()
    
    return $result
}

class Color : System.IEquatable[Object] {
    [Byte[]]$RGB
    [String]$HEX

    Color([Byte]$R,[Byte]$G,[Byte]$B){
        $this.RGB = $R,$G,$B
        $this.HEX = "{0:X2}{1:X2}{2:X2}" -f $R,$G,$B
    }
    Color([object]$RGB){
        $this.RGB = $RGB[0],$RGB[1],$RGB[2]
        $this.HEX = "{0:X2}{1:X2}{2:X2}" -f $RGB[0],$RGB[1],$RGB[2]
    }
    Color([String]$p){
        $c = [System.Drawing.ColorTranslator]::FromHtml("#$p")
        $this.HEX = $p
        $this.RGB = $c.R,$c.G,$c.B
    }
    Color([Drawing.Color]$c){
        $this.RGB = $c.R,$c.G,$c.B
        $this.HEX = "{0:X2}{1:X2}{2:X2}" -f $c.R,$c.G,$c.B
    }
    [bool] Equals([Object] $obj) {
        return $this.HEX -eq ([Color]$obj).HEX
    }
}

function New-Color
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        $Color,
        [Switch]$Raw
    )
    $c = [Color]$color
    if($raw){
        [Drawing.Color]::FromArgb($c.RGB[0],$c.RGB[1],$c.RGB[2])
    }
    else{
        $c
    }
}

function Get-Color
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen')]
    Param(
        [Parameter(Mandatory, Position=0,ParameterSetName = 'Screen')]
        [Parameter(Mandatory, Position=0,ParameterSetName = 'Window')]
        [Parameter(Mandatory, Position=0,ParameterSetName = 'Image' )]
        $Position
        ,
        [Parameter(Mandatory,ParameterSetName = 'Window')]
        [IntPtr]$Handle = [IntPtr]::Zero
        ,
        [Parameter(ParameterSetName = 'Window')]
        [Switch]$Visible
        ,
        [Parameter(ParameterSetName = 'Screen')]
        [Switch]$Screen
        ,
        [Parameter(ParameterSetName = 'Image')]
        [Drawing.Bitmap]$Picture
        ,
        [switch]$Raw
    )
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
    }
    if($Picture){
        $color = $Picture.GetPixel($Position.x, $Position.y)
    }
    else{
        if($Visible){
            [Void][w32Windos]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$Position, 1)
            $Handle = [IntPtr]::Zero
        }
        $color = [psClick.Imaging]::GetColor($Position.x, $Position.y, $handle)
    }
    if($raw){
        $color
    }
    else{
        [color]::new($color.R,$color.G,$color.B)
    }
}

function Cut-Image
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Rect')]
    Param
    (
        [Parameter(Mandatory,Position=0,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Size'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Rect'    )]
        [Drawing.Bitmap]$Image
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Size'    )]
        $StartPos
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'EndPoint')]
        $EndPos
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Size'    )]
        $Size
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Rect'    )]
        [System.Drawing.Rectangle]$rect
        ,
        [Switch]$New
    )
    Switch ($PSCmdlet.ParameterSetName)
    {
        'EndPoint'
        {
            if($StartPos -isnot [Drawing.Point]){try{$StartPos = [Drawing.Point]::new.Invoke($StartPos)}catch{throw $_}}
            if($EndPos -isnot [Drawing.Point]){try{$EndPos = [Drawing.Point]::new.Invoke($EndPos)}catch{throw $_}}
            $rect = [Drawing.Rectangle]::new($StartPos.x, $StartPos.y, ($EndPos.X-$StartPos.X), ($EndPos.Y-$StartPos.Y))
        }
        'Size'
        {
            if($StartPos -isnot [Drawing.Point]){try{$StartPos = [Drawing.Point]::new.Invoke($StartPos)}catch{throw $_}}
            if($Size-isnot[Drawing.Size]){try{$Size=[Drawing.Size]::new.Invoke($Size)}catch{throw $_}}
            $rect = [Drawing.Rectangle]::new($StartPos, $Size)
        }
    }
    $newImg = $Image.Clone($rect, $Image.PixelFormat)
    if(!$New){
        $Image.Dispose()
        return $newImg
    }
    else{
        return $newImg
    }
}

function Get-Image
{
    #.COMPONENT
    #3.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen_FullSize')]
    Param
    (   [Parameter(Mandatory,Position=0,ParameterSetName = 'Url')]
        [String]$Url
        ,
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Window_Rect'    )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Window_FullSize')]
        [IntPtr]$Handle
        ,
        [Parameter(Mandatory,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,ParameterSetName = 'Screen_Rect'    )]
        [Parameter(Mandatory,ParameterSetName = 'Screen_FullSize')]
        [switch]$Screen
        ,
        [Parameter(Mandatory,Position=0,ParameterSetName = 'File_EndPoint'  )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'File_Size'      )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'File_Rect'      )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'File_FullSize'  )]
        [ValidateScript({Test-Path $_})]
        [String[]]$Path
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_EndPoint'  )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_Size'      )]
        $StartPos
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_EndPoint'  )]
        $EndPos
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_Size'      )]
        $Size
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_Rect'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_Rect'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_Rect'      )]
        [Drawing.Rectangle]$Rect
        ,
        [Parameter(ParameterSetName = 'Window_EndPoint')]
        [Parameter(ParameterSetName = 'Window_Size'    )]
        [Parameter(ParameterSetName = 'Window_Rect'    )]
        [Parameter(ParameterSetName = 'Window_FullSize')]
        [Switch]$Visible
        ,
        [ValidateSet([Drawing.Imaging.PixelFormat]::Format24bppRgb, [Drawing.Imaging.PixelFormat]::Format32bppArgb)]
        $PixelFormat = [Drawing.Imaging.PixelFormat]::Format24bppRgb
    )

    if($Url){
        return [Drawing.Image]::FromStream((IWR $Url -USEB).RawContentStream)
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
                $scr = [System.Drawing.Bitmap]::new($wRect.Width, $wRect.Height, $PixelFormat)
                $gfx = [System.Drawing.Graphics]::FromImage($scr)
                $gfx.CopyFromScreen($wRect.Location,[Drawing.Point]::Empty,$wrect.Size)
                $gfx.Dispose()
                return $scr
            }
            else{
                if( $rect ){
                    return Cut-Image ([psClick.Imaging]::GetImage($handle, $PixelFormat)) -Rect $rect
                }
                else{
                    return [psClick.Imaging]::GetImage($handle, $PixelFormat)
                }
            }
        }
        'Screen*'
        {
            if(!$rect){$rect = [Windows.Forms.Screen]::PrimaryScreen.Bounds}
            $scr = [System.Drawing.Bitmap]::new($Rect.Width, $Rect.Height, $PixelFormat)
            $gfx = [System.Drawing.Graphics]::FromImage($scr)
            $gfx.CopyFromScreen($rect.Location,[Drawing.Point]::Empty,$rect.Size)
            $gfx.Dispose()
            return $scr
        }
        'File*'
        {
            if($rect){
                $res = $path|ForEach{                   
                    $img = Cut-Image ([Drawing.Bitmap]::new($_)) -Rect $rect
                    if($img.PixelFormat -ne $PixelFormat){
                        $img.Clone([System.Drawing.Rectangle]::new(0, 0, $img.Width, $img.Height), $PixelFormat)
                        $img.Dispose()         
                    }
                    else{ $img }
                }
                return $res
            }
            else{
                $res = $path|ForEach{
                    $img = [Drawing.Bitmap]::new($_)
                    if($img.PixelFormat -ne $PixelFormat){
                        $img.Clone([System.Drawing.Rectangle]::new(0, 0, $img.Width, $img.Height), $PixelFormat)
                        $img.Dispose()         
                    }
                    else{ $img }
                }
                return $res
            }
        }
    }
}

function Show-Hint
{
    #.COMPONENT
    #5
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    param(
        [String]$Text
        ,
        [Parameter(Mandatory)]
        [String]$Name
        ,
        $Position
        ,
        [ValidateRange(0, [Int32]::MaxValue)]
        [Int32]$Duration = 3000
        ,
        [UInt16]$Size = 25
        ,
        [Switch]$Vision
        ,
        [ValidateRange(0, 100)]
        $Transparency
        ,
        $TextColor = [Drawing.Color]::Cyan
        ,
        $BgColor = [Drawing.Color]::FromArgb(255, 1, 36, 86)
    )
    if($null -eq $Position){
        $Position = [Drawing.Point]::Empty
        $NewPosition = $false
    }
    else{$NewPosition = $true}
    if($null -eq $Transparency){
        $Transparency = 82
        $NewTransparency = $false
    }
    else{$NewTransparency = $true}
    if($Duration -eq 0){
        $Duration = [Int32]::MaxValue
    }
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
    }
    if($BgColor -isnot [Drawing.Color]){
        $BgColor = New-Color $BgColor -Raw
    }
    if($TextColor -isnot [Drawing.Color]){
        $TextColor = New-Color $TextColor -Raw
    }
    [double]$Transparency = [double]($Transparency/100)
    <#
    if(!$new){
        $h = (Find-Window -Title "psClickHint").handle
        if($h){$h|%{[void][w32]::SendMessage($_, 0x0112, 0xF060, 0)}}
    }
    #>
    $fPath = (Convert-Path "$psscriptroot\Jura.otf")
    #$handle = 
    $hint = {
        param(
            $Text,
            $Duration,
            $fColor,
            $Position,
            $Size,
            $fPath,
            [bool]$Ghost,
            $Name,
            $BgColor,
            $Transparency,
            [bool]$NewPosition,
            [bool]$NewTransparency
        )
        $w = (Find-Window -Title "psClickHint_$name" -Option EQ).handle
        if(!$w){$new = $true}else{$w = $w[0]}
        if($New -and $Ghost){
            $f = [System.Windows.Forms.Form]::new()
            $f.ShowInTaskbar = $false
            $f.FormBorderStyle = "none"
            $f.TransparencyKey = $f.BackColor
            $f.TopLevel = $true
            #$f.TopMost = $true
            $f.Size = [System.Drawing.Size]::Empty
            $f.AutoSize = $true
            $f.StartPosition = 0
            $f.Text = "psClickHint_$Name"
            $f.Location = $Position
            $f.Opacity = $Transparency

            $fc = [System.Drawing.Text.PrivateFontCollection]::new()
            $fc.AddFontFile($fPath)

            $lb = [System.Windows.Forms.Label]::new()
            $lb.Size = [Drawing.Size]::Empty
            $lb.Location = [System.Drawing.Point]::Empty
            $lb.BackColor = $BgColor
            $lb.AutoSize = $true
            $lb.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
            $lb.Font = [Drawing.Font]::new($fc.Families[0], $size, [System.Drawing.FontStyle]::Bold)
            $lb.ForeColor = $fColor
            $lb.Text = $Text
            $lb.Parent = $f

            $tb = [Windows.Forms.TextBox]@{
                Location = [Drawing.point]::Empty
                Size = [Drawing.Size]::Empty
                Parent = $f
            }

            $tb2 = [Windows.Forms.TextBox]@{
                Location = [Drawing.point]::Empty
                Size = [Drawing.Size]::Empty
                Text = $f.Opacity
                Parent = $f
            }

            $timer = [Windows.Forms.Timer]::new()
            $timer.Interval = $Duration
            $timer.add_tick({ $f.Close() })
            $timer.Start()

            $tb2.Add_TextChanged({$f.Opacity = $tb2.Text})

            $tb.Add_TextChanged({
                $lb.Text = $tb.Text
                #$f.TopMost = $true
                $timer.Stop()
                $timer.Start()
            })
            #$f.Add_Shown({ $f.TopMost = $true })
            #$f.Add_Shown({Start-ThreadJob -ScriptBlock {Show-Window $args[0] -State TopMost} -ArgumentList $f.Handle -StreamingHost $host})
            $f.Add_Closed({ $timer.Stop() })

            $WS_EX_TRANSPARENT = 0x00000020
            $WS_EX_LAYERED = 0x00080000
            $GWL_EXSTYLE   = -20

            [Void][psClick.User32]::SetWindowLongPtr(
                $f.Handle, 
                $GWL_EXSTYLE, 
                ($WS_EX_LAYERED -bor $WS_EX_TRANSPARENT)
            )

            .{
                Show-Window $f.Handle -State ShowNA
                Show-Window $f.Handle -State TopMost
                $f.Show()
                while($f.Visible){
                    [Windows.Forms.Application]::DoEvents()
                    Sleep -m 64
                } 
                $f.Dispose()
            }
        }
        elseif($New -and !$Ghost){
            $f = [System.Windows.Forms.Form]::new()
            $f.ShowInTaskbar = $false
            $f.FormBorderStyle = "none"
            $f.TransparencyKey = $f.BackColor
            $f.TopLevel = $true
            #$f.TopMost = $true
            $f.Size = [System.Drawing.Size]::Empty
            $f.AutoSize = $true
            $f.StartPosition = 0
            $f.Text = "psClickHint_$Name"
            $f.Location = $Position
            $f.Opacity = $Transparency

            $fc = [System.Drawing.Text.PrivateFontCollection]::new()
            $fc.AddFontFile($fPath)
            $font = [Drawing.Font]::new($fc.Families[0], $size, [System.Drawing.FontStyle]::Bold)

            $lb = [System.Windows.Forms.Label]::new()
            $lb.Size = [Drawing.Size]::Empty
            $lb.Location = [System.Drawing.Point]::empty
            $lb.BackColor = $BgColor
            $lb.AutoSize = $true
            $lb.Font = $font
            $lb.Text = $Text

            $tb1 = [Windows.Forms.TextBox]@{
                Location = [Drawing.point]::Empty
                Size = [Drawing.Size]::Empty
                Parent = $f
            }

            $tb2 = [Windows.Forms.TextBox]@{
                Location = [Drawing.point]::Empty
                Size = [Drawing.Size]::Empty
                Text = $f.Opacity
                Parent = $f
            }

            $tb = [Windows.Forms.TextBox]::new()
            $tb.Location = [Drawing.point]::Empty
            $tb.Size = [Drawing.Size]::Empty
            $tb.BackColor = $BgColor
            $tb.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
            $tb.ForeColor = $fColor
            $tb.Multiline = $true
            $tb.TabStop = $false
            $tb.ReadOnly = $true
            $tb.AutoSize = $true
            $tb.Font = $lb.Font
            $tb.Text = $lb.Text

            $f.Controls.Add($tb)
            $f.Controls.Add($lb)

            $timer = [Windows.Forms.Timer]::new()
            $timer.Interval = $Duration
            $timer.add_tick({ $f.Close() })
            $timer.Start()

            $tb2.Add_TextChanged({$f.Opacity = $tb2.Text})

            $tb1.Add_TextChanged({
                $tb.Text = $tb1.Text
                $lb.Text = $tb.Text
                $tb.Size = $lb.Size
                #$f.TopMost = $true
                $timer.Stop()
                $timer.Start()
            })
            #$f.Add_Shown({ $f.TopMost = $true;$tb.Size = $lb.Size })
            $f.Add_Shown({
                $tb.Size = $lb.Size
                #Start-ThreadJob -ScriptBlock {Show-Window $args[0] -State TopMost} -ArgumentList $f.Handle -StreamingHost $host
            })
            $f.Add_Closed({ $timer.Stop() })
             

            .{
                Show-Window $f.Handle -State ShowNA
                Show-Window $f.Handle -State TopMost
                $f.Show()
                while($f.Visible){
                    [Windows.Forms.Application]::DoEvents()
                    Sleep -m 64
                } 
                $f.Dispose()
            }
        }
        else{
            $h = @(Get-ChildWindows -Handle $w|where Class -match "EDIT")
            $ptr = [Runtime.InteropServices.Marshal]::StringToHGlobalAuto($text)
            $send = [psClick.User32]::SendMessage(
                $h[0].Handle,
                0x000C,
                0,
                $ptr
            )
            [Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)
            #Write-Host $Transparency
            #Write-Host $Position
            #Write-Host $w
            if($NewPosition){
                #Write-Host "NewPosition"
                Move-Window $Position $w
            }
            if($NewTransparency){
                #Write-Host "NewTransparency"
                $ptr = [Runtime.InteropServices.Marshal]::StringToHGlobalAuto("$Transparency")
                $send = [psClick.User32]::SendMessage(
                    $h[1].Handle,
                    0x000C,
                    0,
                    $ptr
                )
                [Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)
            }
        }
    }
    Start-ThreadJob $hint -Name psclickhint -StreamingHost $host -ArgumentList @(
        $Text,$Duration,$TextColor,
        $Position,$Size,$fPath,
        $Vision,$Name,$BgColor,
        $Transparency,$NewPosition,
        $NewTransparency
    )|out-null
}

Function Close-Hint
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Cirus ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [String]$Name
    )
    $w = (Find-Window -Title "psClickHint_$name" -Option EQ).handle
    if(!$w){Write-Host "По имени '$name' Hint не найден" -fo DarkRed;return}
    Close-Window $w[0]
    Sleep -m 2
}

Function Get-Hint
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0,ParameterSetName = "Name")]
        [String]$Name
        ,
        [Parameter(Mandatory, Position = 0,ParameterSetName = "All")]
        [Switch]$All
    )
    if($Name){
        $w = Find-Window -Title "psClickHint_$name" -Option EQ
        if($w){$true}else{$false}
    }
    else{
        $w = Find-Window -Title "psClickHint_"
        if($w){return ($w).title.replace("psClickHint_","")}
    }
}

Function Compare-Color
{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Cirus ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0)]
        $Color1
        ,
        [Parameter(Mandatory, Position = 1)]
        $Color2
        ,
        $Deviation = 0
        ,
        $Rmin = 0
        ,
        $Gmin = 0
        ,
        $Bmin = 0
        ,
        $Rmax = 0
        ,
        $Gmax = 0
        ,
        $Bmax = 0
        ,
        [switch]$Percent
    )

    $Color1 = New-Color $Color1 
    $Color2 = New-Color $Color2
    
    if ($Deviation) {
        if ($Percent) {
            $Rmin = 2.55 * $Deviation 
            $Gmin = 2.55 * $Deviation 
            $Bmin = 2.55 * $Deviation 
            $Rmax = 2.55 * $Deviation 
            $Gmax = 2.55 * $Deviation  
            $Bmax = 2.55 * $Deviation 
        }
        else {
            $Rmin = $Deviation 
            $Gmin = $Deviation 
            $Bmin = $Deviation 
            $Rmax = $Deviation 
            $Gmax = $Deviation  
            $Bmax = $Deviation 
        }
    }
        
    if ($Color1.RGB[0] -gt ($Color2.RGB[0] + $Rmin)) { return $false }   
    if ($Color1.RGB[1] -gt ($Color2.RGB[1] + $Gmin)) { return $false }   
    if ($Color1.RGB[2] -gt ($Color2.RGB[2] + $Bmin)) { return $false }           
    if ($Color1.RGB[0] -lt ($Color2.RGB[0] - $Rmax)) { return $false }   
    if ($Color1.RGB[1] -lt ($Color2.RGB[1] - $Gmax)) { return $false }   
    if ($Color1.RGB[2] -lt ($Color2.RGB[2] - $Bmax)) { return $false }                 
    
    return $true
}

function Draw-Rectangle
{
    #.COMPONENT
    #3
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    param(
        [Parameter(Mandatory,Position=0)]
        $Location
        ,
        [Parameter(Mandatory,Position=1)]
        $Size
        ,
        [Parameter(Position=2)]
        $Color = [Drawing.Color]::Red
        ,
        [Parameter(Position=3)]
        [UInt16]$Width = 3
    )
    if($Size -isnot [Drawing.Size]){try{$Size=[Drawing.Size]::new.Invoke($Size)}catch{throw $_}}
    if($Color -isnot [Drawing.Color]){$Color = New-Color $Color -Raw}
    if($Location -isnot [Drawing.Point]){
        try{
            if($Location.Count -eq 2 -and $Location[0]-is[int]){
                $Location = [Drawing.Point]::new.Invoke($Location)
            }
            else{
                $Location = $Location|ForEach{
                    if($_ -isnot [Drawing.Point]){
                    
                        [Drawing.Point]::new.Invoke($_)
                    }
                    else{$_}
                }
            }
        }catch{throw $_}
    }
    

    $DrawRectangle = {
        param($Location,$Size,$Color,$width)
        #$f = $using:f
        $Location.Offset(-$Width+1,-$Width+1)
        $sz = [Drawing.Size]::new($size.Width+$Width,$size.Height+$Width)
        $WS_EX_TRANSPARENT = 0x00000020
        $WS_EX_LAYERED     = 0x00080000
        $GWL_EXSTYLE       = -20

        $f = [System.Windows.Forms.Form]::new()
        $f.ShowInTaskbar = $false
        $f.FormBorderStyle = "none"
        $f.TransparencyKey = $f.BackColor
        $f.StartPosition = 0
        $f.Text = "psClick_DrawRectangle"
        $f.Size = [Windows.Forms.Screen]::PrimaryScreen.bounds.size

        $timer = [Windows.Forms.Timer]::new()
        $timer.Interval = 3000
        $timer.add_tick({ $f.Close() })
        $timer.Start()

        [Void][psClick.User32]::setSetWindowLongPtr(
            $f.Handle, 
            $GWL_EXSTYLE, 
            ($WS_EX_LAYERED -bor $WS_EX_TRANSPARENT)
        ) 
        $pen = [Drawing.Pen]::new($Color, $Width)

        $f.Add_Paint({ForEach($l in $location){$_.Graphics.DrawRectangle($pen, [System.Drawing.Rectangle]::new($l,$sz))}})
        $f.Add_Closed({ $timer.Stop() })

        .{
            Show-Window $f.Handle -State ShowNA
            Show-Window $f.Handle -State TopMost
            $f.Show()
            while($f.Visible){
                [Windows.Forms.Application]::DoEvents()
                Sleep -m 64
            } 
            $f.Dispose()
        }
    }

    Remove-Job -Name psclickDrawRectangle -Force -ea 0
    Start-ThreadJob $DrawRectangle -Name psclickDrawRectangle -StreamingHost $host -ArgumentList @(
        $Location,$Size,$Color,$width
    )|Out-Null
}

function Show-WindowThumbnail
{
    #.COMPONENT
    #1.0
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
 
    [CmdletBinding(DefaultParameterSetName = 'Rect')] 
    param(
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Thumbnail')]
        [Object]$Thumbnail
        ,
        [Parameter(Mandatory,Position=0,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Size'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Rect'    )]
        [IntPtr]$Handle
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Size'    )]
        $StartPos
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'EndPoint')]
        $EndPos
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Size'    )]
        $Size
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Rect'    )]
        [System.Drawing.Rectangle]$Rect
        ,
        $Location = [System.Drawing.Point]::Empty
        ,
        [uint32]$Percent = 100
        ,
        [ValidateRange(0, 1)]
        [double]$OpacityWindow = 1.0
    )


    Switch ($PSCmdlet.ParameterSetName)
    {
        'EndPoint'
        {
            if($StartPos -isnot [Drawing.Point]){try{$StartPos = [Drawing.Point]::new.Invoke($StartPos)}catch{throw $_}}
            if($EndPos -isnot [Drawing.Point]){try{$EndPos = [Drawing.Point]::new.Invoke($EndPos)}catch{throw $_}}
            $Rect = [Drawing.Rectangle]::new($StartPos.x, $StartPos.y, ($EndPos.X-$StartPos.X), ($EndPos.Y-$StartPos.Y))
        }
        'Size'
        {
            if($StartPos -isnot [Drawing.Point]){try{$StartPos = [Drawing.Point]::new.Invoke($StartPos)}catch{throw $_}}
            if($Size-isnot[Drawing.Size]){try{$Size=[Drawing.Size]::new.Invoke($Size)}catch{throw $_}}
            $Rect = [Drawing.Rectangle]::new($StartPos, $Size)
        }
        'Thumbnail'
        {
            Set-WindowTransparency -Handle $Thumbnail.Handle -Transparency $Thumbnail.Alpha
            return
        }
    }


    if($Location -isnot [Drawing.Point]){try{$Location = [Drawing.Point]::new.Invoke($Location)}catch{throw $_}}

    $Action = {
        $Form = [psClick.FormWindowThumbnail]::new($args[0], $args[1], $args[2], $args[3], $args[4])
        $Form.Handle
        $Form.ShowDialog()|Out-Null
        $Form.Dispose()
    }

    $ThumbnailCount = (Get-Job|where{$_.Name -match "JobThumbnail\d+"}).Count
    $ThumbnailCount++

    $Job = Start-ThreadJob -ScriptBlock $Action -Name ('JobThumbnail' + $ThumbnailCount.ToString()) -ArgumentList $Handle, $Location, $Rect, $Percent, $OpacityWindow
    while((Receive-Job $Job -Keep) -isnot [System.IntPtr]){ sleep -m 10 }
    [IntPtr]$FormHandle = Receive-Job $Job
    [uint32]$Alpha = $OpacityWindow * 255

    [PSCustomObject]@{
        Job   = $Job
        Handle = $FormHandle
        Alpha = $Alpha
    }   
}

function Hide-WindowThumbnail
{
    #.COMPONENT
    #1.0
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    param(
        [Parameter(Mandatory,Position=0)]
        [Object]$Thumbnail
    )
    Set-WindowTransparency -Handle $Thumbnail.Handle -Transparency 0
}

function Close-WindowThumbnail
{
    #.COMPONENT
    #1.0
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    param(
        [Parameter(Mandatory,Position=0)]
        [Object]$Thumbnail
    )
    Close-Window $Thumbnail.Handle
    Remove-Job -Job $Thumbnail.Job -Force
}

function Merge-Images
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [Object[]]$Images
    )

    $WidthImage = $Images[0].Width
    $HeightImage = $Images[0].Height
    $ImagesCount = $Images.Count

    for ($i = 1; $i -lt $ImagesCount; $i++)
    { 
        if ($Images[$i].Width -ne $WidthImage -or $Images[$i].Height -ne $HeightImage){
            throw "Изображения разных размеров"
        }
    }

    $ResultImage = [System.Drawing.Bitmap]::new($WidthImage, $HeightImage)

    for ($x = 0; $x -lt $WidthImage; $x++)
    { 
        for ($y = 0; $y -lt $HeightImage; $y++)
        { 
            [int]$R = 0
            [int]$G = 0
            [int]$B = 0
            
            for ($i = 0; $i -lt $ImagesCount; $i++)
            {
                $Color = $Images[$i].GetPixel($x, $y)
                $R += $Color.R
                $G += $Color.G
                $B += $Color.B
            }
            
            $ResultImage.SetPixel(
                    $x, $y,
                    [Drawing.Color]::FromArgb(
                    ($R / $ImagesCount),
                    ($G / $ImagesCount),
                    ($B / $ImagesCount)
                )
            )
        }
    }
    $ResultImage
}