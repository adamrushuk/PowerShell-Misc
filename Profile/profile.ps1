#requires -module posh-git, EditorServicesCommandSuite

#region SSH

# Put the SSH_AGENT_PD and SSH_AUTH_SOCK in the User Env Variables
# This way we don't need to worry about having to be int he right process for
# SSH-AGENT to work
function Set-SSHAgent
{
    $SSHPID = [System.Environment]::GetEnvironmentVariable("SSH_AGENT_PID", "Process")
    $SSHSOCK = [System.Environment]::GetEnvironmentVariable("SSH_AUTH_SOCK", "Process")
    $USSHPID = [System.Environment]::GetEnvironmentVariable("SSH_AGENT_PID", "User")
    $USSHSOCK = [System.Environment]::GetEnvironmentVariable("SSH_AUTH_SOCK", "User")
    if (($USSHPID -ne $SSHPID) -or ($USSHSOCK -ne $SSHSOCK))
    {
        [Environment]::SetEnvironmentVariable('SSH_AGENT_PID', $SSHPID, 'User')
        [Environment]::SetEnvironmentVariable('SSH_AUTH_SOCK', $SSHSOCK, 'User')
    }
}

$profileLoadStart = Get-Date
$poshStart = measure-command { Import-Module posh-git }
$poshLoadTime = "Posh-git Loaded [{0:g}]" -f $poshStart


write-output $poshLoadTime
# Chocolatey profile
$ChocolateyStart = Measure-Command {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile))
    {
        Import-Module "$ChocolateyProfile"
    }
}
$ChocoLoadString = "Chocolatey Loaded: [{0:g}]" -f $ChocolateyStart
Write-Output $ChocoLoadString
# Start SSH Agent on new session
# NOOP if it is already running, so lets just be sure.
Start-SSHAgent

# Check to see if my keys are already loaded
$sshDirectory = Join-Path -Path $env:USERPROFILE -ChildPath '.ssh'
$privateKeys = Get-ChildItem -Path $sshDirectory | Where-Object { !$_.Extension -and $_ -like "id_*"}
$loadedKeys = ssh-add.exe -l
foreach ($key in $privateKeys)
{
    $keyInfo = ssh-keygen.exe -lf $key.FullName
    if ($loadedKeys.Contains($keyInfo))
    {
        continue
    }
    ssh-add.exe $key.FullName

}
Set-SSHAgent
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
function Get-VagrantStatus
{& C:\HashiCorp\Vagrant\bin\vagrant.exe status
}
Set-Alias -Name 'vs' -Value 'Get-VagrantStatus'

function Get-VagrantGlobalStatus
{& C:\HashiCorp\Vagrant\bin\vagrant.exe global-status
}
Set-Alias -Name 'vgs' -Value 'Get-VagrantGlobalStatus'

function Get-VagrantGlobalStatusPrune
{& C:\HashiCorp\Vagrant\bin\vagrant.exe global-status --prune
}
Set-Alias -Name 'vgsp' -Value 'Get-VagrantGlobalStatusPrune'

function Invoke-VagrantUp
{& C:\HashiCorp\Vagrant\bin\vagrant.exe up
}
Set-Alias -Name 'vup' -Value 'Invoke-VagrantUp'

function Invoke-VagrantUpLog
{& C:\HashiCorp\Vagrant\bin\vagrant.exe up 2>&1 | Tee-Object -FilePath 'vagrant.log'
}
Set-Alias -Name 'vupl' -Value 'Invoke-VagrantUpLog'

function Invoke-VagrantHalt
{& C:\HashiCorp\Vagrant\bin\vagrant.exe halt
}
Set-Alias -Name 'vh' -Value 'Invoke-VagrantHalt'

function Invoke-VagrantDestroy
{& C:\HashiCorp\Vagrant\bin\vagrant.exe destroy
}
Set-Alias -Name 'vd' -Value 'Invoke-VagrantDestroy'


function Invoke-VagrantSnapshotList
{& C:\HashiCorp\Vagrant\bin\vagrant.exe snapshot list
}
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


# Source: https://gist.github.com/GABeech/98df2f95fb3a79cd2ccaa80a439aa975
function Clear-DeletedBranches
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $false)]
        [string]
        $GitDir = $PWD
    )

    $before = git branch -a

    $prun = git remote prune origin --dry-run
    if ($prun)
    {
        Write-Host "Branches to Be Pruned" -ForegroundColor Green
        Write-Host $prun -ForegroundColor Red

        if ($PSCmdlet.ShouldProcess("Remove Local Branches?"))
        {
            git remote prune origin
            $after = git branch -a
            $removed = Compare-Object -ReferenceObject $before -DifferenceObject $after
            foreach ($b in $removed.InputObject)
            {
                $localName = $b.Split('/')[-1]
                git branch -D $localName
            }
        }
    }
    else
    {
        Write-Host "Nothing To prune" -ForegroundColor Green
    }
}

$profileLoadEnd = Get-Date
$profileLoadTime = $profileLoadEnd - $profileLoadStart
$loadTimeString = "Profile Loaded [{0:g}]" -f $profileLoadTime
Write-Output $loadTimeString
