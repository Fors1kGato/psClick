function Send-Key
{
    #.COMPONENT
    #3.3
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
        [parameter(Mandatory,ParameterSetName = "Driver_Down")]
        [parameter(Mandatory,ParameterSetName = "Event_Down")]
        [Switch]$Down
        ,
        [parameter(Mandatory,ParameterSetName = "Sys_Up")]
        [parameter(Mandatory,ParameterSetName = "Hardware_Up")]
        [parameter(Mandatory,ParameterSetName = "Driver_Up")]
        [parameter(Mandatory,ParameterSetName = "Event_Up")]
        [Switch]$Up
        ,
        [parameter(Mandatory,ParameterSetName = "Hardware_Click")]
        [parameter(Mandatory,ParameterSetName = "Hardware_Down")]
        [parameter(Mandatory,ParameterSetName = "Hardware_Up")]
        [Switch]$Hardware
        ,
        [parameter(Mandatory,ParameterSetName = "Driver_Click")]
        [parameter(Mandatory,ParameterSetName = "Driver_Down")]
        [parameter(Mandatory,ParameterSetName = "Driver_Up")]
        [Switch]$Driver
        ,
        [parameter(ParameterSetName = "Sys_Down")]
        [parameter(ParameterSetName = "Hardware_Down")]
        [parameter(ParameterSetName = "Driver_Down")]
        [parameter(ParameterSetName = "Event_Down")]
        [UInt16]$Delay = 32
        ,
        [parameter(ParameterSetName = "Hardware_Click")]
        [parameter(ParameterSetName = "Hardware_Down")]
        [parameter(ParameterSetName = "Hardware_Up")]
        [UInt16]$Wait = 5000
        ,
        [UInt16]$Sleep
    )
    DynamicParam {
        $attribute = [Management.Automation.ParameterAttribute]::new()
        $attribute.Mandatory = $true
        $attribute.Position = 0

        $collection = [Collections.ObjectModel.Collection[System.Attribute]]::new()
        $collection.Add($attribute)

        if($Hardware){
            $validationSet = [String[]]('D0','D1','D2','D3','D4','D5','D6','D7','D8','D9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','Alt','Capital','CapsLock','Delete','Down','End','Enter','Escape','Space','F1','F10','F11','F12','F13','F14','F15','F16','F17','F18','F19','F2','F20','F21','F22','F23','F24','F3','F4','F5','F6','F7','F8','F9','Home','Insert','LControlKey','Left','LShiftKey','LWin','PageDown','PageUp','RControlKey','Return','Right','RShiftKey','RWin','Tab','Up','NumPad0','NumPad1','NumPad2','NumPad3','NumPad4','NumPad5','NumPad6','NumPad7','NumPad8','NumPad9','Multiply','Subtract','Decimal','Add','Divide')
        }
        elseif($Driver){
            $validationSet = [String[]]('Escape','One','Two','Three','Four','Five','Six','Seven','Eight','Nine','Zero','DashUnderscore','PlusEquals','Backspace','Tab','Q','W','E','R','T','Y','U','I','O','P','OpenBracketBrace','CloseBracketBrace','Enter','Control','A','S','D','F','G','H','J','K','L','SemicolonColon','SingleDoubleQuote','Tilde','LeftShift','BackslashPipe','Z','X','C','V','B','N','M','CommaLeftArrow','PeriodRightArrow','ForwardSlashQuestionMark','RightShift','RightAlt','Space','CapsLock','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','Up','Down','Right','Left','Home','End','Delete','PageUp','PageDown','Insert','PrintScreen','NumLock','ScrollLock','Menu','WindowsKey','NumpadDivide','NumpadAsterisk','Numpad7','Numpad8','Numpad9','Numpad4','Numpad5','Numpad6','Numpad1','Numpad2','Numpad3','Numpad0','NumpadDelete','NumpadEnter','NumpadPlus','NumpadMinus')
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
        if($Hardware -and $Driver){
            Write-Error "-Hardware, -Driver: Допускается только один параметр";return
        }
        $key = $PSBoundParameters.key
        #region keybd_event 
        if(!$Handle){
            if($Hardware){
                $portName = @(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.
                            Properties|Where{$_.name -like  '*USB*'}).value)[0].Replace("COM","")
                $arduino = [psClick.Arduino]::Open($PortName)
                $error = "Не удалось открыть порт. Err code: $arduino"
                if([Int]$arduino -le 0){throw $error}

                if($key -match "^\p{L}$"){
                    $hKey = [Windows.Forms.Keys]::$key.value__+32
                }
                elseif($key -match "^D\d$"){
                    $hKey = [Windows.Forms.Keys]::$key.value__
                }
                else{
                    $hKey = @{
                        LControlKey    = 0x80
                        LShiftKey      = 0x81
                        Alt            = 0x82
                        LWin           = 0x83
                        RControlKey    = 0x84
                        RShiftKey      = 0x85
                        RWin           = 0x87
                        Up             = 0xDA
                        Down           = 0xD9
                        Left           = 0xD8
                        Right          = 0xD7
                        Tab            = 0xB3
                        Enter          = 0xB0
                        Return         = 0xB0
                        Escape         = 0xB1
                        Insert         = 0xD1
                        Delete         = 0xD4
                        PageUp         = 0xD3
                        PageDown       = 0xD6
                        Home           = 0xD2
                        End            = 0xD5
                        CapsLock       = 0xC1
                        Capital        = 0xC1
                        Space          = 0x20
                        F1             = 0xC2
                        F2             = 0xC3
                        F3             = 0xC4
                        F4             = 0xC5
                        F5             = 0xC6
                        F6             = 0xC7
                        F7             = 0xC8
                        F8             = 0xC9
                        F9             = 0xCA
                        F10            = 0xCB
                        F11            = 0xCC
                        F12            = 0xCD
                        F13            = 0xF0
                        F14            = 0xF1
                        F15            = 0xF2
                        F16            = 0xF3
                        F17            = 0xF4
                        F18            = 0xF5
                        F19            = 0xF6
                        F20            = 0xF7
                        F21            = 0xF8
                        F22            = 0xF9
                        F23            = 0xFA
                        F24            = 0xFB
                        NumPad0        = 234 
                        NumPad1        = 225 
                        NumPad2        = 226 
                        NumPad3        = 227 
                        NumPad4        = 228 
                        NumPad5        = 229 
                        NumPad6        = 230 
                        NumPad7        = 231 
                        NumPad8        = 232 
                        NumPad9        = 233 
                        Multiply       = 221 
                        Subtract       = 222 
                        Decimal        = 235 
                        Add            = 223 
                        Divide         = 220
                    }.$key
                }

                if($down){Send-ArduinoCommand $arduino "3$hKey" $Wait}
                elseif($up){Send-ArduinoCommand $arduino "4$hKey" $Wait}
                else{Send-ArduinoCommand $arduino "1$hKey" $Wait}
                [void][psClick.Arduino]::Close($arduino)                
            }
            elseif($Driver){
                $hKey = @{
                    Escape = 1
                    One = 2
                    Two = 3
                    Three = 4
                    Four = 5
                    Five = 6
                    Six = 7
                    Seven = 8
                    Eight = 9
                    Nine = 10
                    Zero = 11
                    DashUnderscore = 12
                    PlusEquals = 13
                    Backspace = 14
                    Tab = 15
                    Q = 16
                    W = 17
                    E = 18
                    R = 19
                    T = 20
                    Y = 21
                    U = 22
                    I = 23
                    O = 24
                    P = 25
                    OpenBracketBrace = 26
                    CloseBracketBrace = 27
                    Enter = 28
                    Control = 29
                    A = 30
                    S = 31
                    D = 32
                    F = 33
                    G = 34
                    H = 35
                    J = 36
                    K = 37
                    L = 38
                    SemicolonColon = 39
                    SingleDoubleQuote = 40
                    Tilde = 41
                    LeftShift = 42
                    BackslashPipe = 43
                    Z = 44
                    X = 45
                    C = 46
                    V = 47
                    B = 48
                    N = 49
                    M = 50
                    CommaLeftArrow = 51
                    PeriodRightArrow = 52
                    ForwardSlashQuestionMark = 53
                    RightShift = 54
                    RightAlt = 56
                    Space = 57
                    CapsLock = 58
                    F1 = 59
                    F2 = 60
                    F3 = 61
                    F4 = 62
                    F5 = 63
                    F6 = 64
                    F7 = 65
                    F8 = 66
                    F9 = 67
                    F10 = 68
                    F11 = 87
                    F12 = 88
                    Up = 72
                    Down = 80
                    Right = 77
                    Left = 75
                    Home = 71
                    End = 79
                    Delete = 83
                    PageUp = 73
                    PageDown = 81
                    Insert = 82
                    PrintScreen = 55
                    NumLock = 69
                    ScrollLock = 70
                    Menu = 93
                    WindowsKey = 91
                    NumpadDivide = 53
                    NumpadAsterisk = 55
                    Numpad7 = 71
                    Numpad8 = 72
                    Numpad9 = 73
                    Numpad4 = 75
                    Numpad5 = 76
                    Numpad6 = 77
                    Numpad1 = 79
                    Numpad2 = 80
                    Numpad3 = 81
                    Numpad0 = 82
                    NumpadDelete = 83
                    NumpadEnter = 28
                    NumpadPlus = 78
                    NumpadMinus = 74
                }.$key

                if($down){
                    if($key -match "(Control|LeftShift|RightShift|RightAlt)"){
                        [psClick.KeyBoard]::SendKey($hKey, [psClick.Hardware.KeyState]::Down)   
                    }
                    else{
                        Start-ThreadJob -Name "$key`_Down" {
                            while($true){
                                [psClick.KeyBoard]::SendKey($args[1], [psClick.Hardware.KeyState]::Down)
                                [psClick.KeyBoard]::SendKey($args[1], [psClick.Hardware.KeyState]::Up)
                                Sleep -m $args[0]
                            }
                        } -ArgumentList $delay, $key|Out-Null
                    }
                }
                elseif($up){
                    if($key -match "(Control|LeftShift|RightShift|RightAlt)"){
                        [psClick.KeyBoard]::SendKey($hKey, [psClick.Hardware.KeyState]::Up)
                    }
                    else{
                        Remove-Job -Name "$key`_Down" -Force
                    }
                }
                else{
                    [psClick.KeyBoard]::SendKey($hKey, [psClick.Hardware.KeyState]::Down)
                    [psClick.KeyBoard]::SendKey($hKey, [psClick.Hardware.KeyState]::Up)
                }
            }                                     
            else{
                if($down){
                    if($key -match "(alt|Control|Shift|win|[lr]menu)"){
                        [psClick.User32]::keybd_event([Windows.Forms.Keys]::$key, 0, 0x0000, 0)
                    }
                    else{
                        Start-ThreadJob -Name "$key`_Down" {
                            while($true){
                                [psClick.User32]::keybd_event([Windows.Forms.Keys]::[String]$args[1], 0, 0x0000, 0)
                                [psClick.User32]::keybd_event([Windows.Forms.Keys]::[String]$args[1], 0, 0x0002, 0)
                                Sleep -m $args[0]
                            }
                        } -ArgumentList $delay, $key|Out-Null
                    }
                }
                elseif($up){
                    if($key -match "(alt|Control|Shift|win|[lr]menu)"){
                        [psClick.User32]::keybd_event([Windows.Forms.Keys]::$key, 0, 0x0002, 0)
                    }
                    else{
                        Remove-Job -Name "$key`_Down" -Force
                    }
                }
                else{
                    [psClick.User32]::keybd_event([Windows.Forms.Keys]::$key, 0, 0x0000, 0)
                    [psClick.User32]::keybd_event([Windows.Forms.Keys]::$key, 0, 0x0002, 0)
                }
            }
        }
        #endregion
        #region Message 
        else{ 
            if($Down){
                Start-ThreadJob -Name "$key`_Down_Event" {
                    while($true){
                        if ([psClick.User32]::PostMessage([IntPtr]$args[2] ,0x0100, [Windows.Forms.Keys]::[String]$args[1], 0)){
                            #[psClick.User32]::PostMessage($handle ,0x0101, [Windows.Forms.Keys]::[string]$args[1], 0)|Out-Null 
                        }
                        else{
                            [psClick.User32]::SendMessage([IntPtr]$args[2] ,0x0100, [Windows.Forms.Keys]::[string]$args[1], 0)|Out-Null
                            #[psClick.User32]::SendMessage($handle ,0x0101, [Windows.Forms.Keys]::[string]$args[1], 0)|Out-Null
                        }
                        Sleep -m $args[0]
                    }
                } -ArgumentList $delay, $key, $Handle|Out-Null
            }
            elseif($Up){
                Remove-Job -Name "$key`_Down_Event" -Force
            }
            else{  
                if ([psClick.User32]::PostMessage($handle ,0x0100, [Windows.Forms.Keys]::$key, 0)){
                    #[psClick.User32]::PostMessage($handle ,0x0101, [Windows.Forms.Keys]::$key, 0)|Out-Null 
                }
                else{
                    [psClick.User32]::SendMessage($handle ,0x0100, [Windows.Forms.Keys]::$key, 0)|Out-Null
                    #[psClick.User32]::SendMessage($handle ,0x0101, [Windows.Forms.Keys]::$key, 0)|Out-Null
                }
            }
        }
        #endregion
        Sleep -m $Sleep
    }
}