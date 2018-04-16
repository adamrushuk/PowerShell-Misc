# Source: https://gist.github.com/jeffpatton1971/a908cac57489e6ca59a6
# Modified by Adam Rush to support remote event collection
Function Get-WinEventTail {
    <#
        .SYNOPSIS
            A tail cmdlet for Eventlogs
        .DESCRIPTION
            This function will allow you to tail Windows Event Logs. You specify
            a Logname for either the original logs, Application, System and Security or
            the new format for the newer logs Microsoft-Windows-PowerShell/Operational
        .PARAMETER LogName
            Specify a valid Windows Eventlog name
        .PARAMETER ShowExisting
            An integer to show the number of events to start with, the default is 10
        .PARAMETER ComputerName
            Specify a valid Computer name
        .PARAMETER Credential
            Supply a valid Credentials for computer
        .EXAMPLE
            Get-WinEventTail -LogName Application
               ProviderName: ESENT
            TimeCreated                     Id LevelDisplayName Message
            -----------                     -- ---------------- -------
            10/9/2014 11:55:51 AM          102 Information      svchost (7528) Instance: ...
            10/9/2014 11:55:51 AM          105 Information      svchost (7528) Instance: ...
            10/9/2014 11:55:51 AM          326 Information      svchost (7528) Instance: ...
            10/9/2014 12:05:49 PM          327 Information      svchost (7528) Instance: ...
            10/9/2014 12:05:49 PM          103 Information      svchost (7528) Instance: ...

            Shows Application log for localhost
        .EXAMPLE
            Get-WinEventTail -LogName Application -ComputerName server01 -Credential (Get-Credential)

               ProviderName: ESENT
            TimeCreated                     Id LevelDisplayName Message
            -----------                     -- ---------------- -------
            10/9/2014 11:55:51 AM          102 Information      svchost (7528) Instance: ...
            10/9/2014 11:55:51 AM          105 Information      svchost (7528) Instance: ...
            10/9/2014 11:55:51 AM          326 Information      svchost (7528) Instance: ...
            10/9/2014 12:05:49 PM          327 Information      svchost (7528) Instance: ...
            10/9/2014 12:05:49 PM          103 Information      svchost (7528) Instance: ...

            Shows Application log for server01
        .NOTES
            FunctionName : Get-WinEventTail
            Created by   : jspatton
            Date Coded   : 10/09/2014 13:20:22
        .LINK
            https://code.google.com/p/mod-posh/wiki/ComputerManagement#Get-WinEventTail
        .LINK
            http://stackoverflow.com/questions/15262196/powershell-tail-windows-event-log-is-it-possible
    #>
    [CmdletBinding()]
    Param
    (
        [string]$LogName = 'System',
        [int]$ShowExisting = 10,
        [string]$ComputerName = 'localhost',
        [pscredential]$Credential
    )
    Begin {
        if ($ShowExisting -gt 0) {
            $events = Get-WinEvent -LogName $LogName -MaxEvents $ShowExisting -ComputerName $ComputerName -Credential $Credential
            $events | Sort-Object -Property RecordId
            $firstRecordId = $events[0].RecordId
        }
        else {
            $firstRecordId = (Get-WinEvent -LogName $LogName -MaxEvents 1 -ComputerName $ComputerName -Credential $Credential).RecordId
        }
    }
    Process {
        while ($true) {
            Start-Sleep -Seconds 1
            $currentRecordId = (Get-WinEvent -LogName $LogName -MaxEvents 1 -ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue).RecordId
            if ($currentRecordId -gt $firstRecordId) {
                Get-WinEvent -LogName $LogName -MaxEvents ($currentRecordId - $firstRecordId) -ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue | Sort-Object -Property RecordId
            }
            $firstRecordId = $currentRecordId
        }
    }
    End {
    }
}
