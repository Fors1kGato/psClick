function Send-TelegramMessage
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [String[]]$Message
    )
    ."$psscriptroot\psClick_bot.exe" -id="$me" -content="$message" -msg|out-null
}

function Send-TelegramFile
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [String]$Path
    )
    ."$psscriptroot\psClick_bot.exe" -id="$me" -content="$path"|out-null
}

function Send-TelegramImage
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [Drawing.Bitmap]$Image
    )
    $Image.Save("$env:TEMP\picture.png", [System.Drawing.Imaging.ImageFormat]::Png)
    ."$psscriptroot\psClick_bot.exe" -id="$me" -content="$env:TEMP\picture.png"|out-null
}