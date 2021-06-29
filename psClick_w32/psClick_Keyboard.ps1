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
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [parameter(Mandatory=$true )]
        [String]$Text
        ,
        [int]$Delay = 32
    )

    $chars = $Text.ToCharArray()
    $rus = [w32KeyBoard]::LoadKeyboardLayout("00000419", 0)
    $eng = [w32KeyBoard]::LoadKeyboardLayout("00000409", 0)
    $window = [w32Windos]::GetForegroundWindow()
    ForEach($c in $chars){
        if([Text.Encoding]::Default.GetBytes($c) -ge 184){
            [w32]::PostMessage($window, 0x0050, 0x0001, $rus)
            $vk = [w32KeyBoard]::VkKeyScanEx($c, $rus)
        }
        else{
            [w32]::PostMessage($window, 0x0050, 0x0001, $eng)
            $vk = [w32KeyBoard]::VkKeyScanEx($c, $eng)
        }

        if($vk -band 256){
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
