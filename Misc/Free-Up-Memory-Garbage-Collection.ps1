# Clear down variables and free up the memory
Get-ChildItem variable:
(Get-ChildItem variable:).Name | Where-Object { $_ -imatch '^vA|^vC' } | Foreach-Object { Remove-Variable $_ }
[System.GC]::Collect()

############################

# Source: https://dmitrysotnikov.wordpress.com/2012/02/24/freeing-up-memory-in-powershell-using-garbage-collector/
# Find out how much memory is being consumed by your Sesssion:
[System.gc]::gettotalmemory("forcefullcollection") /1MB
# Force a collection of memory by the garbage collector:
[System.gc]::collect()
# Dump all variables not locked by the system:
foreach ($i in (Get-ChildItem variable:/*)) {Remove-Variable -ea 0 -verbose $i.Name}
#Check memory usage again and force another collection:
[System.gc]::gettotalmemory("forcefullcollection") /1MB
[System.gc]::collect()
#Check Memory once more:
[System.gc]::gettotalmemory("forcefullcollection") /1MB

#You can examine the difference before and after with:
Get-Process powershell* | Select-Object *memory*

#or with something more complicated:

Get-Process powershell* | Select-Object *memory*, @{Name='VirMemMB';Expression={($_.VirtualMemorySize64)/1MB}}, @{Name='PriMemMB';Expression={($_.PrivateMemorySize64)/1MB}} | Format-Table -auto
