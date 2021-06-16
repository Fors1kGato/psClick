function Click-Mouse
{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [Int]$X
        ,
        [parameter(Mandatory=$true)]
        [Int]$Y
        ,
        [switch]$Right
        ,
        [switch]$Middle
        ,
        [IntPtr]$Handle
        ,
        [switch]$Down
        ,
        [switch]$Up
        ,
        [Switch]$Double
        ,
        [Switch]$Tripple
        ,
        [Switch]$Event
        ,
        [ValidateSet('Shift','Control')]
        [String[]]$With = [string[]]::new(0)
    )
    #region Params Validating 
    if($Down -and $Up){
        Write-Error "-Down , -Up: Допускается только один параметр";return
    }
    if($Double -and $Tripple){
        Write-Error "-Double , -Tripple: Допускается только один параметр";return
    }
    if($Right -and $Middle){
        Write-Error "-Right , -Middle: Допускается только один параметр";return
    }
    if($event -and !$handle){
        Write-Error "-Event: Требуется указать handle окна";return
    }
    if(($Double-or$Tripple) -and ($Down-or$Up)){
        Write-Error "Для -Down/-Up не допускается -Double/-Tripple";return
    }
    $count = 1
    if($Double ){$count = 2}
    if($Tripple){$count = 3}
    #endregion
    #region Kleft 
    if(!$event){
        $button = "left"
        if($Right ){$button = "right" }
        if($Middle){$button = "Middle"}
        if($Handle){
            $pt = [Drawing.Point]::new($x,$y)
            [Void][w32Windos]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$pt, 1)
            $x = $pt.X ; $y = $pt.Y
        }
        $w = @{'Shift' = 0x10;'Control' = 0x11}
        Move-Cursor $x $y
        $with|%{[w32KeyBoard]::keybd_event($w.$_, 0, 0x0000, 0)}
        if($Down){
            [w32Mouse]::mouse_event([w32Mouse+MouseEventFlags]::"MOUSEEVENTF_$button`DOWN",0,0,0,0)
        }
        elseif($Up){
            [w32Mouse]::mouse_event([w32Mouse+MouseEventFlags]::"MOUSEEVENTF_$button`UP",  0,0,0,0)
        }
        else{
            1..$count|%{
                [w32Mouse]::mouse_event(
                    ([w32Mouse+MouseEventFlags]::"MOUSEEVENTF_$button`DOWN" -bor
                    [w32Mouse+MouseEventFlags]::"MOUSEEVENTF_$button`UP"),0,0,0,0
                )
            }
        }
        $with|%{[w32KeyBoard]::keybd_event($w.$_, 0, 0x0002, 0)}
    }
    #endregion
    #region left 
    else{
        $button = 0x0201
        if($Right ){$button = 0x0204}
        if($Middle){$button = 0x0207}
        $wParams = 0
        $w = @{'Shift'=0x0004;'Control'=0x0008}
        $with|%{$wParams+=$w.$_}
        if($Down){
            if(![w32]::PostMessage($handle, $button,   $wParams, ($x + 0x10000 * $y))){
                [w32]::SendMessage($handle, $button,   $wParams, ($x + 0x10000 * $y))|Out-Null 
            }
        }
        elseif($Up){
            if(![w32]::PostMessage($handle, $button+1, $wParams, ($x + 0x10000 * $y))){ 
                [w32]::SendMessage($handle, $button+1, $wParams, ($x + 0x10000 * $y))|Out-Null
            }
        }
        else{
            1..$count|%{    
                if ([w32]::PostMessage($handle, $button,   $wParams, ($x + 0x10000 * $y))){
                    [w32]::PostMessage($handle, $button+1, $wParams, ($x + 0x10000 * $y))|Out-Null 
                }
                else{
                    [w32]::SendMessage($handle, $button,   $wParams, ($x + 0x10000 * $y))|Out-Null
                    [w32]::SendMessage($handle, $button+1, $wParams, ($x + 0x10000 * $y))|Out-Null
                }
            }
        }
    }
    #endregion
}