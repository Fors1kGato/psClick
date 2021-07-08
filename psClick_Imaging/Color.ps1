﻿function Find-Color{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen')]Param
    (
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Screen'  )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Size'    )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'Window'  )]
        [Object[]]$Color
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Size'    )]
        [int]$StartX
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Size'    )]
        [int]$StartY
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'EndPoint')]
        [int]$EndX
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'EndPoint')]
        [int]$EndY
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Size'    )]
        [int]$Width
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Size'    )]
        [int]$Height
        ,
        [Parameter(Mandatory = $false,  ParameterSetName = 'Screen'  )]
        [Parameter(Mandatory = $false,  ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory = $false,  ParameterSetName = 'Size'    )]
        [Parameter(Mandatory = $false,  ParameterSetName = 'Window'  )]
        [ValidateRange(0.0, 1.0)]
        [Double]$deviation = 0.0
        ,
        [Parameter(ParameterSetName = 'Screen')]
        [switch]$Screen
        ,
        [Parameter(ParameterSetName = 'Window')]
        [IntPtr]$Handle
    )
    try{
        if($color.count-eq 1)
        {[Drawing.Color]$Color = [Drawing.Color]::FromArgb($color[0])}
        else
        {[Drawing.Color]$Color = [Drawing.Color]::FromArgb($color[0],$color[1],$color[2])}
    }
    catch{Write-Error "Неверно указан цвет";return}

    Switch ($PSCmdlet.ParameterSetName)
    {
        'Screen'
        {
            $rect = [Windows.Forms.Screen]::PrimaryScreen.Bounds
        }
        'EndPoint'
        {
            $rect = [Drawing.Rectangle]::new($StartX, $StartY, ($EndX-$StartX), ($EndY-$StartY))
        }
        'Size'
        {
            $rect = [Drawing.Rectangle]::new($StartX, $StartY, $Width, $Height)
        }
        'Window'
        {
            $scr = Get-Image -Handle $Handle
        }

    }

    $img = [System.Drawing.Bitmap]::new(1,1)
    $img.SetPixel(0,0,$color)
    
    if($PSCmdlet.ParameterSetName-ne'Window'){
        $scr = [System.Drawing.Bitmap]::new($Rect.Width, $Rect.Height)
        $gfx = [System.Drawing.Graphics]::FromImage($scr)
        $gfx.CopyFromScreen($Rect.Location,[Drawing.Point]::Empty,$Rect.Size)
    }

    $res = [ImgSearcher]::searchBitmap($img, $scr, $deviation, 100)
    $res.Location.X+=$rect.x;$res.Location.Y+=$rect.Y
    $scr.Dispose()
    $img.Dispose()
    if($gfx){$gfx.Dispose()}
    return $res  
}

function Get-Color{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [int]$X,
        [int]$Y,
        [IntPtr]$Handle = [IntPtr]::Zero
    )
    [psClickColor]::GetColor($x, $y, $handle)
}

function Resize-Image{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Rect')]Param
    (
        [Parameter(Mandatory,Position=0)][System.Drawing.Bitmap]$Image
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Size'    )]
        [int]$StartX
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Size'    )]
        [int]$StartY
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'EndPoint')]
        [int]$EndX
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'EndPoint')]
        [int]$EndY
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Size'    )]
        [int]$Width
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Size'    )]
        [int]$Height
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
            $rect = [Drawing.Rectangle]::new($StartX, $StartY, ($EndX-$StartX), ($EndY-$StartY))
        }
        'Size'
        {
            $rect = [Drawing.Rectangle]::new($StartX, $StartY, $Width, $Height)
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
    #1
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
        [int]$StartX
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_EndPoint'  )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Size'      )]
        [int]$StartY
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_EndPoint'  )]
        [int]$EndX
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_EndPoint'  )]
        [int]$EndY
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_Size'      )]
        [int]$Width
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_Size'      )]
        [int]$Height
        ,
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Window_Rect'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'Screen_Rect'    )]
        [Parameter(Mandatory,Position=1,ParameterSetName = 'File_Rect'      )]
        [System.Drawing.Rectangle]$Rect
    )
    if($EndX){
        $rect = [Drawing.Rectangle]::new($StartX, $StartY, ($EndX-$StartX), ($EndY-$StartY))
    }
    if($Width){
        $rect = [Drawing.Rectangle]::new($StartX, $StartY, $Width, $Height)
    }

    Switch -Wildcard ($PSCmdlet.ParameterSetName)
    {
        'Window*'
        {
            if($rect){
                return Resize-Image ([psClickColor]::GetImage($handle)) $rect
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
                return Resize-Image ([System.Drawing.Bitmap]::new($path)) $rect
            }
            else{
                return [System.Drawing.Bitmap]::new($path)
            }
        }
    }
}