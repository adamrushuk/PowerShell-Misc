# #################################################################
# ScienceLogic/EM7 - Device Alert Gen                             #
# Created by: Lorenzo Thomai                                      #
# #################################################################

function Load-PowerCLI {
    Add-PSSnapin VMware.VimAutomation.Core
    Add-PSSnapin VMware.VimAutomation.Vds
    Add-PSSnapin VMware.VumAutomation
    . "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}


function SLAPI($text) {
    $url = "https://10.10.10.10/api/alert"
    $user = "SL_username"
    $pass = "SL_password"

    $json = "{""force_ytype"":""0"",
            ""force_yid"":""0"",""force_yname"":""1"",
            ""message"": ""$text"",""value"":"""",""threshold"":""0"",
            ""message_time"":""0"",
            ""aligned_resource"":""/device/123""}"
    $json
    $secpasswd = ConvertTo-SecureString -String $pass -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $secpasswd
    #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} (This one liner will ignore SSL certificate error)
    $r = Invoke-RestMethod -Uri $url -Method Post -Credential $cred -Body $json -ContentType 'application/json'

}

function vCloud {
    $vcdinstance = "vcd"
    $user = 'vcd_username'
    $pass = 'vcd_password'
    connect-ciserver -server $vcdinstance -User $user -Password $pass

    $output = @()
    $prov = Get-ProviderVdc | Select-Object Name
    $extNetworks = Get-ExternalNetwork
    foreach ($extNet in $extNetworks) {
        $obje = new-object psobject
        $obje | add-member noteproperty Name ($extNet)
        $obje | add-member noteproperty UsedIP ($extNet.UsedIpCount)
        $obje | add-member noteproperty TotalIP ($extNet.TotalIpCount)
        $obje | add-member noteproperty PercUsed ([math]::Round($extNet.UsedIpCount / $extNet.TotalIpCount * 100))
        $output += $obje

        $PU = ([math]::Round($extNet.UsedIpCount / $extNet.TotalIpCount * 100))
        $threshold = 85

        if ($PU -gt $threshold) {
            $name = $extNet.Name | Out-String
            $exception = "ecs_storage_data" | Out-String

            if ($name -ne $exception ) {
                $t1 = "The "
                $t2 = " has exceeded the threshold of 85% utilization of free IPs and is: "
                SLAPI $t1, $extNet, $t2, $PU
            }
        }
    }
    Disconnect-ciserver $vcdinstance -Confirm:$false
}

Load-PowerCLI
vCloud
