function Verb-Noun {
    <#
        .SYNOPSIS
        Summary

        .DESCRIPTION
        Detailed description

        .PARAMETER Name
        Specifies the name of a thing

        .PARAMETER OptionalParam
        Specifies the name of an optional thing

        .INPUTS
        System.String

        .OUTPUTS
        System.Management.Automation.PSCustomObject

        .EXAMPLE
        Verb-Noun

        Returns all things.

        .EXAMPLE
        Verb-Noun -Name 'Thing01'

        Returns a single thing.

        .EXAMPLE
        Verb-Noun -Name 'Thing01', 'Thing02'

        Returns multiple things.

        .NOTES
        Author: Adam Rush
        GitHub: adamrushuk
        Twitter: @adamrushuk
    #>
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $OptionalParam
    )

    Begin {}

    Process {

        try {

            if ($PSBoundParameters.ContainsKey('OptionalParam')){
                # Do something
            }

            foreach ($Item in $Collection) {

                # Do something
                $Object = $Item | Get-Stuff

                # Output to pipeline
                [PSCustomObject]@{
                    Name          = $Object.Name
                    Id            = $Object.Id
                }

            }

        }
        catch [exception] {

            throw $_

        }

    } # End process

} # End function
