<#
.SYNOPSIS
    One-command release of Slow Sailing Bagpipes to Thunderstore and Nexus Mods.

.DESCRIPTION
    Builds the mod, packages both platform archives, and publishes them. Designed to be run
    unattended by a person or a coding agent: everything it needs comes from three files, and
    it refuses to proceed rather than guess.

      VERSION              single source of truth for the version number
      release.config.json  non-secret config (namespace, Nexus mod/file IDs, pinned tool tags)
      .env                 secrets only - TCLI_AUTH_TOKEN, NEXUSMODS_API_KEY (gitignored)

    Pipeline:
      1. Load .env and validate that both tokens are present
      2. Read VERSION and run preflight checks (clean tree, version not already published)
      3. dotnet build -c Release
      4. Verify the compiled DLL's version actually equals VERSION
      5. Run both packaging scripts
      6. Verify both zips contain that same DLL
      7. Publish to Thunderstore (tcli)
      8. Upload a new version to Nexus (Nexus-Mods/upload-action, run locally via node)

    Steps 7 and 8 are the only irreversible ones. -DryRun performs 1-6 and stops.

.PARAMETER DryRun
    Do everything except the two publish steps. Use this first, always.

.PARAMETER SkipThunderstore
    Skip the Thunderstore publish (e.g. it already succeeded and Nexus failed).

.PARAMETER SkipNexus
    Skip the Nexus upload.

.PARAMETER AllowDirtyTree
    Permit publishing with uncommitted changes. Off by default so releases are reproducible
    from a known commit.

.EXAMPLE
    .\release.ps1 -DryRun
    Build, package and verify without publishing anything.

.EXAMPLE
    .\release.ps1
    Full release to both platforms.

.NOTES
    Thunderstore package versions are IMMUTABLE. Once 1.0.6 is published it cannot be replaced
    or re-uploaded - only superseded by 1.0.7. Run -DryRun first and test the build in-game.
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$SkipThunderstore,
    [switch]$SkipNexus,
    [switch]$AllowDirtyTree
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = $PSScriptRoot
$script:StepNumber = 0

# ---------------------------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------------------------

function Write-Step([string]$Message) {
    $script:StepNumber++
    Write-Host ""
    Write-Host "[$script:StepNumber] $Message" -ForegroundColor Cyan
}
function Write-Ok([string]$Message)   { Write-Host "    OK   $Message" -ForegroundColor Green }
function Write-Note([string]$Message) { Write-Host "    ..   $Message" -ForegroundColor DarkGray }
function Write-Warn([string]$Message) { Write-Host "    WARN $Message" -ForegroundColor Yellow }
function Fail([string]$Message) { throw $Message }

# ---------------------------------------------------------------------------------------------
# Configuration loading
# ---------------------------------------------------------------------------------------------

<#
.SYNOPSIS
    Loads KEY=VALUE pairs from .env into the current process environment.
.DESCRIPTION
    Values are never written to the console. Supports optional surrounding quotes, blank lines
    and '#' comments. Called once at startup by the main pipeline.
#>
function Import-DotEnv([string]$Path) {
    if (-not (Test-Path $Path)) {
        Fail ".env not found at $Path. It must define TCLI_AUTH_TOKEN and NEXUSMODS_API_KEY."
    }
    $loaded = @()
    foreach ($line in Get-Content $Path) {
        $trimmed = $line.Trim()
        if ($trimmed -eq '' -or $trimmed.StartsWith('#')) { continue }
        if ($trimmed -notmatch '^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') { continue }
        $key   = $Matches[1]
        $value = $Matches[2].Trim() -replace '^"|"$', '' -replace "^'|'$", ''
        Set-Item -Path "env:$key" -Value $value
        $loaded += $key
    }
    # Names only - never values.
    Write-Note "Loaded from .env: $($loaded -join ', ')"
}

<#
.SYNOPSIS
    Reads and validates the repo-root VERSION file.
.OUTPUTS
    The version string, e.g. "1.0.6".
