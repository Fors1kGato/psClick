function Get-KeyState
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true )]
        [ValidateSet('None','LButton','RButton','Cancel','MButton','XButton1','XButton2','Back','Tab','LineFeed','Clear','Enter','Return','ShiftKey','ControlKey','Menu','Pause','CapsLock','Capital','HangulMode','HanguelMode','KanaMode','JunjaMode','FinalMode','KanjiMode','HanjaMode','Escape','IMEConvert','IMENonconvert','IMEAccept','IMEAceept','IMEModeChange','Space','Prior','PageUp','PageDown','Next','End','Home','Left','Up','Right','Down','Select','Print','Execute','Snapshot','PrintScreen','Insert','Delete','Help','D0','D1','D2','D3','D4','D5','D6','D7','D8','D9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','LWin','RWin','Apps','Sleep','NumPad0','NumPad1','NumPad2','NumPad3','NumPad4','NumPad5','NumPad6','NumPad7','NumPad8','NumPad9','Multiply','Add','Separator','Subtract','Decimal','Divide','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','F13','F14','F15','F16','F17','F18','F19','F20','F21','F22','F23','F24','NumLock','Scroll','LShiftKey','RShiftKey','LControlKey','RControlKey','LMenu','RMenu','BrowserBack','BrowserForward','BrowserRefresh','BrowserStop','BrowserSearch','BrowserFavorites','BrowserHome','VolumeMute','VolumeDown','VolumeUp','MediaNextTrack','MediaPreviousTrack','MediaStop','MediaPlayPause','LaunchMail','SelectMedia','LaunchApplication1','LaunchApplication2','OemSemicolon','Oem1','Oemplus','Oemcomma','OemMinus','OemPeriod','Oem2','OemQuestion','Oem3','Oemtilde','Oem4','OemOpenBrackets','OemPipe','Oem5','OemCloseBrackets','Oem6','OemQuotes','Oem7','Oem8','Oem102','OemBackslash','ProcessKey','Packet','Attn','Crsel','Exsel','EraseEof','Play','Zoom','NoName','Pa1','OemClear','KeyCode','Shift','Control','Alt','Modifiers')]
        [String]$Key
    )

    $res = [w32KeyBoard]::GetAsyncKeyState([Windows.Forms.Keys]::$key)
    if($res -notin (0,1)){return 2}else{$res}
}

function Send-key
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [Int]$Key
        ,
        [IntPtr]$Handle
        ,
        [switch]$Down
        ,
        [switch]$Up
    )
    #region Params Validating 
    if($Down -and $Up){
        Write-Error "-Down , -Up: Допускается только один параметр";return
    }
    #endregion
    #region keybd_event 
    if(!$Handle){
        if($down){[w32KeyBoard]::keybd_event($key, 0, 0x0000, 0)}
        elseif($up){[w32KeyBoard]::keybd_event($key, 0, 0x0002, 0)}
        else{
            [w32KeyBoard]::keybd_event($key, 0, 0x0000, 0)
            [w32KeyBoard]::keybd_event($key, 0, 0x0002, 0)
        }
    }
    #endregion
    #region Message 
    else{   
        if($Down){
            if(![w32]::PostMessage($handle ,0x0100, $key, 0)){
                [w32]::SendMessage($handle ,0x0100, $key, 0)|Out-Null 
            }
        }
        elseif($Up){
            if(![w32]::PostMessage($handle ,0x0101, $key, 0)){ 
                [w32]::SendMessage($handle ,0x0101, $key, 0)|Out-Null
            }
        }
        else{  
            if ([w32]::PostMessage($handle ,0x0100, $key, 0)){
                [w32]::PostMessage($handle ,0x0101, $key, 0)|Out-Null 
            }
            else{
                [w32]::SendMessage($handle ,0x0100, $key, 0)|Out-Null
                [w32]::SendMessage($handle ,0x0101, $key, 0)|Out-Null
            }
        }
    }
    #endregion
}

