<#
.SYNOPSIS
    Deletes Azure Resource Groups with a given prefix
.DESCRIPTION
    Deletes Azure Resource Groups with a given prefix, with confirmation prompt and WhatIf functionality
.PARAMETER Prefix
    The prefix string that matches the start of the Resource Group name
    # "a6wx6" would match resource group called "a6wx6-rg-blahblah"
.PARAMETER WhatIf
    Does a dry-run and shows what Resource Groups would be deleted
.EXAMPLE
    ./Delete-ResourceGroups.ps1 -Prefix a6wx6

    Deletes all Resource Groups starting with "a6wx6", eg:
    "a6wx6-rg-one"
    "a6wx6-rg-two"
.EXAMPLE
    ./Delete-ResourceGroups.ps1 -Prefix a6wx6 -WhatIf

    Shows what Resource Groups would be deleted
.NOTES
    Author: Adam Rush
    GitHub: adamrushuk
    Twitter: @adamrushuk
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [string]
    $Prefix,

    [switch]
    $WhatIf
)

$resourceGroups = Get-AzResourceGroup -Name "$prefix*"
Write-Output "Resource groups found: [$($resourceGroups.Count)]"

# abort if we find no resource groups
if ($resourceGroups.Count -eq 0) {
    Write-Output "Aborting"
    return
}

# show resource groups
$resourceGroups | Select-Object -ExpandProperty "ResourceGroupName"
Write-Output ""

# confirm deletion
$confirmation = $null
while($confirmation -ne "y") {
    if ($confirmation -eq 'n') {
        Write-Output "Aborting"
        return
    }
    $confirmation = Read-Host "Are you Sure You Want To Delete [$($resourceGroups.Count)] Resource Groups? [y/n]"
}

# delete
if ($confirmation -eq "y") {
    Write-Output "Deleting [$($resourceGroups.Count)] Resource Groups..."

    if ($WhatIf.IsPresent) {
        $resourceGroups | Remove-AzResourceGroup -Force -WhatIf
    } else {
        $jobs = $resourceGroups | Remove-AzResourceGroup -Force -AsJob
        $jobs

        Write-Output "Waiting for jobs to finish..."
        $jobs | Wait-Job
        $jobs | Receive-Job -Keep
    }
} else {
    Write-Output "Aborting"
}
