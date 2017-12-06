# Source: https://github.com/nyanhp/VoiceCommands/blob/master/VoiceCommands/VoiceCommands.psm1
#RequiredAssemblies = 'System.Speech'
Add-Type -AssemblyName 'System.Speech'

function Out-Voice {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]
        $Text,

        [ValidateSet('Male', 'Female')]
        [System.String]
        $Gender = 'Female'
    )

    begin {
        $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $synth.SelectVoiceByHints($Gender)
        $synth.SetOutputToDefaultAudioDevice()
    }

    process {
        $synth.Speak($Text)

    }

    end {
        $synth.Dispose()
    }
}

# New-Alias -Name ov -Value Out-Voice -Description "Alias for voice cmdlet Out-Voice" -Force

"PowerShell is awesome!" | Out-Voice