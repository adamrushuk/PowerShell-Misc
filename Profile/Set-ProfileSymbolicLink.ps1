# NEW METHOD
# First move your Documents folder location (in properties) to OneDrive
# new location would be "C:\Users\USERNAME\OneDrive\Documents"
# Create Symbolic Link for your PowerShell to Windows PowerShell profile script
# we then only need to maintain this one profile script for both new PowerShell, and Windows PowerShell:
# C:\Users\USERNAME\OneDrive\Documents\PowerShell\profile.ps1
$sourceProfilePath = Join-Path -Path $env:OneDrive -ChildPath 'Documents\PowerShell\profile.ps1'
$destProfilePath = Join-Path -Path $env:OneDrive -ChildPath 'Documents\WindowsPowerShell\profile.ps1'
New-Item -ItemType SymbolicLink -Path $destProfilePath -Value $sourceProfilePath -Force


# OLD METHOD: Create Symbolic Link for your PowerShell profile script
$sourceProfilePath = Join-Path -Path $env:OneDrive -ChildPath 'Documents\WindowsPowerShell\profile.ps1'
$destProfilePath = Join-Path -Path $env:USERPROFILE -ChildPath 'Documents\WindowsPowerShell\profile.ps1'
New-Item -ItemType SymbolicLink -Path $destProfilePath -Value $sourceProfilePath -Force
