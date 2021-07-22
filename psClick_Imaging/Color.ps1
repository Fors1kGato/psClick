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
        $this.HEX=$p
        $this.RGB=$c.R,$c.G,$c.B
    }
    [bool] Equals([Object] $obj) {
        return $this.HEX -eq ([Color]$obj).HEX
    }
}

function New-Color{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        $p
    )
    [Color]$p
}

function Find-Color{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen')]Param
    (
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Screen'  )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Size'    )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Window'  )]
        [Color]$Color
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
        [Parameter(Mandatory = $false,  ParameterSetName = 'Screen'  )]
        [Parameter(Mandatory = $false,  ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory = $false,  ParameterSetName = 'Size'    )]
        [Parameter(Mandatory = $false,  ParameterSetName = 'Window'  )]
        [ValidateRange(0.0, 1.0)]
        [Double]$deviation = 0.0
        ,
        [Int16]$Count = 1
        ,
        [Parameter(ParameterSetName = 'Screen')]
        [switch]$Screen
        ,
        [Parameter(ParameterSetName = 'Window')]
        [IntPtr]$Handle
    )
    #region Params Validating
    if($StartPos -isnot [Drawing.Point]){
        try{$StartPos = [Drawing.Point]::new.Invoke($StartPos)}catch{throw $_}
    }
    
    #endregion
    Switch ($PSCmdlet.ParameterSetName)
    {
        'Screen'
        {
            $rect = [Windows.Forms.Screen]::PrimaryScreen.Bounds
        }
        'EndPoint'
        {
            if(!$EndPos-is[Drawing.Point]){try{$EndPos=[Drawing.Point]::new.Invoke($EndPos)}catch{throw $_}}
            $rect = [Drawing.Rectangle]::new($StartPos, ($EndPos.X-$StartPos.X), ($EndPos.Y-$StartPos.Y))
        }
        'Size'
        {
            if(!$Size-is[Drawing.Size]){try{$Size=[Drawing.Size]::new.Invoke($Size)}catch{throw $_}}
            $rect = [Drawing.Rectangle]::new($StartPos, $Size)
        }
        'Window'
        {
            $scr = Get-Image -Handle $Handle
        }

    }

    $img = [System.Drawing.Bitmap]::new(1,1)
    $img.SetPixel(0,0,([Drawing.Color]::FromArgb($color)))
    
    if($PSCmdlet.ParameterSetName-ne'Window'){
        $scr = [System.Drawing.Bitmap]::new($Rect.Width, $Rect.Height)
        $gfx = [System.Drawing.Graphics]::FromImage($scr)
        $gfx.CopyFromScreen($Rect.Location,[Drawing.Point]::Empty,$Rect.Size)
    }

    $res = [ImgSearcher]::searchBitmap($img, $scr, $deviation, 100, $count)
    0..($res.Count-1)|%{$res[$_].location.X+=$rect.x;$res[$_].location.Y+=$rect.Y}
    $scr.Dispose()
    $img.Dispose()
    if($gfx){$gfx.Dispose()}
    return ,$res  
}

function Get-Color{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0)]
        $Position
        ,
        [IntPtr]$Handle = [IntPtr]::Zero
    )
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
    }
    $color = [psClickColor]::GetColor($Position.x, $Position.y, $handle)
    [color]::new($color.R,$color.G,$color.B)
}

function Cut-Image{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Rect')]Param
    (
        [Parameter(Mandatory,Position=0)][System.Drawing.Bitmap]
        $Image
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
            if(!$EndPos-is[Drawing.Point]){try{$EndPos=[Drawing.Point]::new.Invoke($EndPos)}catch{throw $_}}
            $rect = [Drawing.Rectangle]::new($StartPos, ($EndPos.X-$StartPos.X), ($EndPos.Y-$StartPos.Y))
        }
        'Size'
        {
            if(!$Size-is[Drawing.Size]){try{$Size=[Drawing.Size]::new.Invoke($Size)}catch{throw $_}}
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

function Get-Image{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen_FullSize')]Param
    (
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
        [String]$Path
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
        [System.Drawing.Rectangle]$Rect
    )
    if($EndX){
        if(!$EndPos-is[Drawing.Point]){try{$EndPos=[Drawing.Point]::new.Invoke($EndPos)}catch{throw $_}}
        $rect = [Drawing.Rectangle]::new($StartPos, ($EndPos.X-$StartPos.X), ($EndPos.Y-$StartPos.Y))
    }
    if($Width){
        if(!$Size-is[Drawing.Size]){try{$Size=[Drawing.Size]::new.Invoke($Size)}catch{throw $_}}
        $rect = [Drawing.Rectangle]::new($StartPos, $Size)
    }

    Switch -Wildcard ($PSCmdlet.ParameterSetName)
    {
        'Window*'
        {
            if($rect){
                return Cut-Image ([psClickColor]::GetImage($handle)) $rect
            }
            else{
                return [psClickColor]::GetImage($handle)
            }
        }
        'Screen*'
        {
            if(!$rect){$rect = [Windows.Forms.Screen]::PrimaryScreen.Bounds}
            $scr = [System.Drawing.Bitmap]::new($Rect.Width, $Rect.Height, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
            $gfx = [System.Drawing.Graphics]::FromImage($scr)
            $gfx.CopyFromScreen($rect.Location,[Drawing.Point]::Empty,$rect.Size)
            $gfx.Dispose()
            return $scr
        }
        'File*'
        {
            if($rect){
                return Cut-Image ([System.Drawing.Bitmap]::new($path)) $rect
            }
            else{
                return [System.Drawing.Bitmap]::new($path)
            }
        }
    }
}