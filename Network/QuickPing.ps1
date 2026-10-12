# A one-liner to quickly ping your subnet for devices
$subnet = "192.168.0."; 1..254 | ForEach-Object -Parallel { $ip = "$($using:subnet)$_"; if ([System.Net.NetworkInformation.Ping]::new().Send($ip, 100).Status -eq "Success") { $ip } } -ThrottleLimit 254
