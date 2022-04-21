function Send-TelegramMessage
{
    #.COMPONENT
    #2.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [String[]]$Message
    )
    ."$psscriptroot\psClick_bot.exe" -id="$mee" -content="$message" -msg|out-null
}

function Send-TelegramFile
{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [String]$Path
    )
    ."$psscriptroot\psClick_bot.exe" -id="$mee" -content="$path"|out-null
}

function Send-TelegramImage
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory = $true)]
        [Drawing.Bitmap]$Image
        ,
        [Parameter(Mandatory = $false)]
        [String]$Name
    )
    if(!$Name){$Name = "picture"}
    $Image.Save("$env:TEMP\$Name.png", [Drawing.Imaging.ImageFormat]::Png)
    ."$psscriptroot\psClick_bot.exe" -id="$mee" -content="$env:TEMP\$Name.png"|out-null
}