# Configure useful Folder Options
$key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

Write-Host "Enabling showing hidden files"
Set-ItemProperty $key Hidden 1

Write-Host "Disabling hiding extensions for known files"
Set-ItemProperty $key HideFileExt 0

Write-Host "Disabling showing hidden operation system files"
Set-ItemProperty $key ShowSuperHidden 0

Write-Host "Uncheck sharing wizard"
Set-ItemProperty $key SharingWizardOn 0

Write-Host "Restore previous folder windows at logon"
Set-ItemProperty $key PersistBrowsers 1

Write-Host "Restarting explorer shell to apply registry changes"
Stop-Process -ProcessName explorer
