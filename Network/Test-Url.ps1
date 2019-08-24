# https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/test-web-site-availability
function Test-Url {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Url
    )

    Add-Type -AssemblyName System.Web

    $check = "https://isitdown.site/api/v3/"
    $encoded = [System.Web.HttpUtility]::UrlEncode($url)
    $callUrl = "$check$encoded"

    Invoke-RestMethod -Uri $callUrl #| Select-Object -Property Host, IsItDown, Response_Code
}

$response = Test-Url -Url thehypepipe.co.uk
$response
