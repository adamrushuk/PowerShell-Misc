Import-Module 'oh-my-posh', 'posh-git'

# Set oh-my-posh theme
Set-Theme -Name tehrob

# SSH Agent handles keys for apps like VSCode
$privateSshKeyPath = "$env:USERPROFILE\OneDrive\.ssh\id_rsa"

if (Test-Path -Path $privateSshKeyPath) {
    Write-Verbose "Private SSH key exists [$privateSshKeyPath]"

    if (Get-Process -Name 'ssh-agent' -ErrorAction 'SilentlyContinue') {
        Write-Verbose 'ssh-agent process already exists'
    }
    else {
        Write-Verbose 'Starting ssh-agent process'
        Start-SshAgent -Quiet
    }

    # Load Private SSH key
    if ($(ssh-add -l) -match 'The agent has no identities') {
        Write-Verbose "The SSH agent has no identities, loading key from [$privateSshKeyPath]"
        Add-SshKey $privateSshKeyPath -q
    }
    else {
        Write-Verbose 'The SSH agent has identities'
    }
}
