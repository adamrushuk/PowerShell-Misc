# show duplicate aad groups
# must be run from Windows PowerShell session

# install module
Install-module AzureADPreview -Verbose
Get-Module AzureADPreview -Verbose -ListAvailable

# login
# open browser (but may not come into focus)
Connect-AzureAD -Confirm

# get all aad groups
$aadGroups = Get-AzureADGroup -All $true
$aadGroups.Count
$aadGroups | Sort-Object -Property DisplayName

# group aad groups
$aadGroupsGrouped = $aadGroups | Group-Object -Property DisplayName

# find duplicate group names
$aadGroupsGroupedDupes = $aadGroupsGrouped | Where-Object Count -GT 1
$aadGroupsGroupedDupes | Sort-Object -Property Count -Descending | Format-Table -AutoSize
