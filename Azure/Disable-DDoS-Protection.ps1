# Disable Azure DDoS Protection
# https://docs.microsoft.com/en-us/azure/ddos-protection/manage-ddos-protection-powershell#enable-ddos-for-an-existing-virtual-network

# Get all vnets in current subscription
$vnets = Get-AzVirtualNetwork
$vnets | Select-Object "ResourceGroupName", "Name"

# Disable ddos for all vnets
foreach ($vnet in $vnets) {
    $vnet.DdosProtectionPlan = $null
    $vnet.EnableDdosProtection = $false
    $vnet | Set-AzVirtualNetwork
}
