function Get-PointsDistance
{
    #.COMPONENT
    #2.1
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
    if($point1 -isnot [Drawing.Point] -and $point1 -isnot [Drawing.PointF]){
        try{$point1 = [Drawing.PointF]::new.Invoke($point1)}catch{throw $_}
    }
    if($point2 -isnot [Drawing.Point] -and $point2 -isnot [Drawing.PointF]){
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
    [psClick.Tray]::GetTrayInfo()
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
        [Switch]$Unicode
        ,
        [Parameter(Mandatory,ParameterSetName = 'Ansi')]
        [Switch]$Ansi
    )
    if($Data -isnot [String] -and ($Unicode -or $Ansi)){throw "Переданные данные не являются строкой"}

    if($Data.GetType() -in [Int16],[Int32],[Int64],[UInt16],[UInt32],[UInt64],[Float],[Double]){
        $Data = [BitConverter]::GetBytes($Data)
    }
    elseif ($Data -is [String]){
        if ($Unicode){$Data = [Text.Encoding]::Unicode.GetBytes("$Data`0`0")}
        elseif($Ansi){$Data = [Text.Encoding]::GetEncoding(1251).GetBytes("$Data`0")}
        else{throw "Укажите кодировку"}
    }
    if($Data -isnot [Byte[]]){throw "Incorrect data type"}
    [UInt32]$BytesWritten = 0

    $writeResult = [psClick.Kernel32]::WriteProcessMemory(
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
    #3.1
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
        if($size){
            $memInfo = [psClick.Kernel32+MEMORY_BASIC_INFORMATION]::new()

            $queryResult = [psClick.Kernel32]::VirtualQueryEx(
                $Process.Handle,
                $Address,
                [ref]$memInfo,
                [Runtime.InteropServices.Marshal]::SizeOf($memInfo)
            )
            $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            if(!$queryResult){throw "Virtual Query error: $err"}

            [int]$sizeMax = $memInfo.RegionSize - ([int64]$Address - [int64]$memInfo.BaseAddress)
            if($sizeMax -lt $size){$size = $sizeMax}
            $Data = [Byte[]]::new($size)
        }
        else{$Data = [Byte[]]::new([Runtime.InteropServices.Marshal]::SizeOf([Type]$Read))}

        $CallResult = [psClick.Kernel32]::ReadProcessMemory(
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
        $memInfo = [psClick.Kernel32+MEMORY_BASIC_INFORMATION]::new()

        $queryResult = [psClick.Kernel32]::VirtualQueryEx(
            $Process.Handle,
            $Address,
            [ref]$memInfo,
            [Runtime.InteropServices.Marshal]::SizeOf($memInfo)
        )
        $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if(!$queryResult){throw "Virtual Query error: $err"}

        [int]$size = $memInfo.RegionSize - ([int64]$Address - [int64]$memInfo.BaseAddress)
        $string = [System.Text.StringBuilder]::new($size)

        $readResult = [psClick.Kernel32]::"ReadProcessMemory$read"(
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

    $me32 = [psClick.Kernel32+MODULEENTRY32]::new()
    $me32.dwSize = [Runtime.InteropServices.Marshal]::SizeOf($me32)

    $hModuleSnap = [psClick.Kernel32]::CreateToolhelp32Snapshot(
        ($TH32CS_SNAPMODULE -bor $TH32CS_SNAPMODULE32), 
        $Process.Id
    )
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if(!$hModuleSnap){throw "Create Tool help 32 Snapshot error: $err"}

    $CallResult = [psClick.Kernel32]::Module32First($hModuleSnap, [ref]$me32) 
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if(!$CallResult){throw "Get Module 32 First error: $err"}

    $modules = [Collections.Generic.List[PSCustomObject]]::new()

    $modules.Add([PSCustomObject]@{Name = [string]$me32.szModule;Address = [IntPtr]$me32.modBaseAddr;Path = [string]$me32.szExePath})

    while([psClick.Kernel32]::Module32Next($hModuleSnap, [ref]$me32)){
        $modules.Add([PSCustomObject]@{Name = [string]$me32.szModule;Address = [IntPtr]$me32.modBaseAddr;Path = [string]$me32.szExePath})    
    }   
               
    [Void][psClick.Kernel32]::CloseHandle($hModuleSnap)
    ,$modules
}

function Find-AddressProcessMemory
{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    Param(
        [Parameter(Mandatory, Position = 0)]
        [Diagnostics.Process]$Process
        ,
        [Parameter(Mandatory, Position = 1)]
        $Data
        ,
        [Parameter(Mandatory, Position = 2)]
        [ValidateSet('ANSI','Unicode','Int16','Int32','Int64','UInt16','UInt32','UInt64','Single','Double','Mask','Byte[]')]
        [String]$Type
        ,
        [Parameter(Position = 3)]
        [Uint32]$Alignment = 1
        ,
        [Parameter(Position = 4)]
        [Uint32]$Count = 0
        ,        
        [Parameter(Position = 5)]
        $StartAddress = 0      
        ,
        [Parameter(Position = 6)]
        $EndAddress = 0x7fffffff
    )

    if($Type -ne 'Mask')
    {
        if($Data -isnot [String] -and $Type -in 'ANSI', 'Unicode'){throw "Переданные данные не являются строкой"}

        if($Data.GetType() -in [Int16],[Int32],[Int64],[UInt16],[UInt32],[UInt64],[Float],[Double]){
        $Data = [BitConverter]::GetBytes($Data)
        }
        elseif ($Data -is [String]){
            if ($Type -eq 'Unicode'){$Data = [Text.Encoding]::Unicode.GetBytes("$Data")}
            elseif($Type -eq 'ANSI'){$Data = [Text.Encoding]::GetEncoding(1251).GetBytes("$Data")}
            else{throw "Укажите кодировку"}
        }
        if($Data -isnot [Byte[]]){throw "Incorrect data type"}

        ,[psClick.Memory]::FindAddress($Process, $Data, $null, $Alignment, $Count, $StartAddress, $EndAddress) 
    }
    else{
       if($Data -isnot [Object[]]){throw "Недопустимый объект, используйте Get-MaskBytes"}       
       ,[psClick.Memory]::FindAddress($Process, [Byte[]]$Data[0], [Bool[]]$Data[1], $Alignment, $Count, $StartAddress, $EndAddress) 
     }       
}

function Exclude-AddressProcessMemory
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [Diagnostics.Process]$Process
        ,      
        [Parameter(Mandatory, Position = 1)]
        $Address
        ,             
        [Parameter(Mandatory, Position = 2, ParameterSetName="String")]
        [String]$String
        ,
        [Parameter(Mandatory, Position = 2, ParameterSetName="Number")]
        [Object[]]$Number
        ,
        [Parameter(Mandatory, Position = 3, ParameterSetName="String")]
        [ValidateSet('ANSI','Unicode')]
        [String]$Encoding
        ,
        [Parameter(Mandatory, Position = 3, ParameterSetName="Number")]
        [ValidateSet('Int16', 'Int32','Int64', 'UInt16', 'UInt32', 'UInt64', 'Single', 'Double')]
        [String]$NumberType
        ,
        [Parameter(Mandatory, Position = 4, ParameterSetName="String")]
        [ValidateSet('НовоеЗначение', 'Изменилось', 'НеИзменилось')]     
        [String]$StringChanged
        ,
        [Parameter(Mandatory, Position = 4, ParameterSetName="Number")]
        [ValidateSet(
            'НовоеЗначение','БольшеЧем','МеньшеЧем','ЗначениеМежду','Увеличилось',
            'УвеличилосьНа','Уменьшилось','УменьшилосьНа','Изменилось','НеИзменилось')]     
        [String]$NumberChanged        
    )
    DynamicParam
    {
        if ($NumberChanged -in 'УвеличилосьНа','УменьшилосьНа')
        {
            $attribute = [Management.Automation.ParameterAttribute]@{
                Mandatory = $true
                Position = 5
                ParameterSetName = "Number"
            }
            $collection = [Collections.ObjectModel.Collection[Attribute]]::new()
            $collection.Add([ValidateNotNullOrEmpty]::new())
            $collection.Add($attribute)
 
            $param = [Management.Automation.RuntimeDefinedParameter]::new(
                'TargetValue', ([Type]$NumberType), $collection
            )
            $Global:a= $param
            $dictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
            $dictionary.Add('TargetValue', $param)
 
            return $dictionary
        }
    }
 
    End{
        Switch ($PSCmdlet.ParameterSetName)
        {           
            'String'
            {
                if($Encoding -eq 'Unicode'){$Data = [Text.Encoding]::Unicode.GetBytes($String)}
                else{$Data = [Text.Encoding]::GetEncoding(1251).GetBytes($String)}
                [psClick.Memory]::ExcludeAddress($Process, $Data, $Encoding, $StringChanged, 0, [ref]$Address)  
            }
            'Number'
            {   
                if($NumberChanged -eq 'ЗначениеМежду' -and $Number.Count -lt 2){
                	throw "Number должно содержать 2 числа"	    
                }
            
                $Data = [BitConverter]::GetBytes($Number[0])
                if($Number.Count -gt 1){ $Data += [BitConverter]::GetBytes($Number[1]) }

                if($PSBoundParameters.TargetValue -eq $null){ $TargetValue = 0 }
                else {$TargetValue = $PSBoundParameters.TargetValue}

                [psClick.Memory]::ExcludeAddress($Process, $Data, $NumberType, $NumberChanged, $TargetValue, [ref]$Address)  
            }     
        }
    }
}

function Get-MaskBytes
{
    #.COMPONENT
    #1
    #.SYNOPSIS
    #Author: Fors1k, Cirus ; Link: https://psClick.ru
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]         
        [Object[]]$Data       
    )

    $buffer = [Byte[]]::new(0)
    $mask = [Bool[]]::new(0)

    $Data|%{
        if($_.GetType() -in [Int32],[Int16],[Int64],[Double],[Float]){        
            $buffer += [BitConverter]::GetBytes($_)
            $size = [System.Runtime.InteropServices.Marshal]::SizeOf([Type]$_.GetType())
            for($i=0; $i-lt$size; $i++){$mask += $true}
        }
        elseif($_ -is [Byte[]]){       
            $buffer += $_
            $size = $_.Count
            $BytesNull = $true
            for($i=0; $i-lt$size; $i++){$_|%{if($_ -ne [byte]0){ $BytesNull = $false; break }}}
            if($BytesNull){ for($i=0; $i-lt$size; $i++){$mask += $false} } # пустой массив
            else{ for($i=0; $i-lt$size; $i++){$mask += $true} }           # массив байт                         
        }
        elseif($_ -is [String]){
            $text = Get-Bytes -Text $_ -Encoding Unicode
            $buffer += $text
            for($i=0; $i-lt$text.Count; $i++){$mask += $true}
        }
        else{ throw 'Тип данных не определён' }
    }

    $buffer, $mask
}