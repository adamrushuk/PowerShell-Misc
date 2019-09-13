#requires -module posh-git

$profileLoadStart = Get-Date

# Am I running as Administrator?
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

#region Prompt
<# function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host

    if (Test-Administrator) {
        # Use different username if elevated
        Write-Host "(Admin) : " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor DarkYellow
    Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor Magenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray

    if ($null -ne $s) {
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
} #>
#endregion Prompt


#region Aliases
function Get-VagrantStatus {
    & vagrant.exe status
}
Set-Alias -Name 'vs' -Value 'Get-VagrantStatus'

function Get-VagrantGlobalStatus {
    & vagrant.exe global-status
}
Set-Alias -Name 'vgs' -Value 'Get-VagrantGlobalStatus'

function Get-VagrantGlobalStatusPrune {
    & vagrant.exe global-status --prune
}
Set-Alias -Name 'vgsp' -Value 'Get-VagrantGlobalStatusPrune'

function Invoke-VagrantUp {
    & vagrant.exe up
}
Set-Alias -Name 'vup' -Value 'Invoke-VagrantUp'

function Invoke-VagrantUpLog {
    & vagrant.exe up 2>&1 | Tee-Object -FilePath 'vagrant.log'
}
Set-Alias -Name 'vupl' -Value 'Invoke-VagrantUpLog'

function Invoke-VagrantHalt {
    & vagrant.exe halt
}
Set-Alias -Name 'vh' -Value 'Invoke-VagrantHalt'

function Invoke-VagrantDestroy {
    & vagrant.exe destroy
}
Set-Alias -Name 'vd' -Value 'Invoke-VagrantDestroy'


function Invoke-VagrantSnapshotList {
    & vagrant.exe snapshot list
}
Set-Alias -Name 'vsl' -Value 'Invoke-VagrantSnapshotList'

function Invoke-VagrantSnapshotRestoreNP {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $Name
    )
    & vagrant.exe snapshot restore $Name --no-provision
}
Set-Alias -Name 'vsr' -Value 'Invoke-VagrantSnapshotRestoreNP'

function Invoke-VagrantSnapshotSave {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $Name
    )
    & vagrant.exe snapshot save $Name -f
}
Set-Alias -Name 'vss' -Value 'Invoke-VagrantSnapshotSave'
#endregion Aliases


# Custom VSCode functions
# Import useful functions like splatting: https://sqldbawithabeard.com/2018/03/11/easily-splatting-powershell-with-vs-code/
if ($Host.Name -match 'Visual Studio') {
    if (-not (Get-Module -Name "EditorServicesCommandSuite" -ListAvailable)) {
        Import-Module EditorServicesCommandSuite -ErrorAction Ignore
    }
    Import-EditorCommand -Module EditorServicesCommandSuite -Verbose
}


#region Debug
function Enable-ExceptionDebugger {
    <#
        .Synopsis
        $StackTrace is touched on every exception. This causes you to break into the debugger before you enter the catch statement.

        .Link
        https://stackoverflow.com/questions/20912371/is-there-a-way-to-enter-the-debugger-on-an-error
    #>
    $null = Set-PSBreakpoint -Variable 'StackTrace' -Mode 'Write'
}

function Disable-ExceptionDebugger {
    Get-PSBreakpoint -Variable 'StackTrace' | Remove-PSBreakpoint
}
#endregion Debug


# Source: https://gist.github.com/GABeech/98df2f95fb3a79cd2ccaa80a439aa975
function Clear-DeletedBranches {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [Alias("cdb")]
    param(
        [Parameter(Mandatory = $false)]
        [string]
        $GitDir = $PWD
    )

    $before = git.exe branch -a

    $prun = git.exe remote prune origin --dry-run
    if ($prun) {
        Write-Host "Branches to Be Pruned" -ForegroundColor Green
        Write-Host $prun -ForegroundColor Red

        if ($PSCmdlet.ShouldProcess("Remove Local Branches?")) {
            git.exe remote prune origin
            $after = git.exe branch -a
            $removed = Compare-Object -ReferenceObject $before -DifferenceObject $after
            foreach ($b in $removed.InputObject) {
                $localName = $b.Split('/')[-1]
                git.exe branch -D $localName
            }
        }
    } else {
        Write-Host "Nothing To prune" -ForegroundColor Green
    }

    Write-Host "`nCurrent branches" -ForegroundColor Green
    git.exe branch -a
}

$profileLoadEnd = Get-Date
$profileLoadTime = $profileLoadEnd - $profileLoadStart
$loadTimeString = "Profile Loaded [{0:g}]" -f $profileLoadTime
Write-Output $loadTimeString
