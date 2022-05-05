function Get-PointsDistance
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position=0)]
        $Point1
        ,
        [Parameter(Mandatory, Position=1)]
        $Point2
        ,
        [Switch]$Round
    )
    if($point1 -isnot [Drawing.Point] -or $point1 -isnot [Drawing.PointF]){
        try{$point1 = [Drawing.PointF]::new.Invoke($point1)}catch{throw $_}
    }
    if($point2 -isnot [Drawing.Point] -or $point2 -isnot [Drawing.PointF]){
        try{$point2 = [Drawing.PointF]::new.Invoke($point2)}catch{throw $_}
    }
    $distance = [Math]::Sqrt(
        [Math]::Pow($point1.X - $point2.X, 2) + 
        [Math]::Pow($point1.Y - $point2.Y, 2)
    )
    if($Round){
        [Math]::Round($distance)
    }
    else{
        $distance
    }
}

function Get-TrayInfo
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
    )
    [Tray]::GetTrayInfo()
}

function Write-ProcessMemory
{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    Param(
        [Parameter(Mandatory,Position = 0)]
        [IntPtr]$Address
        ,
        [Parameter(Mandatory,Position = 1)]
        [Diagnostics.Process]$Process
        ,
        [Parameter(Mandatory,Position = 2)]
        $Data
        ,
        [Parameter(Mandatory,ParameterSetName = 'Unicode')]
        [switch]$Unicode
        ,
        [Parameter(Mandatory,ParameterSetName = 'Ansi')]
        [switch]$Ansi
    )
    if($Data -isnot [String] -and ($Unicode -or $Ansi)){throw "Переданные данные не являются строкой"}

    if($Data.GetType() -in [Int16],[Int32],[Int64],[UInt16],[UInt32],[UInt64],[Float],[Double]){
        $Data = [BitConverter]::GetBytes($Data)
    }
    elseif ($Data -is [String]){
        if ($Unicode){$Data = [Text.Encoding]::Unicode.GetBytes("$Data`0`0")}
        elseif($Ansi){$Data = [Text.Encoding]::GetEncoding('windows-1251').GetBytes("$Data`0")}
        else{throw "Укажите кодировку"}
    }
    if($Data -isnot [Byte[]]){throw "Incorrect data type"}
    [UInt32]$BytesWritten = 0

    $writeResult = [w32Memory]::WriteProcessMemory(
        $Process.Handle,
        $Address,
        $Data,
        $Data.Count,
        [ref]$BytesWritten
    )
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if(!$writeResult){throw "Write process memory error: $err"}
}

function Read-ProcessMemory
{
    #.COMPONENT
    #3
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    [CmdletBinding(DefaultParameterSetName = 'Type')]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [IntPtr]$Address
        ,
        [Parameter(Mandatory, Position = 1)]
        [Diagnostics.Process]$Process
        ,
        [Parameter(Mandatory, Position = 2, ParameterSetName = "Type")]
        [ValidateSet('ANSI','Unicode','Int16','Int32','Int64','UInt16','UInt32','UInt64','Single','Double')]
        [String]$Read
        ,
        [Parameter(Mandatory, Position = 2, ParameterSetName = "Size")]
        [Int]$Size
        ,
        [String]$Module
    )
    [UInt32]$BytesRead = 0

    if($module){
        $processModules = Get-ProcessModules $Process
        $processModule  = ($processModules|Where-Object{$_.Name -ceq $module})-as $processModules.GetType()
        if($processModule.count -ne 1){
            throw "Ошибка поиска модуля. Модулей [$module] найдено: $($processModule.count)"   
        }
        [IntPtr]$Address= [Int64]$Address + [Int64]$processModule.Address
    }

    if($Read -notin ('ANSI', 'Unicode')){
        if($size){$Data = [byte[]]::new($size)}
        else{$Data = [byte[]]::new([Runtime.InteropServices.Marshal]::SizeOf([type]$Read))}

        $CallResult = [w32Memory]::ReadProcessMemory(
            $Process.Handle,
            $Address,
            $Data,
            $Data.Count,
            [ref]$BytesRead
        )
        $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if(!$CallResult){throw "Read process memory error: $err"}
        if(!$size){[BitConverter]::"To$Read"($Data,0)}else{,$Data}
    }
    else{
        $memInfo = [w32Memory+MEMORY_BASIC_INFORMATION]::new()

        $queryResult = [w32Memory]::VirtualQueryEx(
            $Process.Handle,
            $Address,
            [ref]$memInfo,
            [Runtime.InteropServices.Marshal]::SizeOf($memInfo)
        )
        $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if(!$queryResult){throw "Virtual Query error: $err"}

        [int]$size = $memInfo.RegionSize - ([int64]$Address - [int64]$memInfo.BaseAddress)
        $string = [System.Text.StringBuilder]::new($size)

        $readResult = [w32Memory]::"ReadProcessMemory$read"(
            $Process.Handle,
            $Address,
            $string,
            $size,
            [ref]$bytesRead
        )
        $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if(!$readResult){throw "Read process memory error: $err"}

        $string.ToString()
    }
}

function Get-ProcessModules
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Cirus, Fors1k ; Link: https://psClick.ru
    param(
        [Parameter(Mandatory)]
        [Diagnostics.Process]$Process
    )
    $TH32CS_SNAPMODULE   = 0x00000008
    $TH32CS_SNAPMODULE32 = 0x00000010

    $me32 = [w32Memory+MODULEENTRY32]::new()
    $me32.dwSize = [Runtime.InteropServices.Marshal]::SizeOf($me32)

    $hModuleSnap = [w32Memory]::CreateToolhelp32Snapshot(
        ($TH32CS_SNAPMODULE -bor $TH32CS_SNAPMODULE32), 
        $Process.Id
    )
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if(!$hModuleSnap){throw "Create Tool help 32 Snapshot error: $err"}

    $CallResult = [w32Memory]::Module32First($hModuleSnap, [ref]$me32) 
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if(!$CallResult){throw "Get Module 32 First error: $err"}

    $modules = [Collections.Generic.List[PSCustomObject]]::new()

    $modules.Add([PSCustomObject]@{Name = [string]$me32.szModule;Address = [IntPtr]$me32.modBaseAddr;Path = [string]$me32.szExePath})

    while([w32Memory]::Module32Next($hModuleSnap, [ref]$me32)){
        $modules.Add([PSCustomObject]@{Name = [string]$me32.szModule;Address = [IntPtr]$me32.modBaseAddr;Path = [string]$me32.szExePath})    
    }   
               
    [Void][w32]::CloseHandle($hModuleSnap)
    ,$modules
}
