# Source: https://4sysops.com/archives/setting-powershell-breakpoints-on-an-exception/

$action = {
    if ($_ -and ($stacktrace -notmatch '^\s*at System\.Management\.Automation\.ExceptionHandlingOps\.CheckActionPreference') -and ($stacktrace -notmatch '^\s*at System\.Management\.Automation\.MshCommandRuntime\.ThrowTerminatingError\(ErrorRecord errorRecord\)\s*$')) {
        break
    }
}
$null = Set-PSBreakpoint -Variable stackTrace -Mode Write -Action $action
