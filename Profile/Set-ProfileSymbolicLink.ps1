# Create Symbolic Link for your PowerShell profile script
$sourceProfilePath = Join-Path -Path $env:OneDrive -ChildPath 'Documents\WindowsPowerShell\profile.ps1'
$destProfilePath = Join-Path -Path $env:USERPROFILE -ChildPath 'Documents\WindowsPowerShell\profile.ps1'
New-Item -ItemType SymbolicLink -Path $destProfilePath -Value $sourceProfilePath -Force
