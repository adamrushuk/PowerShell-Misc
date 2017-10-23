# Find all parameters with a given term (like "path") in the name
$parameterName = '*path*'
$commands = Get-Command -ParameterName $parameterName
$commands.Count

$allParameters = $commands | Select-Object -ExpandProperty Parameters
$allParameters.Count

$allParameters.Keys | Where-Object {$_ -like $parameterName} | Select-Object -Unique | Sort-Object