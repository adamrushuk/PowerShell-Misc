# Save module(s) from PSGallery to local path
$moduleNames = 'posh-git'
$localPath = Join-Path -Path $env:OneDrive -ChildPath 'PS\Modules'

Save-Module -Name $moduleNames -Path $localPath -Verbose
