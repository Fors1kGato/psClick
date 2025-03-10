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

function Start-Wait()
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [ValidateRange(1, 999999)]
        [Parameter(Mandatory, Position=0)]
        [Int]$Wait 
        ,
        [Parameter(Position=1, ParameterSetName = "SerialPort")]
        [System.IO.Ports.SerialPort]$Port               
    )
      
    if($Port){         
        $Port.Write("06" + ($Wait - 1))
        while($Port.BytesToRead-lt5){}  
        [byte[]]$result = 0,0,0,0,0
        $Port.Read($result, 0, 5)|Out-Null
    }
    else{    
        $portName = @(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.
                    Properties|where{$_.name -like  '*USB*'}).value)[0].replace("COM","")
        $arduino = [psClick.Arduino]::Open($PortName)
        $error = "Не удалось открыть порт. Err code: $arduino"
        if([Int]$arduino -le 0){throw $error}    
        Send-ArduinoCommand $arduino ("06" + ($Wait - 1)) -Wait ($Wait + 5000)
        [Void][psClick.Arduino]::Close($arduino)
    }
}