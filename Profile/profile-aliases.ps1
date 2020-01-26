# Alias examples for a PowerShell profile

#region Aliases
function Get-VagrantStatus {
    & vagrant.exe status
}
Set-Alias -Name 'vs' -Value 'Get-VagrantStatus'

function Get-VagrantGlobalStatus {
    & vagrant.exe global-status
}
Set-Alias -Name 'vgs' -Value 'Get-VagrantGlobalStatus'

function Get-VagrantGlobalStatusPrune {
    & vagrant.exe global-status --prune
}
Set-Alias -Name 'vgsp' -Value 'Get-VagrantGlobalStatusPrune'

function Invoke-VagrantUp {
    & vagrant.exe up
}
Set-Alias -Name 'vup' -Value 'Invoke-VagrantUp'

function Invoke-VagrantUpLog {
    & vagrant.exe up 2>&1 | Tee-Object -FilePath 'vagrant.log'
}
Set-Alias -Name 'vupl' -Value 'Invoke-VagrantUpLog'

function Invoke-VagrantHalt {
    & vagrant.exe halt
}
Set-Alias -Name 'vh' -Value 'Invoke-VagrantHalt'

function Invoke-VagrantDestroy {
    & vagrant.exe destroy
}
Set-Alias -Name 'vd' -Value 'Invoke-VagrantDestroy'


function Invoke-VagrantSnapshotList {
    & vagrant.exe snapshot list
}
Set-Alias -Name 'vsl' -Value 'Invoke-VagrantSnapshotList'

function Invoke-VagrantSnapshotRestoreNP {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $Name
    )
    & vagrant.exe snapshot restore $Name --no-provision
}
Set-Alias -Name 'vsr' -Value 'Invoke-VagrantSnapshotRestoreNP'

function Invoke-VagrantSnapshotSave {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $Name
    )
    & vagrant.exe snapshot save $Name -f
}
Set-Alias -Name 'vss' -Value 'Invoke-VagrantSnapshotSave'
#endregion Aliases
