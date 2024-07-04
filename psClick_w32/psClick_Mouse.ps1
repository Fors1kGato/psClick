function Scroll-Mouse
{
    #.COMPONENT
    #2.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0, ParameterSetName = "SysUP")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "SysDown")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "HandleDown")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "HandleUP")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "HardwareDown")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "HardwareUP")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "DriverDown")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "DriverUP")]
        $Position
        ,
        [Parameter(Mandatory, ParameterSetName = "HandleDown")]
        [Parameter(Mandatory, ParameterSetName = "HandleUP")]
        [IntPtr]$Handle
        ,
        [Parameter(Position=1)]
        [Int]$Steps = 1
        ,
        [Parameter(ParameterSetName = "HandleDown")]
        [Parameter(ParameterSetName = "HandleUP")]
        [Switch]$Abs
        ,
        [Parameter(Mandatory, ParameterSetName = "SysUP")]
        [Parameter(Mandatory, ParameterSetName = "HandleUP")]
        [Parameter(Mandatory, ParameterSetName = "HardwareUP")]
        [Parameter(Mandatory, ParameterSetName = "DriverUP")]
        [Switch]$Up
        ,
        [Parameter(Mandatory, ParameterSetName = "SysDown")]
        [Parameter(Mandatory, ParameterSetName = "HardwareDown")]
        [Parameter(Mandatory, ParameterSetName = "HandleDown")]
        [Parameter(Mandatory, ParameterSetName = "DriverDown")]
        [Switch]$Down
        ,
        [Parameter(Mandatory, ParameterSetName = "HardwareDown")]
        [Parameter(Mandatory, ParameterSetName = "HardwareUP")]
        [Switch]$Hardware
        ,
        [Parameter(Mandatory, ParameterSetName = "DriverDown")]
        [Parameter(Mandatory, ParameterSetName = "DriverUP")]
        [Switch]$Driver
        ,
        [Parameter(ParameterSetName = "HardwareDown")]
        [Parameter(ParameterSetName = "HardwareUP")]
        [UInt16]$Wait = 5000
    )
    $WM_MOUSEWHEEL = 0x020A 
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
    }
    if($Down){$Steps = -$Steps}

    if($Handle){
        if($Abs){[Void][psClick.User32]::MapWindowPoints($handle, [IntPtr]::Zero, [ref]$Position, 1)}
        [Void][psClick.User32]::SendMessage($handle, $WM_MOUSEWHEEL, (120 * $Steps -shl 16), ($Position.x + ($Position.y -shl 16)))
    }
    else{
        if($Hardware){
            Move-Cursor $Position -Hardware
            $portName = @(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.
                        Properties|where{$_.Name -like  '*USB*'}).Value)[0].Replace("COM","")
            $arduino = [psClick.Arduino]::Open($PortName)
            $error = "Не удалось открыть порт. Err code: $arduino"
            if([Int]$arduino -le 0){throw $error}

            Send-ArduinoCommand $arduino "9$Steps" $Wait

            [Void][psClick.Arduino]::Close($arduino)
        }
        elseif($Driver){
            Move-Cursor $Position -Driver
            if($Down){$Steps|%{[psClick.Mouse]::MouseScroll([psClick.Hardware.MouseState]::ScrollDown)}}
            if($Up){$Steps|%{[psClick.Mouse]::MouseScroll([psClick.Hardware.MouseState]::ScrollUp)}}
        }
        else{
            Move-Cursor $Position
            [psClick.User32]::mouse_event([psClick.User32+MouseEventFlags]::MOUSEEVENTF_WHEEL, 0, 0, (120 * $Steps), 0)
        }
    }
}

function Get-CursorHandle
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    $cursorinfo = [psClick.User32+CURSORINFO]::new()
    $cursorinfo.cbSize = [Runtime.InteropServices.Marshal]::SizeOf([type][psClick.User32+CURSORINFO])
    [void][psClick.User32]::GetCursorInfo([ref]$cursorinfo)
    $cursorinfo.hCursor
}

