#!/usr/bin/env pwsh

# Get-UniqueString function that returns same result as Azure ARM/Bicep "uniqueString()" function
# ! WARNING testing doesnt get the same results
# https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-string#uniquestring
# https://stackoverflow.com/questions/48190183/how-do-i-replicate-the-azure-resource-manager-template-uniquestring-function-i

function Get-UniqueString ([string]$id, $length = 13) {
    $hashArray = (new-object System.Security.Cryptography.SHA512Managed).ComputeHash($id.ToCharArray())
    -join ($hashArray[1..$length] | ForEach-Object { [char]($_ % 26 + [byte][char]'a') })
}

Get-UniqueString "foobar"

$resourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-nsg-protection-testing"

# baxueypixkuuu
Get-UniqueString -id $resourceId.ToLower()

# aydhxshlgltuy
Get-UniqueString -id $resourceId
Get-UniqueString -id $resourceId -replace("/")
