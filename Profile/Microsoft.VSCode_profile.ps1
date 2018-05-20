#requires -module posh-git, EditorServicesCommandSuite

#region SSH
# See main .profile.ps1 example
#endregion SSH

# Am I running as Administrator?
function Test-Administrator
{
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

#region Prompt
function prompt
{
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host

    if (Test-Administrator)
    {
        # Use different username if elevated
        Write-Host "(Admin) : " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor DarkYellow
    Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor Magenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray

    if ($s -ne $null)
    {
        # color for PSSessions
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ") " -NoNewline -ForegroundColor DarkGray
        Write-Host " : " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\', '\\'), "~") -NoNewline -ForegroundColor Blue
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkMagenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray

    $global:LASTEXITCODE = $realLASTEXITCODE

    Write-VcsStatus

    Write-Host ""

    return "> "
}
#endregion Prompt


#region Aliases
function Get-VagrantStatus {& C:\HashiCorp\Vagrant\bin\vagrant.exe status}
Set-Alias -Name 'vs' -Value 'Get-VagrantStatus'

function Get-VagrantGlobalStatus {& C:\HashiCorp\Vagrant\bin\vagrant.exe global-status}
Set-Alias -Name 'vgs' -Value 'Get-VagrantGlobalStatus'

function Get-VagrantGlobalStatusPrune {& C:\HashiCorp\Vagrant\bin\vagrant.exe global-status --prune}
Set-Alias -Name 'vgsp' -Value 'Get-VagrantGlobalStatusPrune'

function Invoke-VagrantUp {& C:\HashiCorp\Vagrant\bin\vagrant.exe up}
Set-Alias -Name 'vup' -Value 'Invoke-VagrantUp'

function Invoke-VagrantUpLog {& C:\HashiCorp\Vagrant\bin\vagrant.exe up 2>&1 | Tee-Object -FilePath 'vagrant.log'}
Set-Alias -Name 'vupl' -Value 'Invoke-VagrantUpLog'

function Invoke-VagrantHalt {& C:\HashiCorp\Vagrant\bin\vagrant.exe halt}
Set-Alias -Name 'vh' -Value 'Invoke-VagrantHalt'

function Invoke-VagrantDestroy {& C:\HashiCorp\Vagrant\bin\vagrant.exe destroy}
Set-Alias -Name 'vd' -Value 'Invoke-VagrantDestroy'


function Invoke-VagrantSnapshotList {& C:\HashiCorp\Vagrant\bin\vagrant.exe snapshot list}
Set-Alias -Name 'vsl' -Value 'Invoke-VagrantSnapshotList'

function Invoke-VagrantSnapshotRestoreNP
{
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $Name
    )
    & C:\HashiCorp\Vagrant\bin\vagrant.exe snapshot restore $Name --no-provision
}
Set-Alias -Name 'vsr' -Value 'Invoke-VagrantSnapshotRestoreNP'

function Invoke-VagrantSnapshotSave
{
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $Name
    )
    & C:\HashiCorp\Vagrant\bin\vagrant.exe snapshot save $Name -f
}
Set-Alias -Name 'vss' -Value 'Invoke-VagrantSnapshotSave'
#endregion Aliases


# Custom VSCode functions
# Import useful functions like splatting: https://sqldbawithabeard.com/2018/03/11/easily-splatting-powershell-with-vs-code/
if ($Host.Name -match 'Visual Studio Code')
{
    Import-Module EditorServicesCommandSuite
    Import-EditorCommand -Module EditorServicesCommandSuite
}


#region Debug
function Enable-ExceptionDebugger
{
    <#
        .Synopsis
        $StackTrace is touched on every exception. This causes you to break into the debugger before you enter the catch statement.

        .Link
        https://stackoverflow.com/questions/20912371/is-there-a-way-to-enter-the-debugger-on-an-error
    #>
    $null = Set-PSBreakpoint -Variable 'StackTrace' -Mode 'Write'
}

function Disable-ExceptionDebugger
{
    Get-PSBreakpoint -Variable 'StackTrace' | Remove-PSBreakpoint
}
#endregion Debug
