# Test all possible PowerShell profile file paths, and open if they exist
$ProfileTypes = 'AllUsersAllHosts', 'AllUsersCurrentHost', 'CurrentUserAllHosts', 'CurrentUserCurrentHost'
foreach ($ProfileType in $ProfileTypes) {
    Write-Host "Testing $($Profile.$ProfileType)"
    if (Test-Path $Profile.$ProfileType) {psedit $Profile.$ProfileType}
}
