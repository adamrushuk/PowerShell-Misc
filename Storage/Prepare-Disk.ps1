# Set up disk after adding at virtual layer
Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PassThru |
    New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume
