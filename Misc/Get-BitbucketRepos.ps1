# Vars
$domain = 'bitbucket.org'
$account = 'MyAccountName'
$userPass = 'user@domain.com:MyPassword' # Format: 'username:password'
$basicAuthHeader = "Basic " + [System.Convert]::ToBase64String([System.Text.ASCIIEncoding]::ASCII.GetBytes($userPass))
$uri = "https://api.$domain/2.0/repositories/$account"
$headers = @{
    Authorization = $basicAuthHeader
}

# Get repos
$repos = Invoke-RestMethod -Uri $uri -Headers $headers

# Build full git clone command for each repo
foreach ($repo in $repos.values) {
    # Need to output something like this:
    $gitCloneCommand = "git clone git@$($domain):$($repo.full_name).git"
    Write-Host "Command to run is: $gitCloneCommand"

    Invoke-Expression $gitCloneCommand
}
