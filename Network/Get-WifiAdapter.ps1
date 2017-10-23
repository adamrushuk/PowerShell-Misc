# Get wifi adapter details
$wifiAdapter = Get-NetAdapter wi-fi
$wifiAdapter

# Show IP
$wifiAdapter | Get-NetIPAddress

# Reset
$wifiAdapter | Restart-NetAdapter
