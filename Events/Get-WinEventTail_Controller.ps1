# Get-WinEventTail testing
# Vars
$computerName = 'node01'
$credential = New-Object -TypeName 'PSCredential' -ArgumentList ('.\vagrant', (ConvertTo-SecureString -String 'vagrant' -AsPlainText -Force))

# Load function
. .\Get-WinEventTail.ps1

# Test remote event collection
Get-WinEventTail -LogName "Microsoft-Windows-DSC/Operational" -ComputerName $computerName -Credential $credential | Format-Table -Wrap

<# Testing DSC logs
Get-WinEventTail -LogName "Application" -ComputerName $computerName -Credential $credential | Format-Table -Wrap

Get-WinEventTail -LogName "Microsoft-Windows-DSC/Operational" | Format-Table -Wrap
Get-WinEventTail -LogName "Microsoft-Windows-DSC/Analytic" | Format-Table -Wrap # needs work as no support for -Oldest
Get-WinEventTail -LogName "Microsoft-Windows-DSC/Debug" | Format-Table -Wrap # needs work as no support for -Oldest
#>