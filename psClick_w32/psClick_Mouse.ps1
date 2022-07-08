function Set-ArduinoSetting
{
    #.COMPONENT
    #1.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(ParameterSetName = "cus")]
        [UInt16]$MouseDelay
        ,
        [parameter(ParameterSetName = "cus")]
        [UInt16]$MouseMoveDelay
        ,
        [ValidateRange(1, 127)]
        [parameter(ParameterSetName = "cus")]
        [UInt16]$MouseMoveOffset
        ,
        [parameter(ParameterSetName = "cus")]
        [UInt16]$KeyRandomDelay
        ,
        [parameter(ParameterSetName = "cus")]
        [UInt16]$MouseRandomDelay
        ,
        [parameter(Mandatory,ParameterSetName = "def")]
        [Switch]$Default
    )
    $portName = @(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.
                Properties|where{$_.name -like  '*USB*'}).value)[0].replace("COM","")
    $arduino = [psClick.Arduino]::Open($PortName)
    $error = "Не удалось открыть порт. Err code: $arduino"
    if([Int]$arduino -le 0){throw $error}

    if($Default){
        Send-ArduinoCommand $arduino "0120"
        Send-ArduinoCommand $arduino "020"
        Send-ArduinoCommand $arduino "035"
        Send-ArduinoCommand $arduino "040"
        Send-ArduinoCommand $arduino "050"
    }
    if($MouseDelay){
        Send-ArduinoCommand $arduino "01$mouseDelay"
    }
    if($MousemoveDelay){
        Send-ArduinoCommand $arduino "02$mousemoveDelay"
    }
    if($MousemoveOffset){
        Send-ArduinoCommand $arduino "03$mousemoveOffset"
    }
    if($KeyRandomDelay){
        Send-ArduinoCommand $arduino "04$keyRandomDelay"
    }
    if($MouseRandomDelay){
        Send-ArduinoCommand $arduino "05$MouseRandomDelay"
    }

    [Void][psClick.Arduino]::Close($arduino)
}

function Send-ArduinoCommand
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0)]
        [System.IntPtr]$Arduino
        ,
        [Parameter(Mandatory, Position=1)]
        [String]$Command 
        ,
        [Parameter(Position=2)]
        [UInt16]$Wait = 5000
    )
    if(![psClick.Arduino]::SendCommand($Arduino, $Command, $Wait)){
        [void][psClick.Arduino]::Close($Arduino)
        $error = "Arduino write/read error"
        throw $error 
    }
}

function Scroll-Mouse
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0, ParameterSetName = "SysUP")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "SysDown")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "HandleDown")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "HandleUP")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "HardwareDown")]
        [Parameter(Mandatory, Position=0, ParameterSetName = "HardwareUP")]
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
        [Switch]$Up
        ,
        [Parameter(Mandatory, ParameterSetName = "SysDown")]
        [Parameter(Mandatory, ParameterSetName = "HardwareDown")]
        [Parameter(Mandatory, ParameterSetName = "HandleDown")]
        [Switch]$Down
        ,
        [Parameter(Mandatory, ParameterSetName = "HardwareDown")]
        [Parameter(Mandatory, ParameterSetName = "HardwareUP")]
        [Switch]$Hardware
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
    #4.1
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
        [UInt16]$Wait = 5000
    )
    if($Position -isnot [Drawing.Point]){
        try{$Position = [Drawing.Point]::new.Invoke($Position)}catch{throw $_}
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

            $param  = "5{0}{1}{2}" -f (
                $(if($offset.x -ge 0){"+"}else{"-"}), 
                $(if($offset.y -ge 0){"+"}else{"-"}),
                $([Math]::Abs($offset.x) * 0xFFFF + [Math]::Abs($offset.y))
            )

            Send-ArduinoCommand $arduino $param $Wait
            if($Hardware){[void][psClick.Arduino]::Close($arduino)}
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
    #2.1
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
        [parameter(Mandatory, ParameterSetName = "Window")]
        [IntPtr]$Handle
        ,
        [parameter(ParameterSetName = "Window")]
        [Switch]$Event
        ,
        [parameter(Mandatory, ParameterSetName = "Hardware")]
        [Switch]$Hardware
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
        Click-Mouse $from -Hardware:$Hardware -Down 
        Sleep -m $Delay
        Click-Mouse $to -Hardware:$Hardware -Up
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