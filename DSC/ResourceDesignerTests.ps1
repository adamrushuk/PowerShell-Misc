# Use dynamic tests below to validate your DSC resources and their schema files
# Source: https://docs.microsoft.com/en-us/powershell/dsc/resourceauthoringchecklist
#
# This file should be placed in a folder called "Tests", which itself is within the DSCResources folder. eg:
# D:\path\to\Module\DSCResources
# ├───DSCResource01
# ├───DSCResource02
# └───Tests
#     └────ResourceDesignerTests.ps1

# Test all DSC resources - folders containing their .psm1
$dscResourcePaths = Get-ChildItem -Path '../' | Where-Object Name -ne 'Tests'

foreach ($dscResourcePath in $dscResourcePaths) {
    Write-Host "`nRunning Test-xDscResource on $($dscResourcePath.FullName)" -ForegroundColor 'Yellow'
    Test-xDscResource -Name $dscResourcePath.FullName
}

# Test all DSC resource schemas
foreach ($dscResourcePath in $dscResourcePaths) {
    $dscSchemaPath = Join-Path -Path $dscResourcePath.FullName -ChildPath "$($dscResourcePath.Name).schema.mof"
    Write-Host "`nRunning Test-xDscSchema on $dscSchemaPath" -ForegroundColor 'Yellow'
    Test-xDscSchema -Path $dscSchemaPath
}
