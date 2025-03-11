function Set-ArduinoSetting
{
    #.COMPONENT
    #1.3
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Position=0)]
        [System.IO.Ports.SerialPort]$Port
        ,
        [parameter(ParameterSetName = "cus")]
        [Int16]$MouseDelay = -1
        ,
        [parameter(ParameterSetName = "cus")]
        [Int16]$MouseMoveDelay = -1
        ,
        [ValidateRange(1, 127)]
        [parameter(ParameterSetName = "cus")]
        [Int16]$MouseMoveOffset = -1
        ,
        [parameter(ParameterSetName = "cus")]
        [Int16]$KeyRandomDelay = -1
        ,
        [parameter(ParameterSetName = "cus")]
        [Int16]$MouseRandomDelay = -1
        ,
        [parameter(Mandatory,ParameterSetName = "def")]
        [Switch]$Default
    )

    if($Port){    
        [byte[]]$result = 0,0,0,0,0    
        
        if($Default){
            $Port.Write("0120")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null

            $Port.Write("020")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null

            $Port.Write("035")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null

            $Port.Write("040")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null

            $Port.Write("050")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null
        }
        if($MouseDelay -gt -1){          
            $Port.Write("01$MouseDelay")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null
        }
        if($MousemoveDelay -gt -1){
            $Port.Write("02$mousemoveDelay")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null
        }
        if($MousemoveOffset -gt -1){
            $Port.Write("03$mousemoveOffset")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null
        }
        if($KeyRandomDelay -gt -1){
            $Port.Write("04$keyRandomDelay")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null
        }
        if($MouseRandomDelay -gt -1){
            $Port.Write("05$MouseRandomDelay")
            while($port.BytesToRead-lt5){}       
            $port.Read($result, 0, 5)|Out-Null
        }                                   
    }
    else{
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
        if($MouseDelay -gt -1){
            Send-ArduinoCommand $arduino "01$mouseDelay"
        }
        if($MousemoveDelay -gt -1){
            Send-ArduinoCommand $arduino "02$mousemoveDelay"
        }
        if($MousemoveOffset -gt -1){
            Send-ArduinoCommand $arduino "03$mousemoveOffset"
        }
        if($KeyRandomDelay -gt -1){
            Send-ArduinoCommand $arduino "04$keyRandomDelay"
        }
        if($MouseRandomDelay -gt -1){
            Send-ArduinoCommand $arduino "05$MouseRandomDelay"
        }

        [Void][psClick.Arduino]::Close($arduino)
    }
}

function Get-ArduinoSetting
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Position=0)]
        [System.IO.Ports.SerialPort]$Port               
    )
          
    if($Port){         
        $Port.Write("07")
        while($port.BytesToRead-lt1){} 
        $res = $port.ReadLine()
    }
    else{    
        $portName = @(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.
                    Properties|where{$_.name -like  '*USB*'}).value)[0].replace("COM","")
        $port = [System.IO.Ports.SerialPort]::new("COM$portName", 9600)
        $port.RtsEnable = $true
        $port.ReadTimeout = 3000
        $port.Open()
        $port.Write("07") 

        while($port.BytesToRead-lt1){} 
        $res =  $port.ReadLine()

        $port.Close();$port.Dispose()
    }

    $values = [regex]::Matches($res, "\d+")
    $Result = [ordered]@{
        MouseDelay = $values[0].Value
        MouseMoveDelay = $values[1].Value
        MouseMoveOffset = $values[2].Value
        KeyRandomDelay = $values[3].Value
        MouseRandomDelay = $values[4].Value
    }
    $Result
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

function Start-Wait
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
        [Parameter(Position=1)]
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