# Uninstalls all versions of the modules provided in modulenames.txt

# Vars
$moduleNamesFilename = 'modulenames.txt'
$moduleNamesPath = Join-Path -Path $PSScriptRoot -ChildPath $moduleNamesFilename

# Get module names from txt file
$moduleNames = Get-Content -Path $moduleNamesPath

# Show currently installed module versions
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }

# Uninstall modules
$moduleNames | ForEach-Object { Uninstall-Module -Name $_ -AllVersions -Force -Verbose }

# Show currently installed module versions
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }
