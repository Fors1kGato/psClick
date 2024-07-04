function Click-Mouse
{
    #.COMPONENT
    #1.7
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0)]
        $Position
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
        [Switch]$Hardware
        ,
        [Switch]$Driver
        ,
        [ValidateSet('Shift','Control')]
        [String[]]$With = [String[]]::new(0)
        ,
        [UInt16]$Wait = 5000
        ,
        [UInt16]$DelayUp = 64
    )
    #region Params Validating 
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
    }
    if($Down -and $Up){
        Write-Error "-Down , -Up: Допускается только один параметр";return
    }
    if($Hardware -and $Driver){
        Write-Error "-Hardware, -Driver: Допускается только один параметр";return
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
        if($Handle){
            [Void][psClick.User32]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$Position, 1)
        }
        if($Hardware){
            Move-Cursor $Position -Hardware
            $w = @{'Shift' = "129";'Control' = "128"}

            $portName = @(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.
                        Properties|where{$_.name -like  '*USB*'}).value)[0].replace("COM","")
            $arduino = [psClick.Arduino]::Open($PortName)
            $error = "Не удалось открыть порт. Err code: $arduino"
            if([Int]$arduino -le 0){throw $error}
            
            $button = 1
            if($Right ){$button = 2}
            if($Middle){$button = 4}

            $with|%{Send-ArduinoCommand $arduino "3$($w.$_)" $Wait}

            if($Down){Send-ArduinoCommand $arduino "7$button" $Wait}
            elseif($Up){Send-ArduinoCommand $arduino "8$button" $Wait}
            else{1..$count|%{Send-ArduinoCommand $arduino "6$button" $Wait}}

            $with|%{Send-ArduinoCommand $arduino "4$($w.$_)" $Wait}

            if($Hardware){[void][psClick.Arduino]::Close($arduino)}
        }
        elseif($Driver){
            $button = 1
            if($Right ){$button = 2}
            if($Middle){$button = 4}
            
            $w = @{'Shift' = 42;'Control' = 29}
            $with|%{[psClick.KeyBoard]::SendKey($w.$_, [psClick.Hardware.KeyState]::Down)}
            
            if($Down){[psClick.Mouse]::MouseDown($Position, $button)}
            elseif($Up){
                Sleep -m $DelayUP 
                [psClick.Mouse]::MouseUp($Position, $button)
            }
            else{1..$count|%{[psClick.Mouse]::MouseClick($Position, $button, $DelayUP)}}
            $with|%{[psClick.KeyBoard]::SendKey($w.$_, [psClick.Hardware.KeyState]::Up)}
        }
        else{
            $button = "left"
            if($Right ){$button = "right" }
            if($Middle){$button = "Middle"}
            
            $w = @{'Shift' = 0x10;'Control' = 0x11}
            Move-Cursor $Position
            $with|%{[psClick.User32]::keybd_event($w.$_, 0, 0x0000, 0)}

            if($Down){$dwFlags = [psClick.User32+MouseEventFlags]::"MOUSEEVENTF_$button`DOWN"}
            elseif($Up){Sleep -m $DelayUP;$dwFlags = [psClick.User32+MouseEventFlags]::"MOUSEEVENTF_$button`UP"}
            else{$dwFlags = [psClick.User32+MouseEventFlags]::"MOUSEEVENTF_$button`DOWN" -bor [psClick.User32+MouseEventFlags]::"MOUSEEVENTF_$button`UP"}
        
            1..$count|%{[psClick.User32]::mouse_event($dwFlags,0,0,0,0)}

            $with|%{[psClick.User32]::keybd_event($w.$_, 0, 0x0002, 0)}
        }
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
            if(![psClick.User32]::PostMessage($handle, $button,   $wParams, ($Position.x + 0x10000 * $Position.y))){
                [psClick.User32]::SendMessage($handle, $button,   $wParams, ($Position.x + 0x10000 * $Position.y))|Out-Null 
            }
        }
        elseif($Up){
            if(![psClick.User32]::PostMessage($handle, $button+1, $wParams, ($Position.x + 0x10000 * $Position.y))){ 
                [psClick.User32]::SendMessage($handle, $button+1, $wParams, ($Position.x + 0x10000 * $Position.y))|Out-Null
            }
        }
        else{
            1..$count|%{    
                if ([psClick.User32]::PostMessage($handle, $button,   $wParams, ($Position.x + 0x10000 * $Position.y))){
                    [psClick.User32]::PostMessage($handle, $button+1, $wParams, ($Position.x + 0x10000 * $Position.y))|Out-Null 
                }
                else{
                    [psClick.User32]::SendMessage($handle, $button,   $wParams, ($Position.x + 0x10000 * $Position.y))|Out-Null
                    [psClick.User32]::SendMessage($handle, $button+1, $wParams, ($Position.x + 0x10000 * $Position.y))|Out-Null
                }
            }
        }
    }
    #endregion
}