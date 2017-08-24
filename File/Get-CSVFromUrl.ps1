# Get a CSV file via HTTPS when self-signed certs are in use
$Uri = 'https://10.10.10.10/somedata.csv'

# Accept untrusted SSL cert
if ( -not ("TrustAllCertsPolicy" -as [type])) {

    Add-Type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
}
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Get CSV file
Invoke-RestMethod $Uri | ConvertFrom-Csv
