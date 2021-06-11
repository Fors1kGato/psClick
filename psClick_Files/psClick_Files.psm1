function Release-File{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        $ffpth
    )
    if((iex("$psscriptroot\psClick_Files.exe -p ((iex(`"$psscriptroot\psClick_Files.exe $ffpth`"))[5]|sls '(?<=pid: )(\d*\w*)').matches.value -c (((iex(`"$psscriptroot\psClick_Files.exe $ffpth`")))[5] | select-string '(?<=File\s*)(\d*\w*)(?=:.*)').matches.value -y -nobanner"))-match"Handle closed")
    {$true}else{$false}
}