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
            1..$count|%{    
                if ([w32]::PostMessage($handle ,0x0100, $key, 0)){
                    [w32]::PostMessage($handle ,0x0101, $key, 0)|Out-Null 
                }
                else{
                    [w32]::SendMessage($handle ,0x0100, $key, 0)|Out-Null
                    [w32]::SendMessage($handle ,0x0101, $key, 0)|Out-Null
                }
            }
        }
    }
    #endregion
}