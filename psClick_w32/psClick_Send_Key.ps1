function Send-Key
{
    #.COMPONENT
    #2.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    Param(
        [parameter(Mandatory,ParameterSetName = "Event_Click")]
        [parameter(Mandatory,ParameterSetName = "Event_Down")]
        [parameter(Mandatory,ParameterSetName = "Event_Up")]
        [IntPtr]$Handle
        ,
        [parameter(Mandatory,ParameterSetName = "Sys_Down")]
        [parameter(Mandatory,ParameterSetName = "Hardware_Down")]
        [parameter(Mandatory,ParameterSetName = "Event_Down")]
        [Switch]$Down
        ,
        [parameter(Mandatory,ParameterSetName = "Sys_Up")]
        [parameter(Mandatory,ParameterSetName = "Hardware_Up")]
        [parameter(Mandatory,ParameterSetName = "Event_Up")]
        [Switch]$Up
        ,
        [parameter(Mandatory,ParameterSetName = "Hardware_Click")]
        [parameter(Mandatory,ParameterSetName = "Hardware_Down")]
        [parameter(Mandatory,ParameterSetName = "Hardware_Up")]
        [Switch]$Hardware
        ,
        [parameter(ParameterSetName = "Sys_Down")]
        [parameter(ParameterSetName = "Hardware_Down")]
        [parameter(ParameterSetName = "Event_Down")]
        [UInt16]$Delay = 32
        ,
        [parameter(ParameterSetName = "Hardware_Click")]
        [parameter(ParameterSetName = "Hardware_Down")]
        [parameter(ParameterSetName = "Hardware_Up")]
        [UInt16]$Wait = 5000
    )
    DynamicParam {
        $attribute = [Management.Automation.ParameterAttribute]::new()
        $attribute.Mandatory = $true
        $attribute.Position = 0

        $collection = [Collections.ObjectModel.Collection[System.Attribute]]::new()
        $collection.Add($attribute)

        if($Hardware){
            $validationSet = [String[]]('D0','D1','D2','D3','D4','D5','D6','D7','D8','D9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','Alt','Capital','CapsLock','Delete','Down','End','Enter','Escape','F1','F10','F11','F12','F13','F14','F15','F16','F17','F18','F19','F2','F20','F21','F22','F23','F24','F3','F4','F5','F6','F7','F8','F9','Home','Insert','LControlKey','Left','LShiftKey','LWin','PageDown','PageUp','RControlKey','Return','Right','RShiftKey','RWin','Tab','Up')
        }
        else{
            $validationSet = [String[]]('None','LButton','RButton','Cancel','MButton','XButton1','XButton2','Back','Tab','LineFeed','Clear','Enter','Return','ShiftKey','ControlKey','Menu','Pause','CapsLock','Capital','HangulMode','HanguelMode','KanaMode','JunjaMode','FinalMode','KanjiMode','HanjaMode','Escape','IMEConvert','IMENonconvert','IMEAccept','IMEAceept','IMEModeChange','Space','Prior','PageUp','PageDown','Next','End','Home','Left','Up','Right','Down','Select','Print','Execute','Snapshot','PrintScreen','Insert','Delete','Help','D0','D1','D2','D3','D4','D5','D6','D7','D8','D9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','LWin','RWin','Apps','Sleep','NumPad0','NumPad1','NumPad2','NumPad3','NumPad4','NumPad5','NumPad6','NumPad7','NumPad8','NumPad9','Multiply','Add','Separator','Subtract','Decimal','Divide','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','F13','F14','F15','F16','F17','F18','F19','F20','F21','F22','F23','F24','NumLock','Scroll','LShiftKey','RShiftKey','LControlKey','RControlKey','LMenu','RMenu','BrowserBack','BrowserForward','BrowserRefresh','BrowserStop','BrowserSearch','BrowserFavorites','BrowserHome','VolumeMute','VolumeDown','VolumeUp','MediaNextTrack','MediaPreviousTrack','MediaStop','MediaPlayPause','LaunchMail','SelectMedia','LaunchApplication1','LaunchApplication2','OemSemicolon','Oem1','Oemplus','Oemcomma','OemMinus','OemPeriod','Oem2','OemQuestion','Oem3','Oemtilde','Oem4','OemOpenBrackets','OemPipe','Oem5','OemCloseBrackets','Oem6','OemQuotes','Oem7','Oem8','Oem102','OemBackslash','ProcessKey','Packet','Attn','Crsel','Exsel','EraseEof','Play','Zoom','NoName','Pa1','OemClear','KeyCode','Shift','Control','Alt','Modifiers')
        }
        $collection.Add(([Management.Automation.ValidateSetAttribute]::new($validationSet)))  

        $param = [Management.Automation.RuntimeDefinedParameter]::new('Key', [string], $collection)
        $dictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
        $dictionary.Add('Key', $param)  

        return $dictionary
    }

    process{
        $key = $PSBoundParameters.key
        #region keybd_event 
        if(!$Handle){
            if($Hardware){
                $portName = @(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.
                            Properties|where{$_.name -like  '*USB*'}).value)[0].replace("COM","")
                $arduino = [arduino]::Open($PortName)
                $error = "Не удалось открыть порт. Err code: $arduino"
                if([int]$arduino -le 0){throw $error}

                if($key -match "^\p{L}$"){
                    $hKey = [Windows.Forms.Keys]::$key.value__+32
                }
                elseif($key -match "^D\d$"){
                    $hKey = [Windows.Forms.Keys]::$key.value__
                }
                else{
                    $hKey = @{
                        LControlKey = 0x80
                        LShiftKey   = 0x81
                        Alt         = 0x82
                        LWin        = 0x83
                        RControlKey = 0x84
                        RShiftKey   = 0x85
                        RWin        = 0x87
                        Up          = 0xDA
                        Down        = 0xD9
                        Left        = 0xD8
                        Right       = 0xD7
                        Tab         = 0xB3
                        Enter       = 0xB0
                        Return      = 0xB0
                        Escape      = 0xB1
                        Insert      = 0xD1
                        Delete      = 0xD4
                        PageUp      = 0xD3
                        PageDown    = 0xD6
                        Home        = 0xD2
                        End         = 0xD5
                        CapsLock    = 0xC1
                        Capital     = 0xC1
                        F1          = 0xC2
                        F2          = 0xC3
                        F3          = 0xC4
                        F4          = 0xC5
                        F5          = 0xC6
                        F6          = 0xC7
                        F7          = 0xC8
                        F8          = 0xC9
                        F9          = 0xCA
                        F10         = 0xCB
                        F11         = 0xCC
                        F12         = 0xCD
                        F13         = 0xF0
                        F14         = 0xF1
                        F15         = 0xF2
                        F16         = 0xF3
                        F17         = 0xF4
                        F18         = 0xF5
                        F19         = 0xF6
                        F20         = 0xF7
                        F21         = 0xF8
                        F22         = 0xF9
                        F23         = 0xFA
                        F24         = 0xFB
                    }.$key
                }

                if($down){Send-ArduinoCommand $arduino "3$hKey" $Wait}
                elseif($up){Send-ArduinoCommand $arduino "4$hKey" $Wait}
                else{Send-ArduinoCommand $arduino "1$hKey" $Wait}
                if($Hardware){[arduino]::Close($arduino)}
            }
            else{
                if($down){
                    if($key -match "(alt|Control|Shift|win)"){
                        [w32KeyBoard]::keybd_event([Windows.Forms.Keys]::$key, 0, 0x0000, 0)
                    }
                    else{
                        Start-ThreadJob -Name "$key`_Down" {
                            while($true){
                                [w32KeyBoard]::keybd_event([Windows.Forms.Keys]::[string]$args[1], 0, 0x0000, 0)
                                [w32KeyBoard]::keybd_event([Windows.Forms.Keys]::[string]$args[1], 0, 0x0002, 0)
                                sleep -m $args[0]
                            }
                        } -ArgumentList $delay, $key|Out-Null
                    }
                }
                elseif($up){
                    if($key -match "(alt|Control|Shift|win)"){
                        [w32KeyBoard]::keybd_event([Windows.Forms.Keys]::$key, 0, 0x0002, 0)
                    }
                    else{
                        Remove-Job -Name "$key`_Down" -Force
                    }
                }
                else{
                    [w32KeyBoard]::keybd_event([Windows.Forms.Keys]::$key, 0, 0x0000, 0)
                    [w32KeyBoard]::keybd_event([Windows.Forms.Keys]::$key, 0, 0x0002, 0)
                }
            }
        }
        #endregion
        #region Message 
        else{ 
            if($Down){
                Start-ThreadJob -Name "$key`_Down_Event" {
                    while($true){
                        if ([w32]::PostMessage([IntPtr]$args[2] ,0x0100, [Windows.Forms.Keys]::[string]$args[1], 0)){
                            #[w32]::PostMessage($handle ,0x0101, [Windows.Forms.Keys]::[string]$args[1], 0)|Out-Null 
                        }
                        else{
                            [w32]::SendMessage([IntPtr]$args[2] ,0x0100, [Windows.Forms.Keys]::[string]$args[1], 0)|Out-Null
                            #[w32]::SendMessage($handle ,0x0101, [Windows.Forms.Keys]::[string]$args[1], 0)|Out-Null
                        }
                        sleep -m $args[0]
                    }
                } -ArgumentList $delay, $key, $Handle|Out-Null
            }
            elseif($Up){
                Remove-Job -Name "$key`_Down_Event" -Force
            }
            else{  
                if ([w32]::PostMessage($handle ,0x0100, [Windows.Forms.Keys]::$key, 0)){
                    #[w32]::PostMessage($handle ,0x0101, [Windows.Forms.Keys]::$key, 0)|Out-Null 
                }
                else{
                    [w32]::SendMessage($handle ,0x0100, [Windows.Forms.Keys]::$key, 0)|Out-Null
                    #[w32]::SendMessage($handle ,0x0101, [Windows.Forms.Keys]::$key, 0)|Out-Null
                }
            }
        }
        #endregion
    }
}