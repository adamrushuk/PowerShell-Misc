# Publishes the modules provided in modulenames.txt

# Vars
$moduleNamesFilename = 'modulenames.txt'
$moduleNamesPath = Join-Path -Path $PSScriptRoot -ChildPath $moduleNamesFilename
$localPSRepositoryName = 'LocalPSRepository'

# Get module names from txt file
$moduleNames = Get-Content -Path $moduleNamesPath

# Show currently installed module versions
Write-Host "Modules on [localhost]..." -ForegroundColor 'Cyan'
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }

Write-Host "`nModules in [$localPSRepositoryName]..." -ForegroundColor 'Cyan'
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }

# Publish multiple modules
$moduleNames | ForEach-Object { Publish-Module -Name $_ -Repository $localPSRepositoryName -Verbose -Force }

# Show latest installed module versions in local repo
Write-Host "`nModules in [$localPSRepositoryName]..." -ForegroundColor 'Cyan'
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }
