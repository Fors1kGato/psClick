function Send-TelegramMessage
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [String[]]$Message
    )
    $WC = [Net.WebClient]::new()
    $Message|Out-File "$env:TEMP\post_msg.txt" -Encoding utf8
    $url = "ftp://vh218.timeweb.ru/$me/post_msg.txt"
    $Wc.Credentials = [Net.NetworkCredential]::new("fors1k_client", "4V8biMPJ");
    $WC.UploadFile($url,"$env:TEMP\post_msg.txt")
    Iwr "https://psclick.ru/bots/index.php?a=$mee" -useb|Out-Null
    $WC.Dispose()
}