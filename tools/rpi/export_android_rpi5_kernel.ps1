param(
    [string]$KernelOut = "bazel-bin/common/rpi5",
    [string]$Destination = "..\android_device_brcm_rpi5-kernel"
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $repoRoot
$kernelOutPath = Join-Path $repoRoot $KernelOut
$destinationPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $Destination))
$modulesPath = Join-Path $destinationPath "modules"
$overlaysPath = Join-Path $destinationPath "overlays"

$dtbNames = @(
    "bcm2712d0-rpi-5-b.dtb",
    "bcm2712-rpi-500.dtb",
    "bcm2712-rpi-5-b.dtb",
    "bcm2712-rpi-cm5-cm4io.dtb",
    "bcm2712-rpi-cm5-cm5io.dtb",
    "bcm2712-rpi-cm5l-cm4io.dtb",
    "bcm2712-rpi-cm5l-cm5io.dtb"
)

if (-not (Test-Path $kernelOutPath)) {
    throw "Kernel output path not found: $kernelOutPath"
}

New-Item -ItemType Directory -Force -Path $destinationPath, $modulesPath, $overlaysPath | Out-Null

function Copy-SingleArtifact {
    param(
        [string]$FileName,
        [string]$TargetDirectory
    )

    $artifact = Get-ChildItem -Path $kernelOutPath -Recurse -File -Filter $FileName | Select-Object -First 1
    if (-not $artifact) {
        throw "Required artifact not found: $FileName"
    }

    Copy-Item -Path $artifact.FullName -Destination (Join-Path $TargetDirectory $FileName) -Force
}

Copy-SingleArtifact -FileName "Image" -TargetDirectory $destinationPath

foreach ($dtbName in $dtbNames) {
    Copy-SingleArtifact -FileName $dtbName -TargetDirectory $destinationPath
}

$overlaySource = Get-ChildItem -Path $kernelOutPath -Recurse -Directory -Filter overlays |
    Where-Object { (Get-ChildItem -Path $_.FullName -Filter *.dtbo -File -ErrorAction SilentlyContinue).Count -gt 0 } |
    Select-Object -First 1
if ($overlaySource) {
    Get-ChildItem -Path $overlaysPath -File | Remove-Item -Force -ErrorAction SilentlyContinue
    Copy-Item -Path (Join-Path $overlaySource.FullName "*") -Destination $overlaysPath -Recurse -Force
}

Get-ChildItem -Path $modulesPath -Filter *.ko -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $kernelOutPath -Recurse -File -Filter *.ko | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination (Join-Path $modulesPath $_.Name) -Force
}

Write-Host "Exported Raspberry Pi 5 kernel artifacts to $destinationPath"
