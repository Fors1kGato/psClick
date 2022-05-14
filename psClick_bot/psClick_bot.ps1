function Send-TelegramDocument
{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [Alias(
        'Send-TelegramAudio', 
        'Send-TelegramVideo',
        'Send-TelegramPhoto'
    )]
    Param(
        [Parameter(Mandatory,Position=0)]
        [Alias("Photo", "Video","Audio")]
        $File,
        [Parameter(Position=1)]
        [String]$Caption,
        [Parameter(Position=2)]
        [ValidateSet('MarkdownV2', 'HTML', 'Markdown')]
        [String]$Parse_mode,
        [Switch]$Disable_notification,
        [Int]$Reply_to_message_id,
        [String]$FileName
    )
    if($FileName -and !(Test-Path $FileName -IsValid))
    {throw "Имя файла содержит недопустимые знаки"}
    if($File -isnot [Drawing.Bitmap] -and !(Test-Path $File))
    {throw "Укажите путь существующего файла"}
    $body = [Collections.Generic.Dictionary[String,String]]::new()
    $body.Add("chat_id", $me)
    if($MyInvocation.InvocationName.EndsWith("Document"))
    {$body.Add("disable_content_type_detection",$true)}
    $cmdType = $MyInvocation.InvocationName.Replace("Send-Telegram","")
    ForEach($k in $MyInvocation.BoundParameters.Keys){
        if($k -eq 'File'){continue}
        $body.Add($k.ToLower(), $MyInvocation.BoundParameters.$k)
    }
    if($cmdType -in ("Photo","Document") -and $File -is [Drawing.Image]){
        $stream = [IO.MemoryStream]::new()
        $File.Save($stream, [Drawing.Imaging.ImageFormat]::Png)
        $stream.Position = 0
        if(!$FileName){$FileName = Get-Date -Format "dd-MM-yyyy_HH-mm-ss.pn\g"}
    }
    else{
        $stream = [IO.File]::OpenRead($File)
        if(!$FileName){$FileName = Split-Path $File -Leaf}
    }
    try{
    $result = [psClick.Telegram]::SendFile(
        $body,
        $stream,
        $FileName,
        [psClick.Telegram+FileType]::$cmdType
    )
    if($result.Result){$result = $result.Result|ConvertFrom-Json}
    }
    catch{
        $stream.Close()
        throw $_
    }
    $stream.Close()
    return $result
}

function Send-TelegramMessage
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory,Position=0)]
        [String]$Text,
        [Parameter(Position=1)]
        [ValidateSet('MarkdownV2', 'HTML', 'Markdown')]
        [String]$Parse_mode,
        [Switch]$Disable_web_page_preview,
        [Switch]$Disable_notification,
        [Int]$Reply_to_message_id
    )
    $body = [Collections.Generic.Dictionary[String,String]]::new()
    $body.Add("chat_id",$me)
    ForEach($k in $MyInvocation.BoundParameters.Keys){
        $body.Add($k.ToLower(), $MyInvocation.BoundParameters.$k)
    }
    $result = [psClick.Telegram]::SendMessage($body)
    if($result.Result){$result = $result.Result|ConvertFrom-Json}
    return $result
}