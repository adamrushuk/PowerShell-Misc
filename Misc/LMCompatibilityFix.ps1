#Requires -RunAsAdministrator
# Author: Steve Baker

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
