<#
.SYNOPSIS
    Sets "version_number" in a Thunderstore manifest.json from the VERSION file.

.DESCRIPTION
    Called by package_thunderstore.bat so the packaged manifest can never drift from the
    version compiled into the DLL.

    Deliberately does a targeted text replacement rather than a ConvertFrom-Json /
    ConvertTo-Json round-trip, for two reasons:

      1. Windows PowerShell 5.1's `Set-Content -Encoding utf8` writes a UTF-8 BOM. Thunderstore's
         manifest parser can reject a BOM'd manifest, and the failure is opaque when it happens.
         This script writes UTF-8 with no BOM explicitly.
      2. A JSON round-trip reformats the whole file (indentation, key spacing), producing noisy
         diffs on every package build.

.PARAMETER ManifestPath
    Path to the manifest.json to update.

.PARAMETER Version
    Version string to write, e.g. "1.0.6".

.EXAMPLE
    .\Set-ManifestVersion.ps1 -ManifestPath dist\thunderstore\manifest.json -Version 1.0.6
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ManifestPath,
    [Parameter(Mandatory = $true)][string]$Version
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ManifestPath)) { throw "manifest not found: $ManifestPath" }
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw "version must be MAJOR.MINOR.PATCH, got '$Version'" }

$text = [System.IO.File]::ReadAllText($ManifestPath)

# Match the existing version_number entry, preserving whatever spacing the file already uses.
$pattern = '("version_number"\s*:\s*")[^"]*(")'
if ($text -notmatch $pattern) { throw "no version_number field found in $ManifestPath" }
$updated = [regex]::Replace($text, $pattern, "`${1}$Version`${2}")

# Strip any BOM a previous tool may have left behind, then write UTF-8 with no BOM.
$updated = $updated.TrimStart([char]0xFEFF)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($ManifestPath, $updated, $utf8NoBom)

Write-Host "    manifest.json version_number set to $Version"
