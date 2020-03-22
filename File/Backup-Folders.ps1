# Robocopy examples
# https://pureinfotech.com/robocopy-transfer-files-fast-network-windows-10/
robocopy \\source-device-ip\path\to\share\folder C:\destination-device\path\to\store\files /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16
robocopy \\10.1.2.111\Users\admin\Documents C:\Users\admin\Documents /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16


# Create dated folder and copy, excluding ".git" folders
# No logging, except a final summary: /njh /ndl /nc /ns /nfl
$dateString = Get-Date -Format "yyyy-MM-dd"
robocopy "$env:HOME\OneDrive" "D:\Backups\OneDrive\$dateString" /E /Z /ZB /R:5 /W:5 /TBD /NP /MT:16 /njh /ndl /nc /ns /nfl /xd ".git"
robocopy "$env:HOME\Google Drive" "D:\Backups\GoogleDrive\$dateString" /E /Z /ZB /R:5 /W:5 /TBD /NP /MT:16 /njh /ndl /nc /ns /nfl /xd ".git"
robocopy "$env:HOME\code" "D:\Backups\code\$dateString" /E /Z /ZB /R:5 /W:5 /TBD /NP /MT:16 /njh /ndl /nc /ns /nfl /xd ".git"
