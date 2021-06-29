function Find-Color{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen')]Param
    (
        [Parameter(Mandatory=$true,ParameterSetName = 'Screen')]
        [Parameter(Mandatory=$true,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory=$true,ParameterSetName = 'Size')]
        [Parameter(Position = 0)]
        [Object[]]$Color
        ,
        [Parameter(Mandatory=$true,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory=$true,ParameterSetName = 'Size')]
        [Parameter(Position = 1)]
        [int]$StartX
        ,
        [Parameter(Mandatory=$true,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory=$true,ParameterSetName = 'Size')]
        [Parameter(Position = 2)]
        [int]$StartY
        ,
        [Parameter(Mandatory=$true,ParameterSetName = 'EndPoint')]
        [Parameter(Position = 3)]
        [int]$EndX
        ,
        [Parameter(Mandatory=$true,ParameterSetName = 'EndPoint')]
        [Parameter(Position = 4)]
        [int]$EndY
        ,
        [Parameter(Mandatory=$true,ParameterSetName = 'Size')]
        [Parameter(Position = 3)]
        [int]$Width
        ,
        [Parameter(Mandatory=$true,ParameterSetName = 'Size')]
        [Parameter(Position = 4)]
        [int]$Height
        ,
        [Parameter(Mandatory=$false,ParameterSetName = 'Screen')]
        [Parameter(Mandatory=$false,ParameterSetName = 'EndPoint')]
        [Parameter(Mandatory=$false,ParameterSetName = 'Size')]
        [ValidateRange(0.0, 1.0)]
        [Double]$deviation = 0.0
        ,
        [Parameter(ParameterSetName = 'Screen')]
        [Boolean]$Screen = $true
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
    }

    $img = [System.Drawing.Bitmap]::new(1,1)
    $img.SetPixel(0,0,$color)

    write-host $rect

    $scr = [System.Drawing.Bitmap]::new($Rect.Width, $Rect.Height)
    $gfx = [System.Drawing.Graphics]::FromImage($scr)
    $gfx.CopyFromScreen(
        $Rect.Location,
        [System.Drawing.Point]::Empty,
        $Rect.Size
    )

    $res = [ImgSearcher]::searchBitmap($img, $scr, $deviation, 100)
    $res.location.X+=$rect.x;$res.location.Y+=$rect.Y
    return $res.location
    $img.Dispose()
    $gfx.Dispose()
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

function Import-Image{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory = $true )]
        [string]$Path
    )
    [System.Drawing.Bitmap]::new($path)
}