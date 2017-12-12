# Change DVD Drive from D to Z
$drv = Get-WmiObject win32_volume -filter 'DriveLetter = "D:"'
$drv.DriveLetter = "Z:"
$drv.Put() 

# Bring Disk 2 online (should be Local disk D: with 80GB space)
$Disk2 = Get-Disk -Number 1
$Disk2 | Set-Disk -IsOffline $False
$Disk2 | Set-Disk -IsReadOnly $False
