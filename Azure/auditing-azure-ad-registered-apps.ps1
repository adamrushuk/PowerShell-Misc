# Auditing Azure AD Registered Applications
# source: https://blog.darrenjrobinson.com/auditing-azure-ad-registered-applications/

# Pre-reqs
# Install-Module -Name MSAL.PS -Verbose
#
# Add API perms (application) to the app reg used in this script
# - Microsoft Graph => Directory.Read.All
# - Microsoft Graph => AuditLog.Read.All

# Creds
$tenantID = ''
$clientID = ''
$clientSecret = (ConvertTo-SecureString '' -AsPlainText -Force)
$accessToken = Get-MsalToken -clientID $clientID -clientSecret $clientSecret -tenantID $tenantID | Select-Object -Property AccessToken

# MS Graph Apps URI
$aadAppsURI = 'https://graph.microsoft.com/v1.0/applications'
# Get Expiring Creds in x Days
$expiryCheck = 60
$now = (Get-Date).ToUniversalTime()
$expiryLimit = $now.AddDays($expiryCheck)
# MS Graph Directory Audit URI
# $signInsURI = 'https://graph.microsoft.com/beta/auditLogs/directoryAudits'
$signInsURI = 'https://graph.microsoft.com/v1.0/auditLogs/directoryAudits'

# Report Template
$aadAppReportTemplate = [pscustomobject][ordered]@{
    displayName     = $null
    createdDateTime = $null
    signInAudience  = $null
}

# Get Apps
$aadApplications = @()
$aadApps = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } `
    -Uri  $aadAppsURI `
    -Method Get


$aadApps.value.Count

if ($aadApps.value) {
    $aadApplications += $aadApps.value
    # More Apps?
    if ($aadApps.'@odata.nextLink') {
        $nextPageURI = $aadApps.'@odata.nextLink'
        do {
            $aadApps = $null
            $aadApps = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } `
                -Uri  $nextPageURI `
                -Method Get
            if ($aadApps.value) {
                $aadApplications += $aadApps.value
                $aadApplications.value.Count
            }
            if ($aadApps.'@odata.nextLink') {
                $nextPageURI = $aadApps.'@odata.nextLink'
            }
            else {
                $nextPageURI = $null
            }
        } until (!$nextPageURI)
    }
}

$aadApplications = $aadApplications | Sort-Object -Property createdDateTime -Descending
$aadAppsReport = @()
$expiringCredsApps = @()

foreach ($app in $aadApplications) {
    $blnExpiringCreds = $false
    # Report Output
    $reportData = $aadAppReportTemplate.PsObject.Copy()
    $reportData.displayName = $app.displayName
    $reportData.createdDateTime = $app.createdDateTime
    $reportData.signInAudience = $app.signInAudience

    # Key Expiry
    if ($app.keyCredentials) {
        $keys = @()
        foreach ($cred in $app.keyCredentials) {
            [datetime]$keyExpiry = $cred.endDateTime
            if ($keyExpiry -lt $expiryLimit) {
                Write-Warning "$($app.displayName): Key expired/expiring on $($keyExpiry)"
                $blnExpiringCreds = $true
            }
            $keys += $app.keyCredentials | Select-Object -Property @{Name = 'displayName'; Expression = { $cred.displayName } }, @{Name = 'keyId'; Expression = { $cred.keyId } }, @{Name = 'startDateTime'; Expression = { $cred.startDateTime } }, @{Name = 'endDateTime'; Expression = { $cred.endDateTime } }
        }
        $reportData | Add-Member -Type NoteProperty -Name "keyCredentials" -Value @($keys)
    }

    # Password Expiry
    if ($app.passwordCredentials) {
        $passwords = @()
        foreach ($cred in $app.passwordCredentials) {
            [datetime]$keyExpiry = $cred.endDateTime
            if ($keyExpiry -lt $expiryLimit) {
                Write-Warning "$($app.displayName): Password expired/expiring on $($keyExpiry)"
                $blnExpiringCreds = $true
            }
            $passwords += $app.passwordCredentials | Select-Object -Property @{Name = 'displayName'; Expression = { $cred.displayName } }, @{Name = 'keyId'; Expression = { $cred.keyId } }, @{Name = 'startDateTime'; Expression = { $cred.startDateTime } }, @{Name = 'endDateTime'; Expression = { $cred.endDateTime } }
        }
        $reportData | Add-Member -Type NoteProperty -Name "passwordCredentials" -Value @($passwords)
    }

    # SignIns
    $appSignIns = $null
    $appSignIns = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } `
        -Uri  "$($signInsURI)?&`$filter=targetResources/any(t: t/id eq `'$($app.id)`')" `
        -Method Get

    if ($appSignIns.value) {
        "$($app.displayName): $($appSignIns.value.Count) recent signIns"
        $reportData | Add-Member -Type NoteProperty -Name "recentSignIns" -Value $appSignIns.value.Count
    }
    else {
        "$($app.displayName): $($appSignIns.value.Count) recent signIns"
        $reportData | Add-Member -Type NoteProperty -Name "recentSignIns" -Value '0'
    }
    $aadAppsReport += $reportData

    if ($blnExpiringCreds) {
        $expiringCredsApps += $reportData
    }
}

$expiringCredsApps.count
$expiringCredsApps | Format-Table
$expiringCredsApps | Export-Csv -Path expiringCredsApps.csv

# Report
$aadAppsReport | Format-Table -AutoSize
$aadAppsReport | Export-Csv -Path aadAppsReport.csv