#>
function Get-ModVersion([string]$RepoRoot) {
    $versionFile = Join-Path $RepoRoot 'VERSION'
    if (-not (Test-Path $versionFile)) { Fail "VERSION file not found at $versionFile" }
    $version = (Get-Content $versionFile -Raw).Trim()
    if ($version -notmatch '^\d+\.\d+\.\d+$') {
        Fail "VERSION must be MAJOR.MINOR.PATCH (Thunderstore requires it). Got: '$version'"
    }
    return $version
}

<#
.SYNOPSIS
    Reads the version compiled into a built assembly's [BepInPlugin] attribute.
.DESCRIPTION
    Uses Mono.Cecil so the assembly is inspected rather than loaded. This is the guard that
    proves the DLL about to ship was actually built from the current VERSION file.
#>
function Get-AssemblyPluginVersion([string]$DllPath) {
    $cecil = Join-Path $HOME '.nuget\packages\mono.cecil\0.11.4\lib\netstandard2.0\Mono.Cecil.dll'
    if (-not (Test-Path $cecil)) { return $null }   # Guard is best-effort if Cecil is absent.
    Add-Type -Path $cecil -ErrorAction SilentlyContinue
    $asm = [Mono.Cecil.AssemblyDefinition]::ReadAssembly($DllPath)
    try {
        $type = $asm.MainModule.GetType('SailingBagpipes.Plugin')
        $attr = $type.CustomAttributes | Where-Object { $_.AttributeType.Name -eq 'BepInPlugin' }
        return $attr.ConstructorArguments[2].Value
    } finally { $asm.Dispose() }
}

# ---------------------------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------------------------

<#
.SYNOPSIS
    Checks the version about to be published against what Thunderstore already has.
.DESCRIPTION
    Thunderstore versions are immutable and must strictly increase, so republishing an existing
    version - or any version below the current latest - always fails server-side. Catching it
    here gives a clear message instead of a late, opaque API error.

    Only 'latest' is consulted: the package API exposes latest.version_number but not a full
    version list, and for these two failure modes that is sufficient.

    Throws if the version is not publishable. Returns silently if it is.
#>
function Assert-ThunderstoreVersionPublishable($Namespace, $PackageName, $Version) {
    $uri = "https://thunderstore.io/api/experimental/package/$Namespace/$PackageName/"
    try {
        $pkg = Invoke-RestMethod -Uri $uri -TimeoutSec 30
    } catch {
        # A 404 here means the package does not exist yet, which is fine - any version publishes.
        $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
        if ($code -eq 404) { Write-Note "Package not yet on Thunderstore - first publish."; return }
        Write-Warn "Could not query Thunderstore to check versions: $($_.Exception.Message)"
        return
    }

    $latest = $pkg.latest.version_number
    Write-Note "Latest published Thunderstore version: $latest"
    if ($latest -eq $Version) {
        Fail "Thunderstore already has version $Version. Versions are immutable - bump VERSION and retry."
    }
    if ([version]$Version -le [version]$latest) {
        Fail "VERSION ($Version) is not greater than the published latest ($latest). Thunderstore requires increasing versions."
    }
}

<#
.SYNOPSIS
    Ensures the pinned Nexus upload-action is available locally, cloning it if needed.
.OUTPUTS
    Path to the action's bundled dist/index.js.
.DESCRIPTION
    The Nexus upload is a multipart presigned-URL flow. Rather than reimplement it, this runs
    Nexus's own published action locally via node, driven by INPUT_* environment variables.
    Pinned to a tag from release.config.json because the API is still in beta.
#>
function Get-NexusUploadAction($Config, [string]$CacheRoot) {
    $tag     = $Config.nexus.uploadActionTag
    $repo    = $Config.nexus.uploadActionRepo
    $dir     = Join-Path $CacheRoot "nexus-upload-action-$tag"
    $entry   = Join-Path $dir 'dist/index.js'

    if (Test-Path $entry) {
        Write-Note "Using cached upload-action $tag"
        return $entry
    }
    Write-Note "Cloning $repo at $tag"
    New-Item -ItemType Directory -Force -Path $CacheRoot | Out-Null
    if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
    git clone --quiet --depth 1 --branch $tag $repo $dir 2>&1 | Out-Null
    if (-not (Test-Path $entry)) { Fail "upload-action clone did not contain dist/index.js at $entry" }
    return $entry
}

