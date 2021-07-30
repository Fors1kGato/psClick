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
        $color
    )
    [Color]$color
}

function Get-Color
{
    #.COMPONENT
    #1.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen')]
    Param(
        [Parameter(Mandatory, Position=0,ParameterSetName = 'Screen')]
        [Parameter(Mandatory, Position=0,ParameterSetName = 'Window')]
        $Position
        ,
        [Parameter(Mandatory,ParameterSetName = 'Window'  )]
        [IntPtr]$Handle = [IntPtr]::Zero
        ,
        [Parameter(ParameterSetName = 'Window')]
        [Switch]$Visible
        ,
        [Parameter(ParameterSetName = 'Screen')]
        [Switch]$Screen
    )
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
    }
    if($Visible){
        [Void][w32Windos]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$Position, 1)
        $Handle = [IntPtr]::Zero
    }
    $color = [psClickColor]::GetColor($Position.x, $Position.y, $handle)
    [color]::new($color.R,$color.G,$color.B)
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
    #2.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen_FullSize')]
    Param
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
    )

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
                return $scr
            }
            else{
                if( $rect ){
                    return Cut-Image ([psClickColor]::GetImage($handle)) -Rect $rect
                }
                else{
                    return [psClickColor]::GetImage($handle)
                }
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
                return ($path|ForEach{Cut-Image ([Drawing.Bitmap]::new($_)) -Rect $rect})
            }
            else{
                return ($path|ForEach{[Drawing.Bitmap]::new($_)})
            }
        }
    }
}