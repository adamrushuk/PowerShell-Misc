# Invoke-AzRestMethod examples

# ! dont include "https://management.azure.com/" as this is prepended to the path

# List blueprints definitions
# https://docs.microsoft.com/en-us/rest/api/blueprints/blueprints/list#definitions
$managementGroupId = "00000000-0000-0000-0000-000000000000"
$resourceScope = "/providers/Microsoft.Management/managementGroups/$managementGroupId"
$apiUri = "$resourceScope/providers/Microsoft.Blueprint/blueprints?api-version=2018-11-01-preview"
Invoke-AzRestMethod -Method "GET" -Path $apiUri #-Debug

# List blueprints assignments
# https://docs.microsoft.com/en-us/rest/api/blueprints/assignments/list
$managementGroupId = "00000000-0000-0000-0000-000000000000"
$resourceScope = "/providers/Microsoft.Management/managementGroups/$managementGroupId"
$apiUri = "$resourceScope/providers/Microsoft.Blueprint/blueprintAssignments?api-version=2018-11-01-preview"
Invoke-AzRestMethod -Method "GET" -Path $apiUri #-Debug
