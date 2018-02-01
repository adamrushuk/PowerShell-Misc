#requires -module posh-git, PSColor

# SSH Agent handles keys for apps like VSCode
$privateSshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"

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
        Add-SshKey $privateSshKeyPath -Quiet
    }
    else {
        Write-Verbose 'The SSH agent has identities'
    }
}


# Am I running as Administrator?
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host

    if (Test-Administrator) {
        # Use different username if elevated
        Write-Host "(Admin) : " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor DarkYellow
    Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor Magenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray

    if ($s -ne $null) {
        # color for PSSessions
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ") " -NoNewline -ForegroundColor DarkGray
        Write-Host " : " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\', '\\'), "~") -NoNewline -ForegroundColor Blue
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkMagenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray

    $global:LASTEXITCODE = $realLASTEXITCODE

    Write-VcsStatus

    Write-Host ""

    return "> "
}
