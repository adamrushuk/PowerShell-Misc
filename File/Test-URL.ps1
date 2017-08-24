# Created by Adam Rush on 2017-01-23

# URL and Proxy variables - PLEASE CHANGE
$URL = "http://google.co.uk"
$ProxyURL = "http://proxy.example.net:8080"

# Parameters for web request
$Params = @{
    Uri = $URL
    Proxy = $ProxyURL
    ProxyUseDefaultCredentials = $true
}

# Path for the CSV export
$OutputTimestamp = (Get-Date -Format ("yyyy-MM-dd_HH-mm-ss"))
$OutputFolder = "$(Split-Path $script:MyInvocation.MyCommand.Path)\URL-Response-Stats"
$OutPath = "$($OutputFolder)\URL-Response-Stats_$($OutputTimestamp).csv"

# Create save path if it does not exist
if(!(Test-Path -Path $OutputFolder)){
	$null = New-Item -ItemType Directory -Force -Path $OutputFolder
}

Write-Host "Use CTRL+C to stop script" -ForegroundColor Yellow

 while ($true) {

     $Timestamp = Get-Date

     $ResponseTime = Measure-Command -Expression {
         $Response = Invoke-WebRequest @Params
     }

     $Milliseconds = $ResponseTime.TotalMilliseconds
     write-host $Milliseconds

     $Row = [pscustomobject] @{
        Timestamp = $Timestamp
        Milliseconds = $Milliseconds
        URL = $URL
     }
     Write-Output $Row | Export-Csv -Path $OutPath -Append -NoTypeInformation -UseCulture
     Start-Sleep 2
 }
