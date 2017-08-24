$PSDPath = 'C:\Path\TO\Module.psd1'

$params = @{
    Path = Split-Path $PSDPath -Parent
    Repository = 'PSGallery'
    NuGetApiKey =  'MyNuGetApiKey'
}

Test-ModuleManifest $PSDPath

# Validate that $target has been setup as a valid PowerShell repository
$validRepo = Get-PSRepository -Name $params.Repository -Verbose:$false -ErrorAction SilentlyContinue
if (-not $validRepo) {
    throw "[$params.Repository] has not been setup as a valid PowerShell repository."
}
$validRepo

Get-PackageProvider -Name NuGet -ForceBootstrap
Get-Module

Publish-Module @params -Verbose #-WhatIf
