# This will remove 'CN=SomeObject' from the string
$text = 'CN=SomeObject,OU=TestFolder01,OU=TestFolder02,DC=domain,DC=local'
$Out = $text.Split(',')
$Out[1..$($out.count)] -join ','