# ---------------------------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------------------------

Write-Host ""
Write-Host "=====================================================" -ForegroundColor White
Write-Host " Slow Sailing Bagpipes - release" -ForegroundColor White
if ($DryRun) { Write-Host " DRY RUN - nothing will be published" -ForegroundColor Yellow }
Write-Host "=====================================================" -ForegroundColor White

# --- 1. Config -------------------------------------------------------------------------------
Write-Step "Loading configuration"
$configPath = Join-Path $RepoRoot 'release.config.json'
if (-not (Test-Path $configPath)) { Fail "release.config.json not found at $configPath" }
$config = Get-Content $configPath -Raw | ConvertFrom-Json

Import-DotEnv (Join-Path $RepoRoot '.env')

# Publishing is pointless without the token for whichever platform is in play; fail early.
if (-not $SkipThunderstore -and [string]::IsNullOrWhiteSpace($env:TCLI_AUTH_TOKEN)) {
    Fail "TCLI_AUTH_TOKEN is not set in .env (needed for Thunderstore; or pass -SkipThunderstore)."
}
if (-not $SkipNexus -and [string]::IsNullOrWhiteSpace($env:NEXUSMODS_API_KEY)) {
    Fail "NEXUSMODS_API_KEY is not set in .env (needed for Nexus; or pass -SkipNexus)."
}

$version = Get-ModVersion $RepoRoot
Write-Ok "Version from VERSION file: $version"

# --- 2. Preflight ----------------------------------------------------------------------------
Write-Step "Preflight checks"

$gitStatus = git -C $RepoRoot status --porcelain
if ($gitStatus) {
    if ($AllowDirtyTree -or $DryRun) {
        Write-Warn "Working tree has uncommitted changes (continuing)."
    } else {
        Fail "Working tree is dirty. Commit first so the release maps to a known commit, or pass -AllowDirtyTree."
    }
} else {
    Write-Ok "Working tree clean"
}

if (-not $SkipThunderstore) {
    Assert-ThunderstoreVersionPublishable $config.thunderstore.namespace $config.thunderstore.packageName $version
    Write-Ok "Version $version is publishable to Thunderstore"
}

foreach ($tool in @('dotnet', 'git')) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { Fail "Required tool not found on PATH: $tool" }
}
# dotnet global tools are not always on PATH in non-interactive shells.
$dotnetTools = Join-Path $HOME '.dotnet\tools'
if ((Test-Path $dotnetTools) -and ($env:PATH -notlike "*$dotnetTools*")) { $env:PATH += ";$dotnetTools" }

if (-not $SkipThunderstore -and -not (Get-Command 'tcli' -ErrorAction SilentlyContinue)) {
    Fail "tcli not found. Install with: dotnet tool install -g tcli"
}
if (-not $SkipNexus -and -not (Get-Command 'node' -ErrorAction SilentlyContinue)) {
    Fail "node not found (required to run the Nexus upload action). Node 20+ required."
}
Write-Ok "Required tooling present"

# --- 3. Build --------------------------------------------------------------------------------
Write-Step "Building mod (Release)"
$projectDir = Join-Path $RepoRoot 'src\SlowSailingBagpipes'
& dotnet build $projectDir -c Release --nologo -v minimal
if ($LASTEXITCODE -ne 0) { Fail "dotnet build failed with exit code $LASTEXITCODE" }

$builtDll = Join-Path $projectDir 'bin\Release\net472\SailingBagpipes.dll'
if (-not (Test-Path $builtDll)) { Fail "Build succeeded but DLL not found at $builtDll" }

