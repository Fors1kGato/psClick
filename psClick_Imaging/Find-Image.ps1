function Find-Image
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Screen_FullSize')]Param
    (
        [Parameter(Mandatory,Position=0)][Object]$Image
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
        [String]$Path
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_EndPoint'  )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Size'      )]
        [int]$StartX
        ,
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_EndPoint'  )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=3,ParameterSetName = 'File_Size'      )]
        [int]$StartY
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_EndPoint'  )]
        [int]$EndX
        ,
        [Parameter(Mandatory,Position=5,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=5,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=5,ParameterSetName = 'File_EndPoint'  )]
        [int]$EndY
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_Size'      )]
        [int]$Width
        ,
        [Parameter(Mandatory,Position=5,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=5,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=5,ParameterSetName = 'File_Size'      )]
        [int]$Height
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Rect'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Rect'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Rect'      )]
        [System.Drawing.Rectangle]$Rect
        ,
        [ValidateRange(0.0, 1.0)]
        [Double]$Deviation = 0.0
        ,
        [ValidateRange(0, 100)]
        [Int]$Accuracy = 100
    )

    if($Image -is [String]){$smallBmp = [Drawing.Bitmap]::new($Image)}else{$smallBmp = $Image}

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

    $res = [ImgSearcher]::searchBitmap($smallBmp, $bigBmp, $deviation, $accuracy)

    if($Image -is [String]){$smallBmp.Dispose()}
    $bigBmp.Dispose()
    return $res
}