function Find-Color{
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
        [ValidateRange(0.0, 1.0)]
        [Double]$deviation = 0.0
        ,
        [Parameter(ParameterSetName = 'Screen')]
        [Boolean]$Screen
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

    Switch ($PSCmdlet.ParameterSetName){
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
    $res.location.X+=$rect.x;$res.location.Y+=$rect.Y
    $scr.Dispose()
    $img.Dispose()
    $gfx.Dispose()
    return $res.location  
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

function Get-Image{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen')]Param
    (
        [Parameter(Mandatory,ParameterSetName = 'Window')]
        [IntPtr]$Handle
        ,
        [Parameter(Mandatory = $true,ParameterSetName = 'Screen')]
        [switch]$Screen
        ,
        [Parameter(Mandatory,Position=0,ParameterSetName = 'File')]
        [String]$Path
    )
    Switch ($PSCmdlet.ParameterSetName){
        'Window'
        {
            return [psClickColor]::GetImage($handle)
        }
        'Screen'
        {
            $rect = [Windows.Forms.Screen]::PrimaryScreen.Bounds
            $scr = [System.Drawing.Bitmap]::new($Rect.Width, $Rect.Height)
            $gfx = [System.Drawing.Graphics]::FromImage($scr)
            $gfx.CopyFromScreen($rect.Location,[Drawing.Point]::Empty,$rect.Size)
            $gfx.Dispose()
            return $scr
        }
        'File'
        {
            return [System.Drawing.Bitmap]::new($path)
        }
    }
}