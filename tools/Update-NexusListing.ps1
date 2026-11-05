[CmdletBinding(SupportsShouldProcess)]
param([switch]$VerifyOnly)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$config = Get-Content -LiteralPath (Join-Path $repo 'release.config.json') -Raw | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($env:NEXUSMODS_API_KEY)) {
    throw 'NEXUSMODS_API_KEY must be supplied in the process environment by the publishing workflow.'
}
$summary = (Get-Content -LiteralPath (Join-Path $repo $config.nexus.summaryFile) -Raw).Trim()
$description = (Get-Content -LiteralPath (Join-Path $repo $config.nexus.descriptionFile) -Raw).Trim()
if (!$summary -or $summary.Length -gt 350 -or !$description) { throw 'Invalid Nexus listing text.' }
$headers = @{ apikey = $env:NEXUSMODS_API_KEY; ApplicationName = 'SlowSailingBagpipesRelease'; ApplicationVersion = (Get-Content (Join-Path $repo 'VERSION') -Raw).Trim() }
$modUri = "https://api.nexusmods.com/v3/mods/$($config.nexus.modId)"
try {
    $before = Invoke-RestMethod -Uri "https://api.nexusmods.com/v3/games/$($config.nexus.gameDomain)/mods/$($config.nexus.pageModId)" -Headers $headers
    if ([string]$before.data.id -ne [string]$config.nexus.modId) { throw 'Nexus mod identity mismatch.' }
    if (!$VerifyOnly) {
        if (!$PSCmdlet.ShouldProcess("Nexus Mods $($config.nexus.pageModId)", 'Update summary and full description from committed listing files')) { return }
        $body = @{ summary = $summary; description = $description } | ConvertTo-Json
        $response = Invoke-WebRequest -Uri $modUri -Method Patch -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body))
        if ($response.StatusCode -ne 204) { throw 'Nexus did not acknowledge the listing update.' }
        Write-Output 'Nexus summary and description update accepted (HTTP 204).'
    }
    $after = Invoke-RestMethod -Uri $modUri -Headers $headers
    # Nexus inserts an HTML <br /> after each stored editor newline.
    $actual = ([string]$after.data.description).Replace("`r`n", "`n").Replace("`n<br />", "`n").Trim()
    $expected = $description.Replace("`r`n", "`n").Trim()
    if ($actual -ne $expected) { throw 'Nexus description read-back does not match the committed text.' }
    Write-Output 'Verified live Nexus description matches the committed BBCode.'
    $legacy = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/$($config.nexus.gameDomain)/mods/$($config.nexus.pageModId).json" -Headers $headers
    if ([string]$legacy.summary -ne $summary) { throw 'Nexus summary read-back does not match the committed text.' }
    Write-Output 'Verified live Nexus summary matches the committed text.'
} catch {
    # Do not dump request objects or headers that contain the API key.
    if ($_.Exception.Response) { throw ('Nexus listing operation failed: HTTP ' + [int]$_.Exception.Response.StatusCode) }
    throw $_.Exception.Message
}
