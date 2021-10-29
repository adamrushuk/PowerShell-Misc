# get disk for aks to check attachment state during disk expansion

# vars
$subscriptionName = ""
$aksClusterName = ""
$aksClusterResourceGroupName = ""
$pvcName = ""

# login
Connect-AzAccount -UseDeviceAuthentication
Get-AzContext
Set-AzContext -Subscription $subscriptionName

# get cluster and associated "node resource group" (where resources live)
$aksCluster = Get-AzAksCluster -Name $aksClusterName -ResourceGroupName $aksClusterResourceGroupName
$diskResourceGroupName = $aksCluster.NodeResourceGroup

# get disk associated with AKS PVC name
$aksDisk = Get-AzDisk -ResourceGroupName $diskResourceGroupName | Where-Object { $_.Tags['kubernetes.io-created-for-pvc-name'] -eq $pvcName }

# wait for disk state to detach
$timer = [Diagnostics.Stopwatch]::StartNew()
do {
    $disk = Get-AzDisk -ResourceGroupName $diskResourceGroupName -DiskName $aksDisk.Name
    $disk | Select-Object DiskState, DiskSizeGB, Name, @{L = "PvcName"; E = { $_.Tags['kubernetes.io-created-for-pvc-name'] } }
    start-sleep -Seconds 10
} while ($disk.DiskState -eq "Attached")
$timer.Stop()
Write-Host "Disk took [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s] to change states"

# full disk info
$disk | Select-Object DiskState, DiskSizeGB, Name, @{L = "PvcName"; E = { $_.Tags['kubernetes.io-created-for-pvc-name'] } }
