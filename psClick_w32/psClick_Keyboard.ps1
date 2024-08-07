﻿function Get-KeyboardLayout
{
    #.COMPONENT
    #3
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [IntPtr]$Handle = (Get-ForegroundWindow)
    )
    $lang = [psClick.KeyBoard]::GetKeyboardLayout($Handle)
    [Windows.Forms.InputLanguage]::FromCulture(
        [Globalization.CultureInfo]::GetCultureInfo([Int]($lang -shr 16))
    )
}

function Get-KeyboardLayouts
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    [Windows.Forms.InputLanguage]::InstalledInputLanguages
}

function Set-KeyboardLayout
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName = 'Layout')]
        [Windows.Forms.InputLanguage]$Layout
        ,
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName = 'Id')]
        [Int]$Id
        ,
        [Parameter(Position=1)]
        [IntPtr]$Handle = (Get-ForegroundWindow)
    )
    $diff = -join(Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name UserPreferencesMask).UserPreferencesMask
    if($diff -eq "15830712818000"){$Handle = Get-ForegroundWindow}
    if(!$Id){$Id = $Layout.Handle}
    [Void][psClick.User32]::PostMessage($Handle, 0x0050, 0x0001, $Id)
}

function Get-KeyState
{
    #.COMPONENT
    #2.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [Alias('Clear-KeyState')]
    Param(
        [parameter(Mandatory=$true)]
        [ValidateSet('None','LButton','RButton','Cancel','MButton','XButton1','XButton2','Back','Tab','LineFeed','Clear','Enter','Return','ShiftKey','ControlKey','Menu','Pause','CapsLock','Capital','HangulMode','HanguelMode','KanaMode','JunjaMode','FinalMode','KanjiMode','HanjaMode','Escape','IMEConvert','IMENonconvert','IMEAccept','IMEAceept','IMEModeChange','Space','Prior','PageUp','PageDown','Next','End','Home','Left','Up','Right','Down','Select','Print','Execute','Snapshot','PrintScreen','Insert','Delete','Help','D0','D1','D2','D3','D4','D5','D6','D7','D8','D9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','LWin','RWin','Apps','Sleep','NumPad0','NumPad1','NumPad2','NumPad3','NumPad4','NumPad5','NumPad6','NumPad7','NumPad8','NumPad9','Multiply','Add','Separator','Subtract','Decimal','Divide','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','F13','F14','F15','F16','F17','F18','F19','F20','F21','F22','F23','F24','NumLock','Scroll','LShiftKey','RShiftKey','LControlKey','RControlKey','LMenu','RMenu','BrowserBack','BrowserForward','BrowserRefresh','BrowserStop','BrowserSearch','BrowserFavorites','BrowserHome','VolumeMute','VolumeDown','VolumeUp','MediaNextTrack','MediaPreviousTrack','MediaStop','MediaPlayPause','LaunchMail','SelectMedia','LaunchApplication1','LaunchApplication2','OemSemicolon','Oem1','Oemplus','Oemcomma','OemMinus','OemPeriod','Oem2','OemQuestion','Oem3','Oemtilde','Oem4','OemOpenBrackets','OemPipe','Oem5','OemCloseBrackets','Oem6','OemQuotes','Oem7','Oem8','Oem102','OemBackslash','ProcessKey','Packet','Attn','Crsel','Exsel','EraseEof','Play','Zoom','NoName','Pa1','OemClear','KeyCode','Shift','Control','Alt','Modifiers')]
        [String]$Key
        ,
        [Switch]$Toggle
    )
    if($MyInvocation.InvocationName -match 'Clear'){
        [Void][psClick.User32]::GetAsyncKeyState([Windows.Forms.Keys]::$Key);return
    }
    if($Toggle){
        if($Key-notin("Scroll","NumLock","CapsLock")){
            $err = "Укажите одну из следующих клавиш: [Scroll]  [NumLock]  [CapsLock]"
            throw $err
        }
        [psClick.User32]::GetKeyState([Windows.Forms.Keys]::$Key)
    }
    else{
        $res = [psClick.User32]::GetAsyncKeyState([Windows.Forms.Keys]::$Key)
        if($res -notin (0,1)){return 2}else{$res}
    }
}

