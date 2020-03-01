#region TASK_DESCRIPTION
# Update task description
$taskMessage = "TASK_DESCRIPTION"
Write-Verbose "STARTED: $taskMessage..."

# Run CLI command
$outputJson = az EXTERNAL_COMMAND --name $env:MY_ENV_VAR | ConvertFrom-Json

# Error handling
if (-not $outputJson) {
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
} else {
    Write-Verbose "FINISHED: $taskMessage."
}
#endregion
