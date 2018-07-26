# Installs the modules provided in modulenames.txt

# Vars
$moduleNamesFilename = 'modulenames.txt'
$moduleNamesPath = Join-Path -Path $PSScriptRoot -ChildPath $moduleNamesFilename

# Get module names from txt file
$moduleNames = Get-Content -Path $moduleNamesPath

# Show currently installed module versions
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }

# Install modules
Install-Module -Name $moduleNames -Repository 'PSGallery' -AllowClobber -Force -Verbose -SkipPublisherCheck

# Show currently installed module versions
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }
