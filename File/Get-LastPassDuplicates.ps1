# Get LastPass duplicate passwords
# Export data to a CSV: https://lastpass.com/support.php?cmd=showfaq&id=1206
$Data = Import-Csv -Path 'C:\Path\To\Passwords.csv'
$DataGrouped = $Data | Group-Object -Property 'password'
$DataGrouped | Where-Object {$_.Count -gt 2} | Sort-Object Count -Descending |
    Select-Object Count, Name, @{n = 'Sites'; e = { ( $_.Group.Url | ForEach-Object {$_.split('/')[2]} ) -join "`n" }} | Format-Table -Wrap