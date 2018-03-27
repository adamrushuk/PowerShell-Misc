# Create symbolic links whilst developing custom DSC resources
# Source: https://hodgkins.io/five-tips-for-writing-dsc-resources-in-powershell-version-5
# NEW
$sourcePath = 'D:\VSTS\ICSClientDsc'
$moduleNames = 'ICSClient', 'ICSClientDsc'
$destPath = 'C:\Users\arush\Documents\WindowsPowerShell\Modules'

foreach ($moduleName in $moduleNames) {
    # originalModulePath is the one containing the .psm1 and .psd1
    $originalModulePath = Join-Path -Path $sourcePath -ChildPath $moduleName

    # destModulePath is the path where the symbolic link will be created which points to your repo
    $destModulePath = Join-Path -Path $destPath -ChildPath $moduleName
    New-Item -ItemType 'SymbolicLink' -Path $destModulePath -Target $originalModulePath -WhatIf
}


# GET
# Get a list of the symbolic links you are using in the PowerShell Modules folder
$env:PSModulePath -Split ";" | Get-ChildItem  | Where-Object { $_.Attributes -match "ReparsePoint"} | Select-Object Target, FullName


# REMOVE
# The recurse might make this seem scary but this just removes the symlink and not your module!
$moduleNames = 'ICSClient', 'ICSClientDsc'
$destPath = 'C:\Users\arush\Documents\WindowsPowerShell\Modules'
foreach ($moduleName in $moduleNames) {
    # destModulePath is the path where the symbolic link will be created which points to your repo
    $destModulePath = Join-Path -Path $destPath -ChildPath $moduleName

    # Remove-Item throws error right now :(
    #Remove-Item -Path $destModulePath -Force -Recurse -WhatIf

    # Use cmd to remove symbolic link, as PowerShell currently has issues
    cmd /c "rmdir $destModulePath"
}