function Send-Text
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [String]$Text
        ,
        [int]$Delay = 64
        ,
        [switch]$Event
        ,
        [IntPtr]$Handle
    )
    #region Params Validating 
    if($Event -and !$Handle -or $Handle -and !$Event){
        Write-Error "-Event , -Handle: Требуются оба параметра";return
    }
    #endregion
    #region keybd_event 
    if(!$Handle){
        $tempCb = Get-Clipboard 
        Set-Clipboard $Text
        [w32KeyBoard]::keybd_event(0xA2, 0, 0x0000, 0)

        [w32KeyBoard]::keybd_event(0x56, 0, 0x0000, 0)
        [w32KeyBoard]::keybd_event(0x56, 0, 0x0002, 0)

        Sleep -m $delay

        [w32KeyBoard]::keybd_event(0xA2, 0, 0x0002, 0)
        Set-Clipboard $tempCb
    }
    #endregion
    #region Message
    else{   
        $chars = $Text.ToCharArray()
        ForEach($c in $chars){
            [void][w32]::PostMessage($handle ,0x0102, $c, 0)
            Sleep -m $delay
        }
    }
    #endregion
}

function Type-Text
{
    #.COMPONENT
    #1.2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true )]
        [String]$Text
        ,
        [int]$Delay = 32
        ,
        [Switch]$Hardware
        ,
        [Switch]$ShiftEOL
    )

    $text = $text-replace"(`r`n|`r)","`n"
    $chars = $Text.ToCharArray()
    $rus = [w32KeyBoard]::LoadKeyboardLayout("00000419", 0)
    $eng = [w32KeyBoard]::LoadKeyboardLayout("00000409", 0)
    $window = [w32Windos]::GetForegroundWindow()
    
    if($Hardware){
        if($Delay -lt 16){$delay = 16}
        $arduino = [System.IO.Ports.SerialPort]::new(@(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.Properties|?{ $_.name -like '*USB*'}).value)[0])
        try{$arduino.Open()}catch{throw $_}
    }

    ForEach($char in $chars){
        if([Text.Encoding]::Default.GetBytes($char) -ge 184){
            [Void][w32]::PostMessage($window, 0x0050, 0x0001, $rus)
            $vk = [w32KeyBoard]::VkKeyScanEx($char, $rus)
        }
        else{
            [Void][w32]::PostMessage($window, 0x0050, 0x0001, $eng)
            $vk = [w32KeyBoard]::VkKeyScanEx($char, $eng)
        }

        if($Hardware){
            if($vk -eq 525){$vk=176}
            if($ShiftEOL -and $vk -eq 176){
                $arduino.Write("3129");Sleep -m $Delay

                $arduino.Write("3$vk");Sleep -m $Delay
                $arduino.Write("4$vk");Sleep -m $Delay

                $arduino.Write("4129");Sleep -m $Delay
            }
            elseif($vk -band 256){
                if($char -notmatch "\p{L}"){
                    $arduino.Write("3129");Sleep -m $Delay

                    $arduino.Write("3$vk");Sleep -m $Delay
                    $arduino.Write("4$vk");Sleep -m $Delay

                    $arduino.Write("4129");Sleep -m $Delay
                }
                else{
                    $arduino.Write("3$vk");Sleep -m $Delay
                    $arduino.Write("4$vk");Sleep -m $Delay
                }
            }
            else{
                if($char -match "\p{L}"){$vk+=32}
                $arduino.Write("3$vk");Sleep -m $Delay
                $arduino.Write("4$vk");Sleep -m $Delay
            }
        }
        else{
            if($vk -band 256 -or ($ShiftEOL -and $vk -eq 525)){
                [w32KeyBoard]::keybd_event(0xA0, 0, 0x0000, 0)
                [w32KeyBoard]::keybd_event($vk , 0, 0x0000, 0)
                [w32KeyBoard]::keybd_event($vk , 0, 0x0002, 0)
                [w32KeyBoard]::keybd_event(0xA0, 0, 0x0002, 0)
            }
            else{
                [w32KeyBoard]::keybd_event($vk , 0, 0x0000, 0)
                [w32KeyBoard]::keybd_event($vk , 0, 0x0002, 0)
            }
            Sleep -m $Delay
        }
    }
    if($Hardware){$arduino.Close();$arduino.Dispose()}
}