function Send-Text
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [String]$Text
        ,
        [int]$Delay = 64
        ,
        [IntPtr]$Handle = (Get-FocusWindow)
    )
    $chars = $Text.ToCharArray()
    ForEach($c in $chars){
        [void][psClick.User32]::PostMessage($handle ,0x0102, $c, 0)
        Sleep -m $delay
    }
}

function Set-Text
{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [String]$Text
        ,
        [IntPtr]$Handle = (Get-FocusWindow)
    )
    Set-WindowText $Text -ToControl -Handle $Handle
    Send-Key -Key End -Handle $Handle
}

function Type-Text
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true)]
        [String]$Text
        ,
        [UInt16]$Delay = 16
        ,
        [Switch]$Hardware
        ,
        [Switch]$Driver
        ,
        [Switch]$ShiftEOL
        ,
        [UInt16]$Wait = 5000
    )

    if($Hardware -and $Driver){
        Write-Error "-Hardware, -Driver: Допускается только один параметр";return
    }

    $Layout = Get-KeyboardLayout
    $text = $text-replace"(`r`n|`r)","`n"
    $chars = $Text.ToCharArray()
    $ruCh = 192..255+168+184
    $rus = [psClick.User32]::LoadKeyboardLayout("00000419", 0)
    $eng = [psClick.User32]::LoadKeyboardLayout("00000409", 0)
    $window = [psClick.User32]::GetForegroundWindow()
    
    if($Hardware){
        $portName = @(((Get-ItemProperty "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM").psobject.
                    Properties|where{$_.name -like  '*USB*'}).value)[0].replace("COM","")
        $arduino = [psClick.Arduino]::Open($PortName)
        $error = "Не удалось открыть порт. Err code: $arduino"
        if([Int]$arduino -le 0){throw $error}
    }

    if($Driver){
        [psClick.KeyBoard]::SendText($Text, $Delay)

    }
    else{
        ForEach($char in $chars){
            $byte = [Text.Encoding]::Default.GetBytes($char)[0]
            if($byte -in $ruCh){
                [Void][psClick.User32]::PostMessage($window, 0x0050, 0x0001, $rus)
                $vk = [psClick.User32]::VkKeyScanEx($char, $rus)
                $cr = $vk
                if(!($vk -band 256)){$cr+=32}
                if($char-ceq"ё"){$cr=96}elseif($char-ceq"Ё"){$cr=126}
            }
            else{
                [Void][psClick.User32]::PostMessage($window, 0x0050, 0x0001, $eng)
                $vk = [psClick.User32]::VkKeyScanEx($char, $eng)
                if($Hardware){$cr = $byte}
            }

            if($Hardware){
                if($ShiftEOL -and $vk -eq 525){
                    Send-ArduinoCommand $arduino "3129" $Wait
                    Send-ArduinoCommand $arduino "1176" $Wait
                    Send-ArduinoCommand $arduino "4129" $Wait
                }
                else{
                    Send-ArduinoCommand $arduino "1$cr" $Wait
                }
            }
            else{
                if($vk -band 256 -or ($ShiftEOL -and $vk -eq 525)){
                    [psClick.User32]::keybd_event(0xA0, 0, 0x0000, 0)
                    [psClick.User32]::keybd_event($vk , 0, 0x0000, 0)
                    [psClick.User32]::keybd_event($vk , 0, 0x0002, 0)
                    [psClick.User32]::keybd_event(0xA0, 0, 0x0002, 0)
                }
                else{
                    [psClick.User32]::keybd_event($vk , 0, 0x0000, 0)
                    [psClick.User32]::keybd_event($vk , 0, 0x0002, 0)
                }
            }
            Sleep -m $Delay
        }
    }
    if($Hardware){[Void][psClick.Arduino]::Close($arduino)}
    Set-KeyboardLayout $Layout
}