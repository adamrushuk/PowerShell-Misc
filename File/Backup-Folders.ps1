# Robocopy examples
# https://pureinfotech.com/robocopy-transfer-files-fast-network-windows-10/
# robocopy \\source-device-ip\path\to\share\folder C:\destination-device\path\to\store\files /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16
# robocopy \\10.1.2.111\Users\admin\Documents C:\Users\admin\Documents /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16

# Create dated folder and copy. Tuned for a slow 5400 RPM / SMR USB drive:
#   /MT:1   single-threaded; concurrent threads thrash the head on a mechanical platter
#   no /Z /ZB - restartable mode writes tracking records per buffer chunk, huge overhead on many small files
# No logging, except a final summary: /njh /ndl /nc /ns /nfl

# Vars
$backupDrive = "D:"
$excludedDirs = @(".git", "node_modules", ".venv", ".terraform", "bin", "obj")

Read-Host -Prompt "Has a USB drive been connected and showing as Drive [$backupDrive]?"
$dateString = Get-Date -Format "yyyy-MM-dd"
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "Backing up [~/code] folder..."
robocopy "$env:HOMEPATH\code" "$backupDrive\Backups\code\$dateString" /E /R:1 /W:1 /TBD /NP /MT:1 /njh /ndl /nc /ns /nfl /xd $excludedDirs

Write-Host "Backing up [~/OneDrive] folder..."
robocopy "$env:OneDrive" "$backupDrive\Backups\OneDrive\$dateString" /E /R:1 /W:1 /TBD /NP /MT:1 /njh /ndl /nc /ns /nfl /xd $excludedDirs

Write-Host "Backing up [~/Google Drive] folder..."
robocopy "$env:HOMEPATH\My Drive" "$backupDrive\Backups\GoogleDrive\$dateString" /E /R:1 /W:1 /TBD /NP /MT:1 /njh /ndl /nc /ns /nfl /xd $excludedDirs

$stopwatch.Stop()
Write-Host "All backup jobs have now completed in $($stopwatch.Elapsed.ToString('hh\h\ mm\m\ ss\s'))."