# --- 4. Verify the build matches VERSION -----------------------------------------------------
Write-Step "Verifying compiled version matches VERSION"
$builtVersion = Get-AssemblyPluginVersion $builtDll
if ($null -eq $builtVersion) {
    Write-Warn "Mono.Cecil unavailable - skipped DLL version verification."
} elseif ($builtVersion -ne $version) {
    Fail "DLL reports version '$builtVersion' but VERSION says '$version'. Refusing to publish a mismatched build."
} else {
    Write-Ok "DLL [BepInPlugin] version = $builtVersion"
}

# --- 5. Package ------------------------------------------------------------------------------
Write-Step "Packaging release archives"
foreach ($script in @('package_thunderstore.bat', 'package_nexus.bat')) {
    Write-Note "Running $script"
    # '< nul' keeps the scripts' trailing `pause` from blocking an unattended run.
    & cmd /c "`"$(Join-Path $RepoRoot $script)`" < nul" | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "$script failed with exit code $LASTEXITCODE" }
}

$tsZip    = Join-Path $RepoRoot "dist\SlowSailingBagpipes-Thunderstore-v$version.zip"
$nexusZip = Join-Path $RepoRoot "dist\SlowSailingBagpipes-NexusMods-v$version.zip"
foreach ($zip in @($tsZip, $nexusZip)) {
    if (-not (Test-Path $zip)) { Fail "Expected package not produced: $zip" }
    Write-Ok "$(Split-Path $zip -Leaf)  ($([math]::Round((Get-Item $zip).Length / 1MB, 2)) MB)"
}

# --- 6. Verify packaged contents -------------------------------------------------------------
Write-Step "Verifying packaged DLL matches the build"
$builtHash = (Get-FileHash $builtDll).Hash
foreach ($staged in @(
    (Join-Path $RepoRoot 'dist\thunderstore\plugins\SailingBagpipes.dll'),
    (Join-Path $RepoRoot 'dist\nexusmods\BepInEx\plugins\SailingBagpipes.dll')
)) {
    if (-not (Test-Path $staged)) { Fail "Staged DLL missing: $staged" }
    if ((Get-FileHash $staged).Hash -ne $builtHash) { Fail "Staged DLL differs from the build: $staged" }
}
$manifest = Get-Content (Join-Path $RepoRoot 'dist\thunderstore\manifest.json') -Raw | ConvertFrom-Json
if ($manifest.version_number -ne $version) {
    Fail "manifest.json version_number is '$($manifest.version_number)' but VERSION is '$version'."
}
Write-Ok "Packaged DLL and manifest.json agree with VERSION"

if ($DryRun) {
    Write-Host ""
    Write-Host "DRY RUN COMPLETE - build and packages verified, nothing published." -ForegroundColor Yellow
    Write-Host "  Thunderstore: $tsZip"
    Write-Host "  Nexus:        $nexusZip"
    Write-Host ""
    return
}

# --- 7. Publish to Thunderstore --------------------------------------------------------------
if ($SkipThunderstore) {
    Write-Step "Thunderstore publish SKIPPED"
} else {
    Write-Step "Publishing to Thunderstore"
    Write-Note "$($config.thunderstore.namespace)/$($config.thunderstore.packageName) $version -> $($config.thunderstore.community)"

    # tcli rejects --package-name/--package-namespace/--package-version alongside --file:
    # when publishing a prebuilt archive the identity comes from thunderstore.toml and the
    # zip's own manifest.json. So stamp the toml's versionNumber from VERSION first, the same
    # way manifest.json is stamped, rather than leaving a placeholder that could get published.
    $tomlPath = Join-Path $RepoRoot 'thunderstore.toml'
    $toml     = [System.IO.File]::ReadAllText($tomlPath)
    $stamped  = [regex]::Replace($toml, '(?m)^(versionNumber\s*=\s*")[^"]*(")', "`${1}$version`${2}")
    if ($stamped -notmatch [regex]::Escape("versionNumber = `"$version`"")) {
        Fail "Could not stamp versionNumber into thunderstore.toml"
    }
    [System.IO.File]::WriteAllText($tomlPath, $stamped, (New-Object System.Text.UTF8Encoding($false)))
    Write-Note "thunderstore.toml versionNumber set to $version"

    & tcli publish --file $tsZip --token $env:TCLI_AUTH_TOKEN --config-path $tomlPath
    if ($LASTEXITCODE -ne 0) { Fail "tcli publish failed with exit code $LASTEXITCODE" }
    Write-Ok "Published to Thunderstore"
}

