function ConvertTo-Text {
<#
    .SYNOPSIS
        Convert an object to text
    .DESCRIPTION
        This function takes an object and converts it to a textual
        representation.
    .NOTES
        Source: Automating vSphere Administration
        Authors: Luc Dekens, Brian Graf, Arnim van Lieshout,
        Jonathan Medd, Alan Renouf, Glenn Sizemore,
        Andrew Sullivan
    .PARAMETER InputObject
        The object to be represented in text format
    .PARAMETER Depth
        Defines how 'deep' the function shall traverse the object.
        The default is a depth of 2.
    .PARAMETER FullPath
        A switch that defines if the property is displayed with
        indentation or with the full path
    .PARAMETER ExtensionData
        A switch that defines if the ExtensionData property shall
        be handled or not
    .EXAMPLE
        Get-VM -Name VM1 | ConvertTo-Text -Depth 2
    .EXAMPLE
        ConvertTo-Text -InputObject $esx -FullPath
#>
    #Requires -Version 4.0

    [CmdletBinding()]
    Param(
        [PARAMETER(ValueFromPipeline = $True)]
        [object[]]$InputObject,
        [int]$Depth = 2,
        [switch]$FullPath = $false,
        [Switch]$ExtensionData = $false,
        [PARAMETER(DontShow)]
        [string]$Indent = '',
        [PARAMETER(DontShow)]
        [string]$Path = ''
    )

    Process {
        if ($Indent.Length -lt $Depth) {
            foreach ($object in $InputObject) {
                $object.PSObject.Properties | Foreach-Object -Process {
                    if ($FullPath) {
                        "$($Path + '\' + $_.Name) - $($_.TypeNameOfValue) = $($_.Value)"
                    }
                    else {
                        "$($Indent)$($_.Name) - $($_.TypeNameOfValue) = $($_.Value)"
                    }
                    if (($_.Name -ne 'ExtensionData' -or $ExtensionData) -and `
                            $_.PSObject.Properties) {
                        $ctSplat = @{
                            InputObject   = $object."$($_.Name)"
                            Depth         = $Depth
                            FullPath      = $FullPath
                            Path          = "$($Path + '\' + $_.Name)"
                            Indent        = " $($Indent)"
                            ExtensionData = $ExtensionData
                        }
                        ConvertTo-Text @ctSplat
                    }
                }
            }
        }
    }
}
