Enable-PSRemoting -Force
Set-ExecutionPolicy 'RemoteSigned'

# Map drive
New-PSDrive –Name 'S' -PSProvider FileSystem -Root '\\fileserver01\Source' -Persist

# Change folder
Set-Location -Path 'S:\Software\PowerShell\Scripts'

# Copy profile script
$PowerShellProfilePath = Join-Path -Path $env:USERPROFILE -ChildPath 'Documents\WindowsPowerShell'
New-Item -Path $PowerShellProfilePath -ItemType 'Directory' -Force
Copy-Item -Path 'profile.ps1' -Destination $PowerShellProfilePath -Force

# Set folder options
.\Set-FolderOptions.ps1


# Configure git example
<#
git config --global user.email 'adam.rush@domain.com'
git config --global user.name 'Adam Rush'
git config --global -l

Copy-Item -Path 'Adam.ssh' -Destination "$env:USERPROFILE\.ssh" -Recurse -Force

ssh -Tv git@gitserver01
#>


# Configure Internal PowerShell repository
#Import-Module PowerShellGet

$powershellRepositoryPath = '\\fileserver01\Source\Software\PowerShell\InternalPSRepository'
$repo = @{
    Name = 'InternalPSRepository'
    SourceLocation = $powershellRepositoryPath
    PublishLocation = $powershellRepositoryPath
    InstallationPolicy = 'Trusted'
}
Register-PSRepository @repo


<#
# Check NuGet Package Provider is listed
Get-PackageProvider

# List repositories
Get-PSRepository

# Publish module
Publish-Module -Name MyModule -Repository InternalPSRepository -Verbose
Publish-Module -Name FJHelperDscResources -Repository InternalPSRepository -Verbose

# List modules
Find-Module -Repository InternalPSRepository

# Install module from private repository
Install-Module -Name MyModule -Repository InternalPSRepository -Scope AllUsers -Verbose

Installing updated modules
You can run Update-Module to update your module. But I find that it leaves the old version on the system.
I tend to remove and then install fresh when I need to update.

Uninstall-Module -Name MyModule -Verbose
Install-Module -Name MyModule -Repository InternalPSRepository -Scope AllUsers -Verbose

Get-Module -Name MyModule
Get-Module -Name MyModule -ListAvailable

#>

