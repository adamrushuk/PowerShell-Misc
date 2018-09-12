# Start logging
Start-Transcript -Path 'C:\logs\Verb-Noun-transcript.log' -NoClobber

# Import module that includes "Verb-Noun" function
Import-Module -Name 'MyModuleName' -Verbose

# Vars
$params = @{
    Name = 'Thing01', 'Thing02'
    OptionalSwitch = $true
}

# Call function
Verb-Noun @params -Verbose

# Stop logging
Stop-Transcript