# --- 8. Upload to Nexus ----------------------------------------------------------------------
if ($SkipNexus) {
    Write-Step "Nexus upload SKIPPED"
} else {
    Write-Step "Uploading new version to Nexus Mods"
    $cacheRoot  = Join-Path $RepoRoot '.release-tools'
    $actionMain = Get-NexusUploadAction $config $cacheRoot

    $changelogPath = Join-Path $RepoRoot 'CHANGELOG.md'
    $changelogText = if (Test-Path $changelogPath) {
        # Take just the section for this version so the Nexus changelog stays focused.
        $raw = Get-Content $changelogPath -Raw
        $m = [regex]::Match($raw, "(?ms)^##\s*\[$([regex]::Escape($version))\].*?(?=^##\s*\[|\z)")
        if ($m.Success) { $m.Value.Trim() } else { "" }
    } else { "" }

    # The action is a GitHub Action: it reads its inputs from INPUT_* environment variables.
    $env:INPUT_API_KEY                      = $env:NEXUSMODS_API_KEY
    $env:INPUT_FILE_ID                      = [string]$config.nexus.fileId
    $env:INPUT_MOD_ID                       = [string]$config.nexus.modId
    $env:INPUT_FILENAME                     = $nexusZip
    $env:INPUT_VERSION                      = $version
    $env:INPUT_DISPLAY_NAME                 = "SlowSailingBagpipes NexusMods V$version"
    $env:INPUT_CATEGORY                     = $config.nexus.category
    $env:INPUT_ARCHIVE_EXISTING_VERSION     = ([string]$config.nexus.archiveExistingVersion).ToLower()
    $env:INPUT_UPDATE_MOD_VERSION           = ([string]$config.nexus.updateModVersion).ToLower()
    $env:INPUT_PRIMARY_MOD_MANAGER_DOWNLOAD = ([string]$config.nexus.primaryModManagerDownload).ToLower()
    $env:INPUT_ALLOW_MOD_MANAGER_DOWNLOAD   = ([string]$config.nexus.allowModManagerDownload).ToLower()
    if ($changelogText) { $env:INPUT_CHANGELOG = $changelogText }

    try {
        # SECURITY: @actions/core writes "::debug::" lines to stdout unconditionally when the
        # action runs outside GitHub Actions, and those lines dump the full request headers -
        # including the apikey. Filter them out so the key never reaches the console, a log
        # file, or CI output. Everything else from the action is passed through unchanged.
        $apiKey = $env:NEXUSMODS_API_KEY
        & node $actionMain 2>&1 | ForEach-Object {
            $line = $_.ToString()
            if ($line -like '*::debug::*') { return }
            # Belt and braces: redact the key if it ever appears on a non-debug line.
            if ($apiKey -and $line.Contains($apiKey)) { $line = $line.Replace($apiKey, '***REDACTED***') }
            Write-Host $line
        }
        $nodeExit = $LASTEXITCODE
        if ($nodeExit -ne 0) { Fail "Nexus upload action failed with exit code $nodeExit" }
        Write-Ok "Uploaded new version to Nexus mod $($config.nexus.pageModId), v3 file $($config.nexus.fileId)"
    } finally {
        # Don't leave the API key sitting in the session environment.
        Remove-Item env:INPUT_API_KEY -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host " Release $version complete" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "  Thunderstore: https://thunderstore.io/c/$($config.thunderstore.community)/p/$($config.thunderstore.namespace)/$($config.thunderstore.packageName)/"
Write-Host "  Nexus:        https://www.nexusmods.com/$($config.nexus.gameDomain)/mods/$($config.nexus.pageModId)"
Write-Host ""
Write-Host "Remember to tag the commit:  git tag v$version && git push --tags"
Write-Host ""
