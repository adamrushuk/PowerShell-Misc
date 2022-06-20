# Author: Steve Baker
function Start-LmcRdpSession {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                if (-Not ($_ | Test-Path) ) {
                    throw "File or folder does not exist."
                }
                if (-Not ($_ | Test-Path -PathType Leaf) ) {
                    throw "The Path argument must be a file. Folder paths are not allowed."
                }
                if ($_ -notmatch "(\.rdp)") {
                    throw "The file specified in the path argument must be of type RDP."
                }
                return $true
            })]
        [String]$RdpFileName
    )

    #Requires -RunAsAdministrator

    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $registryKey = "lmcompatibilitylevel"
    $requiredValue = 5

    # Getting the current value of the lmcompatibilitylevel key.
    $CurrentValue = Get-ItemPropertyValue -Path $registryPath -Name $registryKey

    # Comparing current value to required value and changing if needed.
    if ($CurrentValue -ne 5) {
        Write-Output "RDP logins prevented by current LanMan Compatibility Level of [$CurrentValue]"
        Write-Output "Changing Compatibility Level to 5..."
        try {
            Set-ItemProperty -Path $registryPath -Name $registryKey -Value $requiredValue -Type Dword
            Write-Output "Done! Try RDP again."
        } catch {
            Write-Output "Could not change LanMan Compatibility level. Check for errors above."
        }
    } else {
        Write-Output "LanMan Compatibility Level is already at 5. If you cannot connect, there is a different problem."
    }

    # Starting the RDP Session from the specified RDPFileName
    try {
        Write-Output "Attempting to start RDP session using [$RDPFileName]..."
        & $RDPFileName
        Write-Output "Successfully started RDP session using [$RDPFileName]."
    } catch {
        Write-Output "Could not start RDP session from [$RDPFileName]."
        Write-Output "Is the path/filename correct?"
    }
}
