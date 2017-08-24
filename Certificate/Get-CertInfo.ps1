# Find all certs with given Thumbprint
$Thumbprint = "12:34:56:78:90:aa:bb:cc:dd:ee:ff:12:34:56:78:90:aa:bb:cc:dd" -replace ':' # Remove colons from thumbprint for comparison
Get-ChildItem Cert: -Recurse | Where-Object { $_.Thumbprint -match $Thumbprint }

# Find all certs where Subject name includes 'DigiCert'
Get-ChildItem Cert: -Recurse | Where-Object { $_.Subject -match 'DigiCert' }
