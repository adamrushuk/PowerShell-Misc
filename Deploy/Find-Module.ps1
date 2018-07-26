# Finds the localhost and internal repo module versions provided in modulenames.txt

# Vars
$moduleNamesFilename = 'modulenames.txt'
$moduleNamesPath = Join-Path -Path $PSScriptRoot -ChildPath $moduleNamesFilename
$moduleNamesPath = $moduleNamesFilename
$localPSRepositoryName = 'LocalPSRepository'

# Get module names from txt file
$moduleNames = Get-Content -Path $moduleNamesPath

# Show currently installed module versions
Write-Host "Modules on [localhost]..." -ForegroundColor 'Cyan'
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }

# Find local modules
Write-Host "`nModules in [$localPSRepositoryName]..." -ForegroundColor 'Cyan'
$results = Find-Module -Name $moduleNames -Repository $localPSRepositoryName -ErrorAction 'SilentlyContinue'
$results | Select-Object Version, Name | Sort-Object Name
