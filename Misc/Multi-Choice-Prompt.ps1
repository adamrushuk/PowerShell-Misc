# Multi-choice prompt
$choices = @(
    New-Object "System.Management.Automation.Host.ChoiceDescription" "&Apple", "Apple"
    New-Object "System.Management.Automation.Host.ChoiceDescription" "&Banana", "Banana"
    New-Object "System.Management.Automation.Host.ChoiceDescription" "&Orange", "Orange"
)

$defaults = [int[]]@(0, 2)
$selected = $host.UI.PromptForChoice("Choose a fruit", "You may choose more than one", $choices, $defaults)

Write-Host "$($selected) was selected"
