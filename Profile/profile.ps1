#requires -module posh-git, oh-my-posh

# common path: C:\Users\<USERNAME>\Documents\PowerShell\profile.ps1

#region Custom prompt config
<#
# Install modules
Install-Module -Name posh-git, oh-my-posh, PSReadLine -Verbose
Get-Module -Name posh-git, oh-my-posh, PSReadLine -ListAvailable

# Download "Caskaydia Cove Nerd Font" from:
https://www.nerdfonts.com/font-downloads

# Change font settings in VSCode (only for terminal, as rendering issues for backticks)
"editor.fontFamily": "'Cascadia Code PL', 'Consolas', 'Courier New', monospace",
"editor.fontLigatures": false,
"terminal.integrated.fontFamily": "'CaskaydiaCove NF', 'Cascadia Code PL', 'Courier New', monospace"

Blog post:
https://www.hanselman.com/blog/taking-your-powershell-prompt-to-the-next-level-with-windows-terminal-and-oh-my-posh-3
# https://ohmyposh.dev/docs/upgrading/
#>
Set-PoshPrompt -Theme  ~/.go-my-posh.json
#endregion Custom prompt config


#region PSReadLine
<#
https://www.hanselman.com/blog/you-should-be-customizing-your-powershell-prompt-with-psreadline
https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1#L13-L21

# Show current settings
Get-PSReadLineOption
Get-PSReadLineKeyHandler
#>

# Enable history suggestions
Set-PSReadLineOption -PredictionSource History

# Clear history
# Get-PSReadlineOption | Select-Object -ExpandProperty HistorySavePath | Remove-Item -WhatIf

# Searching for commands with up/down arrow is really handy.  The
# option "moves to end" is useful if you want the cursor at the end
# of the line while cycling through history like it does w/o searching,
# without that option, the cursor will remain at the position it was
# when you used up arrow, which can be useful if you forget the exact
# string you started the search on.
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# add nicer tab completion
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
#endregion PSReadLine


# Source: https://gist.github.com/GABeech/98df2f95fb3a79cd2ccaa80a439aa975
function Clear-DeletedBranches {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [Alias("cdb")]
    param(
        [Parameter(Mandatory = $false)]
        [string]
        $GitDir = $PWD
    )

    $defaultBranch = ((git symbolic-ref --short refs/remotes/origin/HEAD) -split "/")[1]
    Write-Host "Switching to branch [$defaultBranch]..." -ForegroundColor Yellow
    git checkout $defaultBranch

    $branchesBefore = git branch -a

    $branchesToPrune = git remote prune origin --dry-run
    if ($branchesToPrune) {
        Write-Host "Branches to Be Pruned..." -ForegroundColor Green
        Write-Host $branchesToPrune -ForegroundColor Red

        if ($PSCmdlet.ShouldProcess("Remove Local Branches?")) {
            git remote prune origin
            $branchesAfter = git branch -a
            $removed = Compare-Object -ReferenceObject $branchesBefore -DifferenceObject $branchesAfter
            foreach ($b in $removed.InputObject) {
                $localName = $b.Split('/')[-1]
                git branch -D $localName
            }
        }
    } else {
        Write-Host "Nothing To prune" -ForegroundColor Green
    }

    Write-Host "`nPulling changes from default branch..." -ForegroundColor Green
    git pull

    Write-Host "`nCurrent branches..." -ForegroundColor Green
    git branch -a
}

# Aliases
Set-Alias -Name k -Value kubectl
Set-Alias -Name tf -Value terraform
