#requires -module posh-git, oh-my-posh
Set-Theme Paradox

<# Custom prompt config
# Install modules
Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease -Force -Verbose
Install-Module -Name oh-my-posh -Scope CurrentUser -Verbose
Install-Module -Name PSReadLine -Scope CurrentUser -AllowPrerelease -Force -SkipPublisherCheck -Verbose
Get-Module -Name posh-git, oh-my-posh, PSReadLine, EditorServicesCommandSuite -ListAvailable

# Download "Delugia.Nerd.Font.Complete.ttf" from:
https://github.com/adam7/delugia-code/releases?WT.mc_id=-blog-scottha

# Change font settings in VSCode (only for terminal, as rendering issues for backticks)
"editor.fontFamily": "'Consolas', 'Fira Code', 'Courier New', monospace",
"editor.fontLigatures": false,
"terminal.integrated.fontFamily": "'Delugia Nerd Font', 'Consolas', 'Fira Code', 'Courier New', monospace"

Blog post: https://www.hanselman.com/blog/HowToMakeAPrettyPromptInWindowsTerminalWithPowerlineNerdFontsCascadiaCodeWSLAndOhmyposh.aspx
#>


$profileLoadStart = Get-Date

# Custom VSCode functions
# Import useful functions like splatting: https://sqldbawithabeard.com/2018/03/11/easily-splatting-powershell-with-vs-code/
# Install-Module -Name EditorServicesCommandSuite -Scope CurrentUser -Verbose
if ($Host.Name -match 'Visual Studio') {
    if (-not (Get-Module -Name "EditorServicesCommandSuite" -ListAvailable)) {
        Import-Module EditorServicesCommandSuite -ErrorAction Ignore
    }
    Import-EditorCommand -Module EditorServicesCommandSuite
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

    Write-Host "Switching to master branch..." -ForegroundColor Yellow
    git.exe checkout master

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
