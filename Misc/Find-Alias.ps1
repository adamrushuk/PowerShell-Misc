# Finds alias for commands matching a regex
$commandRegex = 'stop'
Get-Alias | Select-Object Name, ResolvedCommand | Where-Object {$_.ResolvedCommand -match $commandRegex}