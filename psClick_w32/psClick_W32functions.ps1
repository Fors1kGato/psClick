function Write-ProcessMemory
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory)]
        [IntPtr]$Address
        ,
        [Parameter(Mandatory)]
        [Diagnostics.Process]$Process
        ,
        [Parameter(Mandatory)]
        $Data
    )

    if($Data.GetType() -in [Int16],[Int32],[Int64],[UInt16],[UInt32],[UInt64],[Float],[Double]){
        $Data = [BitConverter]::GetBytes($Data)
    }
    if($Data -isnot [Byte[]]){throw "Incorrect data type"}
    [UInt32]$BytesWritten = 0

    $CallResult = [w32]::WriteProcessMemory(
        $Process.Handle,
        $Address,
        $Data,
        $Data.Count,
        [ref]$BytesWritten
    )
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if(!$CallResult){throw "Write process memory error: $err"}
}

function Read-ProcessMemory
{
    #.COMPONENT
    #2
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
    )
    [UInt32]$BytesRead = 0
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
        if(!$queryResult){throw "Read process memory error: $err"}

        [int]$size = $memInfo.RegionSize - ([int64]$Address - [int64]$memInfo.BaseAddress)
        $string = [System.Text.StringBuilder]::new($size)
        if($read -eq 'Unicode'){
            $CallResult = [w32Memory]::ReadProcessMemoryUnicode(
                $Process.Handle,
                $Address,
                $string,
                $size,
                [ref]$bytesRead
            )
            $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            if(!$CallResult){throw "Read process memory error: $err"}
        }
        else{
            $CallResult = [w32Memory]::ReadProcessMemoryAnsi(
                $Process.Handle,
                $Address,
                $string,
                $size,
                [ref]$bytesRead
            )
            $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            if(!$CallResult){throw "Read process memory error: $err"}
        }
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
    if(!$hModuleSnap){throw "Creating Tool help 32 Snapshot error: $err"}

    $CallResult = [w32Memory]::Module32First($hModuleSnap, [ref]$me32) 
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if(!$CallResult){throw "Getting Module 32 First error: $err"}

    $modules = [Collections.Generic.List[PSCustomObject]]::new()

    $modules.Add([PSCustomObject]@{Name = $me32.szModule;Address = $me32.modBaseAddr;Path = $me32.szExePath})

    while([w32Memory]::Module32Next($hModuleSnap, [ref]$me32)){
        $modules.Add([PSCustomObject]@{Name = $me32.szModule;Address = $me32.modBaseAddr;Path = $me32.szExePath})    
    }   
               
    [Void][w32]::CloseHandle($hModuleSnap)
    ,$modules
}