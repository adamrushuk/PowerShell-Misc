# Finds all storage blobs with a locked/leased state, then breaks the lease

# vars
$storageAccountName = "MY_STORAGE_ACCOUNT_NAME"
$storageAccountKey = "MY_STORAGE_ACCOUNT_KEY"
$storageContainerName = "terraformstate"

# login
. ~/.azmgt.ps1
# Connect-AzAccount -UseDeviceAuthentication
# Set-AzContext -Subscription "<SUBSCRIPTION_NAME>"

# get blobs
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$blobs = Get-AzStorageBlob -Container $storageContainerName -Context $ctx -ConcurrentTaskCount 50
Write-Host "[$($blobs.Count)] blobs found."

# filter for locked blobs, then group duplicate blob names
$blobsLocked = $blobs | Where-Object { $_.BlobProperties.LeaseStatus -eq "Locked" }
$blobsLockedGrouped = $blobsLocked | Group-Object Name

# grab the most recent blob from each group
$blobsToBreakLease = foreach ($blobsLockedGroup in $blobsLockedGrouped) {
    $blobsLockedGroup.Group | Sort-Object LastModified -Descending | Select-Object -First 1
}
Write-Host "[$($blobsToBreakLease.Count)] blobs are locked."

# show blobs with leases to break
$blobsToBreakLease | Select-Object Name, LastModified, @{N = "LeaseState"; E = { $_.BlobProperties.LeaseStatus } }

# TODO: use out-grid view to select which blobs to break lease on
# INFO: requires "Microsoft.PowerShell.ConsoleGuiTools" module for PowerShell 7
# Install-Module -Name Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
# $blobsToBreakLease | Out-ConsoleGridView

# break leases
foreach ($blob in $blobsToBreakLease) {
    Write-Host "Breaking Lease for [$($blob.Name)]..."

    # catch .NET exceptions
    # try { $blob.ICloudBlob.BreakLease() 2>&1>$null } catch {}
    # try { $blob.ICloudBlob.BreakLease() } catch {}
    $blob.ICloudBlob.BreakLease()
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Exit code [$LASTEXITCODE] occurred for [$($blob.Name)] `n"
    } else {
        Write-Host "Exit code [$LASTEXITCODE] Successfully broke lease for [$($blob.Name)].`n"
    }
}
