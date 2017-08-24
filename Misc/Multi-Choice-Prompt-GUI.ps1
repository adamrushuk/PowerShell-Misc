$Title = "Title"
$Info = "Pick Something!"
$options = Write-Output Option1 Option2 Option3
$defaultchoice = 2
$selected =  $host.UI.PromptForChoice($Title , $Info , $Options, $defaultchoice)
$options[$selected]