function Move-Cursor
{
    #.COMPONENT
    #4.3
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'ScreenCursor')]
    Param(
        [Parameter(Mandatory,Position=0,ParameterSetName = 'ScreenEvent' )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'ScreenCursor')]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'WindowEvent' )]
        [Parameter(Mandatory,Position=0,ParameterSetName = 'WindowCursor')]
        $Position
        ,
        [Parameter(Mandatory,ParameterSetName = 'WindowEvent' )]
        [Parameter(Mandatory,ParameterSetName = 'WindowCursor')]
        [IntPtr]$Handle
        ,
        [Parameter(Mandatory,ParameterSetName = 'WindowEvent' )]
        [Switch]$Event
        ,
        [Parameter(ParameterSetName = 'ScreenCursor')]
        [Parameter(ParameterSetName = 'WindowCursor')]
        [Switch]$Hardware
        ,
        [Parameter(ParameterSetName = 'ScreenCursor')]
        [Parameter(ParameterSetName = 'WindowCursor')]
        [Switch]$Driver
        ,
        [Parameter(ParameterSetName = 'ScreenCursor')]
        [Parameter(ParameterSetName = 'WindowCursor')]
        [UInt16]$Wait = 5000
    )

    $StepMouse = @(
        0.03125,
        0.0625,
        0.125,
        0.25,
        0.375,
        0.5,
        0.625,
        0.75,
        0.875, 
        1.0,
        1.25,
        1.5,
        1.75,
        2.0,
        2.25,
        2.5,
        2.75,
        3.0,
        3.25,
        3.5
    )
    
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
    }

    if($Hardware -and $Driver){
        Write-Error "-Hardware, -Driver: Допускается только один параметр";return
    }

    if($Event){
        if(![psClick.User32]::PostMessage($handle, 0x0200, 0, ($Position.X + 0x10000 * $Position.Y))){
            [psClick.User32]::SendMessage($handle, 0x0200, 0, ($Position.X + 0x10000 * $Position.Y))|Out-Null 
        }
    }
    else{
        if($handle){
            [Void][psClick.User32]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$Position, 1)
        }

        if($Hardware){
            $portName = @(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.
                        Properties|where{$_.name -like  '*USB*'}).value)[0].replace("COM","")
            $arduino = [psClick.Arduino]::Open($PortName)
            $error = "Не удалось открыть порт. Err code: $arduino"
            if([Int]$arduino -le 0){throw $error}

            $offset = $Position - [System.Windows.Forms.Cursor]::Position
            $offset.X /= $StepMouse[(Get-MouseSpeed)-1]
            $offset.Y /= $StepMouse[(Get-MouseSpeed)-1]

            $param  = "5{0}{1}{2}" -f (
                $(if($offset.x -ge 0){"+"}else{"-"}), 
                $(if($offset.y -ge 0){"+"}else{"-"}),
                $([Math]::Abs($offset.x) * 0xFFFF + [Math]::Abs($offset.y))
            )

            Send-ArduinoCommand $arduino $param $Wait
            if($Hardware){[void][psClick.Arduino]::Close($arduino)}
        }
        elseif($Driver){
            [psClick.Mouse]::MouseMove($Position)        
        }
        else{
            [Windows.Forms.Cursor]::Position = $Position
        }
    }
}

function Get-MouseSpeed
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    [psClick.Mouse]::getMSpeed()
}

function Set-MouseSpeed
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        $speed
    )
    [psClick.Mouse]::setMSpeed($speed)
}

function Get-CursorPosition
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [IntPtr]$Handle
    )
    $Position = [Windows.Forms.Cursor]::Position
    if($Handle){
        [Void][psClick.User32]::MapWindowPoints([IntPtr]::Zero, $Handle, [ref]$Position, 1)
    }
    $Position
}

function Drag-WithMouse
{
    #.COMPONENT
    #2.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    Param(
        [parameter(Mandatory, Position = 0)]
        $From
        ,
        [parameter(Mandatory, Position = 1)]
        $To
        ,
        [parameter(ParameterSetName = "Hardware")]
        [parameter(ParameterSetName = "Driver")]
        [parameter(Mandatory, ParameterSetName = "Window")]
        [IntPtr]$Handle
        ,
        [parameter(ParameterSetName = "Window")]
        [Switch]$Event
        ,
        [parameter(Mandatory, ParameterSetName = "Hardware")]
        [Switch]$Hardware
        ,
        [parameter(Mandatory, ParameterSetName = "Driver")]
        [Switch]$Driver
        ,
        [UInt16]$Delay = 64
        ,
        [parameter(ParameterSetName = "Hardware")]
        [UInt16]$Wait = 5000
    )
    if($From -isnot [Drawing.Point]){
        try{$From = [Drawing.Point]::new.Invoke($From)}catch{throw $_}
    }
    if($To -isnot [Drawing.Point]){
        try{$To = [Drawing.Point]::new.Invoke($To)}catch{throw $_}
    }
    if(!$event){
        if($Handle){
            [Void][psClick.User32]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$from, 1)
            [Void][psClick.User32]::MapWindowPoints($Handle, [IntPtr]::Zero, [ref]$to  , 1)
        }
        if($Hardware){
            Click-Mouse $from -Hardware -Down 
            Sleep -m $Delay
            Click-Mouse $to -Hardware -Up
        }
        elseif($Driver){
            Click-Mouse $from -Driver -Down
            Sleep -m $Delay
            Move-Cursor $to -Driver
            Click-Mouse $to -Driver -Up
        }
        else{
            Click-Mouse $from -Down 
            Sleep -m $Delay
            Click-Mouse $to -Up
        }
    }
    else{   
        if ([psClick.User32]::PostMessage($handle, 0x0201, $wParams, ($From.X + 0x10000 * $From.Y))){
            Sleep -m $Delay
            [psClick.User32]::PostMessage($handle, 0x0200, $wParams, ($to.X   + 0x10000 * $to.Y  ))|Out-Null
            
            [psClick.User32]::PostMessage($handle, 0x0202, $wParams, ($to.X   + 0x10000 * $to.Y  ))|Out-Null 
        }
        else{
            [psClick.User32]::SendMessage($handle, 0x0201, $wParams, ($From.X + 0x10000 * $From.Y))|Out-Null
            Sleep -m $Delay
            [psClick.User32]::SendMessage($handle, 0x0200, $wParams, ($to.X   + 0x10000 * $to.Y  ))|Out-Null
            [psClick.User32]::SendMessage($handle, 0x0202, $wParams, ($to.X   + 0x10000 * $to.Y  ))|Out-Null
        }
    }
}