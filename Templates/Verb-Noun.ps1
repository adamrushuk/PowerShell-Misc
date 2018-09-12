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

    begin {
        # Do tasks like opening a DB connection
    }

    process {

        #region TaskSummary
        foreach ($item in $Name) {
            $taskMessage = "TaskMessageDescription: [$item]"
            Write-Verbose -Message "STARTED: $taskMessage..."

            try {
                if ($PSBoundParameters.ContainsKey('OptionalParam')){
                    # Do optional task
                }

                # Get something
                $object = $item | Get-Something -ErrorAction 'Stop'

                # Output to pipeline
                [PSCustomObject]@{
                    Name          = $object.Name
                    Id            = $object.Id
                }
            }
            catch {
                Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
                throw $_
            }

            # Check for incorrect status
            if ($object.status -eq 'failed') {
                throw "ERROR: Status of [$item] is: [failed]"
            }

            Write-Verbose -Message "FINISHED: $taskMessage."
        }
        #endregion TaskSummary

    } # End process

    end {
        # Do tasks like closing a DB connection
    }

} # End function
