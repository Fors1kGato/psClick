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
    #1
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
        [ValidateSet('Int16','Int32','Int64','UInt16','UInt32','UInt64','Single','Double')]
        [String]$Read
        ,
        [Parameter(Mandatory, Position = 2, ParameterSetName = "Size")]
        [Int]$Size
    )
    if($size){$Data = [byte[]]::new($size)}
    else{$Data = [byte[]]::new([Runtime.InteropServices.Marshal]::SizeOf([type]$Read))}
    [UInt32]$BytesRead = 0

    $CallResult = [w32]::ReadProcessMemory(
        $Process.Handle,
        $Address,
        $Data,
        $Data.Count,
        [ref]$BytesRead
    )
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if(!$CallResult){throw "Read process memory error: $err"}
    if(!$size){[BitConverter]::"To$Read"($Data,0)}else{$Data}
}