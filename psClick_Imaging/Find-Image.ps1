function Find-Image
{
    #.COMPONENT
    #2.1
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
        $StartPos
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_EndPoint')]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_EndPoint')]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_EndPoint'  )]
        $EndPos
        ,
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Window_Size'    )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'Screen_Size'    )]
        [Parameter(Mandatory,Position=4,ParameterSetName = 'File_Size'      )]
        $Size
        ,
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Window_Rect'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'Screen_Rect'    )]
        [Parameter(Mandatory,Position=2,ParameterSetName = 'File_Rect'      )]
        [System.Drawing.Rectangle]$Rect
        ,
        [Int16]$Count = 1
        ,
        [ValidateRange(0.0, 1.0)]
        [Double]$Deviation = 0.0
        ,
        [ValidateRange(0, 100)]
        [Int]$Accuracy = 100
    )

    if($Image -is [String]){$smallBmp = [Drawing.Bitmap]::new($Image)}else{$smallBmp = $Image}

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

    $res = [ImgSearcher]::searchBitmap($smallBmp, $bigBmp, $deviation, $accuracy, $count)

    if($Image -is [String]){$smallBmp.Dispose()}
    $bigBmp.Dispose()
    return ,$res
}