<# This script will:
- Uninstall all versions of the given module names.
- Install the latest available modules.
- Publish the new modules to your PowerShell Repository
#>

# Vars
$localPSRepositoryName = 'LocalPSRepository'
$moduleNames = @('xActiveDirectory')

# Show currently installed module versions
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }

# Uninstall modules
$moduleNames | ForEach-Object { Uninstall-Module -Name $_ -AllVersions -Force -Verbose }

# Install modules
Install-Module -Name $moduleNames -Repository 'PSGallery' -AllowClobber -Force -Verbose

# Show currently installed module versions
$moduleNames | ForEach-Object { Get-Module -Name $_ -ListAvailable }

# Publish multiple modules
$moduleNames | ForEach-Object { Publish-Module -Name $_ -Repository $localPSRepositoryName -Verbose -Force }
