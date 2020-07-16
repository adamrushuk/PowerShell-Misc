<#
.SYNOPSIS
    Deletes Azure Shared Image Gallery (SIG) Image Versions
.DESCRIPTION
    Deletes Azure Shared Image Gallery (SIG) Image Versions for multiple SIG Images, with confirmation prompt and WhatIf functionality
.PARAMETER ResourceGroupName
    The resource group name where the SIG exists
.PARAMETER GalleryName
    The SIG name, eg: "my_sig"
.PARAMETER GalleryImageDefinitionNames
    The SIG image definition names, eg: "rhel7"
.PARAMETER GalleryImageVersionName
    The SIG image version names, eg: "1.20200629.1520".
    Also supports wildcard matching, eg:
        "1.20200[1,2,3]*"
        "1.20200[1,2,3,4,5]*"
        "1.2020041*"
.PARAMETER MaxLimit
    Aborts script if too many SIG images are matched.
    This is a safety check.
.PARAMETER WhatIf
    Does a dry-run and shows what SIG images would be deleted.
.EXAMPLE
    $params = @{
        ResourceGroupName           = "rg-images"
        GalleryName                 = "my_sig"
        GalleryImageDefinitionNames = "nginx"
        GalleryImageVersionName     = "*"
    }
    ./Delete-SigImageVersion.ps1 @params

    Deletes all versions of the "nginx" image definition in the "my_sig" SIG
.EXAMPLE
    $params = @{
        ResourceGroupName           = "rg-images"
        GalleryName                 = "my_sig"
        GalleryImageDefinitionNames = "nginx"
        GalleryImageVersionName     = "*"
    }
    ./Delete-SigImageVersion.ps1 @params -WhatIf

    Does a dry-run to only show what SIG image versions would be deleted for the "nginx" image definition in the "my_sig" SIG
.EXAMPLE
    $params = @{
        ResourceGroupName           = "rg-images"
        GalleryName                 = "my_sig"
        GalleryImageDefinitionNames = "nginx"
        GalleryImageVersionName     = "1.20200[1,2,3]*"
    }
    ./Delete-SigImageVersion.ps1 @params

    Deletes versions of the "nginx" image definition in the "my_sig" SIG for January,
    February, and March by partial date matching eg: "1.202001", "1.202002", and "1.202003"
.NOTES
    Author: Adam Rush
    GitHub: adamrushuk
    Twitter: @adamrushuk
#>
[CmdletBinding()]
param (

    [string]
    $ResourceGroupName,

    [string]
    $GalleryName,

    [string[]]
    $GalleryImageDefinitionNames,

    [string]
    $GalleryImageVersionName,

    [int]
    $MaxLimit = 30,

    [switch]
    $WhatIf
)

# Init
$imageVersionsToDelete = $null
$jobs = $null

foreach ($GalleryImageDefinitionName in $GalleryImageDefinitionNames) {

    Write-Host "Searching for [$GalleryImageDefinitionName] Image Versions starting with [$GalleryImageVersionName]"

    $imageVersions = $null

    $imageVersionParams = @{
        ResourceGroupName          = $ResourceGroupName
        GalleryName                = $GalleryName
        GalleryImageDefinitionName = $GalleryImageDefinitionName
        GalleryImageVersionName    = $GalleryImageVersionName
    }
    $imageVersions = Get-AzGalleryImageVersion @imageVersionParams -Verbose

    Write-Host "`n[$GalleryImageDefinitionName] Image Versions found starting with [$GalleryImageVersionName]: [$($imageVersions.Count)]" -ForegroundColor Yellow

    # Abort if we find no Image Versions
    if ($imageVersions.Count -eq 0) {
        Write-Host "Continuing...`n" -ForegroundColor Green
        continue
    }

    # Safety check
    if ($imageVersions.Count -gt $MaxLimit) {
        Write-Host "ABORTING, MaxLimit was hit. Over [$MaxLimit] Image Versions were found." -ForegroundColor Red
        return
    }


    # show Image Versions
    $imageVersions | Select-Object -ExpandProperty "Name"

    # confirm deletion
    $confirmation = $null
    while ($confirmation -ne "y") {
        if ($confirmation -eq 'n') { break }

        $confirmation = Read-Host "Are you sure you want to select these [$($imageVersions.Count)] Image Versions for deletion? [y/n]"
    }

    # queue
    if ($confirmation -eq "y") {
        Write-Output "Queuing [$($imageVersions.Count)] Image Versions..."
        $imageVersionsToDelete += $imageVersions
    } else {
        Write-Host "Skipping...`n" -ForegroundColor Yellow
    }
}

# delete
if ($imageVersionsToDelete.Count -gt 0) {
    Write-Output "Deleting [$($imageVersionsToDelete.Count)] Image Versions..."
    if ($WhatIf.IsPresent) {
        $imageVersionsToDelete | Remove-AzGalleryImageVersion -Force -WhatIf
    } else {
        $timer = [Diagnostics.Stopwatch]::StartNew()
        $jobs += $imageVersionsToDelete | Remove-AzGalleryImageVersion -Force -AsJob
    }
}

# wait for jobs to complete
if ($null -ne $jobs) {
    $jobs | Select-Object "Name"

    Write-Output "`nWaiting for [$($jobs.Count)] jobs to finish..."
    $jobs | Wait-Job
    $jobs | Receive-Job -Keep

    $timer.Stop()
    Write-Output "Deletion jobs completed in: [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s]"
}
