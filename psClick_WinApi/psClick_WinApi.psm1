function WinApi{
    #.COMPONENT
    #1.1
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    PARAM(
        [Parameter(Position = 0, Mandatory = $True )]
        [String]$method
        ,
        [Parameter(Position = 1, Mandatory = $False)]
        [Object[]]$params = [Object[]]::new(0)
        ,
        [Parameter(Position = 2, Mandatory = $False)]
        [Type]$return = [Boolean]
        ,
        [Parameter(Position = 3, Mandatory = $False)]
        [String]$dll = 'User32.dll'
        ,
        [Parameter(Position = 4, Mandatory = $False)]
        [Int]$charSet = 4
    )
    BEGIN{
        [Type[]]$pTypes = $params|ForEach{
            if($_-is[ref]){$_.Value.GetType().MakeByRefType()}
            elseif($_-is[scriptblock]){
                [Delegate]::CreateDelegate([func[[type[]],type]],
                [Linq.Expressions.Expression].Assembly.GetType(
                'System.Linq.Expressions.Compiler.DelegateHelpers'
                ).GetMethod('MakeNewCustomDelegate',
                [Reflection.BindingFlags]'NonPublic, Static') 
                ).Invoke(($_.ast.ParamBlock.Parameters.StaticType+
                $_.Attributes.type.type))
            }else{$_.GetType()}
        }
    }
    PROCESS{
        ($w32=[Reflection.Emit.AssemblyBuilder]::
        DefineDynamicAssembly('w32A','Run').
        DefineDynamicModule('w32M').DefineType('w32T',
        "Public,BeforeFieldInit")).DefineMethod(
        $method,'Public,HideBySig,Static,PinvokeImpl',
        $return,($pTypes)).SetCustomAttribute(
        [Reflection.Emit.CustomAttributeBuilder]::new(
        ($DI=[Runtime.InteropServices.DllImportAttribute]).
        GetConstructor([string]),$dll,$DI.GetField('CharSet'),
        @{[char]'W'=-1;;[char]'A'=-2}[$method[-1]]+$CharSet))
    }
    END{$w32.CreateType()::$method.Invoke($Params)}
}
function Struct{
    #.COMPONENT
    #2
    #.SYNOPSIS
    #Author: Fors1k ; Link: https://psClick.ru
    PARAM(
        [Parameter(ValueFromPipeline  =  $True)]
        [String]$Attributes
        ,
        [Parameter(Position=0,Mandatory=$True )]
        [String]$typeName
        ,
        [Parameter(Position=1,Mandatory=$True )]
        [Object[]]$data
        ,
        [Switch]$New
        ,
        [Switch]$AutoSize
    )
    PROCESS{
        if($AutoSize -and !$New){
            Write-Error "-AutoSize: Expected -New with -AutoSize";return
        }
        for($i=0;$i-lt$data.count){
            [Type[]]$fieldTypes+=$data[$i++]
            [String[]]$fieldNames+=$data[$i++]
        }
        $StructAttributes = 'Class,Public,Sealed,
                             BeforeFieldInit'
        if($Attributes){
            $layout,$charSet=$Attributes-split";"
        }
        else{
            $layout,$charSet='Sequential','Auto'
            
        }
        $StructAttributes = $StructAttributes-bor
        [Reflection.TypeAttributes]::"$layout`Layout"-bor
        [Reflection.TypeAttributes]::"$charSet`Class"
    
        $type = [Reflection.Emit.AssemblyBuilder]::
        DefineDynamicAssembly('w32A','Run').
        DefineDynamicModule('w32M').
        DefineType(
            $typeName,
            $StructAttributes,
            [ValueType]
        )
        for($i = 0; $i -lt $fieldTypes.Length; $i++){
            $arr=$fieldNames[$i]-split";"
            $field=$type.DefineField($arr[0],$fieldTypes[$i],"Public")
            if($fieldNames[$i]-match";"){
                $field.SetCustomAttribute(
                    [Reflection.Emit.CustomAttributeBuilder]::new(
                        [Runtime.InteropServices.MarshalAsAttribute].GetConstructors()[0], 
                        [Runtime.InteropServices.UnmanagedType]::($arr[1]), 
                        [Runtime.InteropServices.MarshalAsAttribute].GetField('SizeConst'), 
                        [int]$arr[2]
                    )
                )
            }
        }
    }
    END{
        if($New){
            $struct = $type.CreateType()::new()
            if($AutoSize){
                $struct.($data[1]) = [Runtime.InteropServices.Marshal]::SizeOf([type]$typeName)
            }
            $struct
        }
        else{
            [void]$type.CreateType()
        }
    }  
}