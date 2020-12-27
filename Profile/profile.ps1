#requires -module posh-git, oh-my-posh
using namespace System.Management.Automation.Host



#region Custom prompt config
<#
# Install modules
Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease -Force -Verbose
Install-Module -Name oh-my-posh -Scope CurrentUser -AllowPrerelease -Verbose
Install-Module -Name PSReadLine -Scope CurrentUser -AllowPrerelease -Force -SkipPublisherCheck -Verbose
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


$profileLoadStart = Get-Date


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


#region Azure Context
# using namespace System.Management.Automation.Host
function Switch-AzContext {
    param (
        [Parameter(ValueFromPipeline)]
        # [Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext[]]
        [ValidateNotNullOrEmpty()]
        $Contexts = (Get-AzContext -ListAvailable | Sort-Object Name),
        [Switch]$GUI
    )

    $currentContext = Get-AzContext

    if (-not $Contexts) {throw 'No Contexts available, run Connect-AzAccount first!'}
    if ($Contexts.count -eq 1) {write-warning "Context $($Contexts.Name) the only context available"; return}

    $defaultIndex = 0
    $i = 1

    $ContextToSet = if ($GUI -and (Get-Command 'Out-Gridview' -ErrorAction SilentlyContinue)) {
        $Contexts | Out-Gridview -OutputMode Single -Title "Select a new Default Azure Context"
    } elseif ($psedition -ne 'Desktop' -and -not $IsWindows -and (Get-Command 'Out-ConsoleGridview' -ErrorAction SilentlyContinue)) {
        $Contexts | Out-ConsoleGridview -OutputMode Single -Title "Select a new Default Azure Context"
    } else {
        [ChoiceDescription[]]$contextPrompts = $Contexts.foreach{
            [ChoiceDescription]::New("&$i $($PSItem.Name)")
            if ($PSItem.Name -eq $currentContext.Name) {
                $defaultIndex = $i - 1
            }
            $i++
        }
        $result = $Host.UI.PromptForChoice(
            $null, #caption
            'Select a new Default Azure Context' + [Environment]::NewLine + '==================================', #message
            $ContextPrompts, #choices
            $defaultIndex #defaultChoice
        )
        $Contexts[$result]
    }

    Set-AzContext -Context $ContextToSet > $null
}

# TODO Finish Out-ConsoleGridView example
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
if ([Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightCtrl)) {

    Write-Host "Right CTRL key pressed...running Azure Login..."

    # Install-Module Microsoft.PowerShell.ConsoleGuiTools -Verbose -Repository PSGallery
    az login
    az account list --query "[].name" --output tsv
    az account list --query "sort_by([].{SubscriptionName:name}, &SubscriptionName)" --output tsv | Out-ConsoleGridView -PassThru
    az account list --query "[].name" --output tsv | Out-ConsoleGridView -PassThru
    az subscription show
    az account set --subscription $env:ARM_SUBSCRIPTION_ID
    $subscription = Get-AzSubscription | Out-ConsoleGridView -PassThru
    $subscription
}
#endregion Azure Context


# Source: https://gist.github.com/GABeech/98df2f95fb3a79cd2ccaa80a439aa975
function Clear-DeletedBranches {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [Alias("cdb")]
    param(
        [Parameter(Mandatory = $false)]
        [string]
        $GitDir = $PWD
    )

    $defaultBranch = ((git.exe symbolic-ref --short refs/remotes/origin/HEAD) -split "/")[1]
    Write-Host "Switching to branch [$defaultBranch]..." -ForegroundColor Yellow
    git.exe checkout $defaultBranch

    $before = git.exe branch -a

    $prun = git.exe remote prune origin --dry-run
    if ($prun) {
        Write-Host "Branches to Be Pruned..." -ForegroundColor Green
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

    Write-Host "`nPulling changes from default branch..." -ForegroundColor Green
    git.exe pull

    Write-Host "`nCurrent branches..." -ForegroundColor Green
    git.exe branch -a
}

$profileLoadEnd = Get-Date
$profileLoadTime = $profileLoadEnd - $profileLoadStart
$loadTimeString = "Profile Loaded [{0:g}]" -f $profileLoadTime
Write-Output $loadTimeString
