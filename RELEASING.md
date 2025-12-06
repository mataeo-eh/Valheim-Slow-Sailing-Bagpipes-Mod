# Releasing Guide - Slow Sailing Bagpipes

This guide documents the complete process for releasing the Slow Sailing Bagpipes mod to Thunderstore and Nexus Mods.

## Table of Contents

1. [Pre-Release Checklist](#pre-release-checklist)
2. [Building Release Packages](#building-release-packages)
3. [Thunderstore Release](#thunderstore-release)
4. [Nexus Mods Release](#nexus-mods-release)
5. [GitHub Release](#github-release)
6. [Post-Release Tasks](#post-release-tasks)
7. [Version Updates](#version-updates)

---

## Pre-Release Checklist

Before creating packages, verify everything is ready:

### Code & Build

- [ ] All code changes committed to Git
- [ ] Version updated in `Plugin.cs` (PluginVersion constant)
- [ ] CHANGELOG.md updated with new version
- [ ] Mod builds successfully: `dotnet build -c Release`
- [ ] No compiler warnings or errors
- [ ] DLL file exists: `src/SlowSailingBagpipes/bin/Release/net472/SailingBagpipes.dll`

### Documentation

- [ ] README.md reviewed and updated
- [ ] INSTALLATION.md is current
- [ ] DEVELOPMENT.md is accurate
- [ ] CHANGELOG.md has entry for this release
- [ ] No hard-coded absolute paths in documentation
- [ ] All links are valid (GitHub, Thunderstore, Nexus)

### Assets

- [ ] icon.png created (256x256 PNG for Thunderstore)
- [ ] Audio files present in BagPipesTracks/ (or placeholder documented)
- [ ] BagPipesTracks/README.md explains how to add custom music

### Testing

- [ ] Mod loads in Valheim without errors
- [ ] Rowing triggers music after 3 seconds
- [ ] Forward AND backward rowing both work
- [ ] Music fades in (1.5s) and fades out (0.5s)
- [ ] Grace period works (10 seconds)
- [ ] Config file is created and editable
- [ ] Custom audio files load correctly
- [ ] No console errors or warnings

---

## Building Release Packages

### Step 1: Update Version Number

Edit `src/SlowSailingBagpipes/Plugin.cs`:

```csharp
private const string PluginVersion = "1.0.0"; // Update this
```

### Step 2: Update Manifest (Thunderstore)

Edit `dist/thunderstore/manifest.json`:

```json
{
  "name": "SlowSailingBagpipes",
  "version_number": "1.0.0",  // Update this (must match PluginVersion)
  "website_url": "https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod",
  "description": "Play custom bagpipe music while rowing your Viking longship!",
  "dependencies": [
    "denikson-BepInExPack_Valheim-5.4.2202"
  ]
}
```

**IMPORTANT**: Version format must be `major.minor.patch` (e.g., 1.0.0, 1.2.3)

### Step 3: Update CHANGELOG.md

Add a new entry at the top:

```markdown
## [1.0.0] - 2025-12-06

### Added
- New feature description

### Changed
- What changed

### Fixed
- What was fixed
```

### Step 4: Build the Mod

```bash
cd src\SlowSailingBagpipes
"C:\Program Files\dotnet\dotnet.exe" clean
"C:\Program Files\dotnet\dotnet.exe" build -c Release
```

Verify output:
```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

### Step 5: Create Thunderstore Package

Run the packaging script:

```bash
cd <project-root>
package_thunderstore.bat
```

The script will:
1. Copy DLL to `dist/thunderstore/plugins/`
2. Copy audio files to `dist/thunderstore/plugins/BagPipesTracks/`
3. Copy CHANGELOG.md
4. Verify required files exist

**Manual ZIP creation**:
1. Navigate to `dist/thunderstore/`
2. Select ALL contents:
   - `manifest.json`
   - `README.md`
   - `icon.png`
   - `CHANGELOG.md`
   - `plugins/` folder
3. Right-click → Send to → Compressed (zipped) folder
4. Name: `SlowSailingBagpipes-v1.0.0.zip`

**IMPORTANT**: ZIP the **contents** of `thunderstore/`, NOT the folder itself!

### Step 6: Create Nexus Mods Package

Run the packaging script:

```bash
cd <project-root>
package_nexus.bat
```

The script will:
1. Copy DLL to `dist/nexusmods/BepInEx/plugins/`
2. Copy audio files to `dist/nexusmods/BepInEx/plugins/BagPipesTracks/`
3. Verify README.txt exists

**Manual ZIP creation**:
1. Navigate to `dist/nexusmods/`
2. Select ALL contents:
   - `BepInEx/` folder
   - `README.txt`
   - `CHANGELOG.txt`
3. Right-click → Send to → Compressed (zipped) folder
4. Name: `SlowSailingBagpipes-v1.0.0.zip`

---

## Thunderstore Release

### Step 1: Create Thunderstore Account

1. Go to: https://thunderstore.io/
2. Sign in with Discord or GitHub
3. Verify email address

### Step 2: Prepare Package

Verify your ZIP contains:
- `manifest.json` (required)
- `README.md` (required)
- `icon.png` (required, 256x256 PNG)
- `CHANGELOG.md` (optional but recommended)
- `plugins/` folder with DLL and audio files

**Test the ZIP**:
1. Extract to a temp folder
2. Verify structure matches requirements
3. Check manifest.json is valid JSON

### Step 3: Upload to Thunderstore

1. Go to: https://thunderstore.io/c/valheim/create/
2. Fill in the form:
   - **Name**: SlowSailingBagpipes (must match manifest.json)
   - **Package file**: Upload your ZIP
   - **Categories**: Mods, Audio, Client-side
   - **NSFW**: No
   - **Communities**: Valheim

3. Click **"Submit"**
4. Wait for package to be processed (usually instant)

### Step 4: Verify Thunderstore Page

1. Navigate to your mod page
2. Check:
   - [ ] Icon displays correctly
   - [ ] README renders properly
   - [ ] Version number is correct
   - [ ] Dependencies listed (BepInEx)
   - [ ] Download button works

### Step 5: Test Installation

1. Open r2modman
2. Search for your mod: "Slow Sailing Bagpipes"
3. Install it
4. Verify files are placed correctly
5. Launch Valheim and test

---

## Nexus Mods Release

### Step 1: Create Nexus Mods Account

1. Go to: https://www.nexusmods.com/
2. Register for an account
3. Verify email

### Step 2: Prepare Package

Verify your ZIP contains:
- `BepInEx/plugins/SailingBagpipes.dll`
- `BepInEx/plugins/BagPipesTracks/` with README and audio
- `README.txt` (user-facing instructions)
- `CHANGELOG.txt` (optional)

**Test Vortex compatibility**:
1. Structure must have `BepInEx/` at the root of the ZIP
2. Vortex will extract and merge with existing BepInEx folder

### Step 3: Upload to Nexus Mods

1. Go to: https://www.nexusmods.com/valheim/mods/add
2. Fill in the details:

**Basic Info**:
- **Name**: Slow Sailing Bagpipes
- **Summary**: Play custom bagpipe music while rowing your Viking longship!
- **Category**: Gameplay or Audio
- **Version**: 1.0.0
- **Author**: mataeo-eh

**Description**:
- Paste formatted version of README.txt
- Add screenshots/videos if available
- Include feature list, installation instructions, credits

**Files**:
- **Main File**: Upload your ZIP
- **Version**: 1.0.0
- **Category**: MAIN
- **Description**: "Initial release of Slow Sailing Bagpipes"

**Requirements**:
- List **BepInEx** as a requirement
- Link to BepInEx on Nexus Mods

**Permissions**:
- Set your preferred permissions
- Recommend: Allow others to modify with credit

3. Click **"Upload"**

### Step 4: Verify Nexus Mods Page

1. Navigate to your mod page
2. Check:
   - [ ] Description displays correctly
   - [ ] Files section shows the ZIP
   - [ ] Requirements list BepInEx
   - [ ] Installation instructions are clear
   - [ ] Screenshots/media (if added)

### Step 5: Test with Vortex

1. Open Vortex
2. Search for your mod in Nexus Mods
3. Click "Mod Manager Download"
4. Install through Vortex
5. Deploy mods
6. Launch Valheim and test

---

## GitHub Release

### Step 1: Tag the Release

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### Step 2: Create GitHub Release

1. Go to: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/releases
2. Click **"Draft a new release"**
3. Fill in:
   - **Tag**: v1.0.0 (select existing tag)
   - **Title**: Slow Sailing Bagpipes v1.0.0
   - **Description**: Copy from CHANGELOG.md

4. Upload files:
   - `SlowSailingBagpipes-v1.0.0.zip` (Thunderstore package)
   - `SlowSailingBagpipes-NexusMods-v1.0.0.zip` (Nexus package)
   - `SailingBagpipes.dll` (standalone DLL)

5. Click **"Publish release"**

---

## Post-Release Tasks

### Update Links

After publishing to Thunderstore and Nexus Mods, update documentation:

1. **README.md** - Add links:
   ```markdown
   ## Links
   - **Thunderstore**: https://thunderstore.io/c/valheim/p/[author]/SlowSailingBagpipes/
   - **Nexus Mods**: https://www.nexusmods.com/valheim/mods/[mod-id]
   - **GitHub**: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod
   ```

2. **manifest.json** - Update website_url if needed

3. **Thunderstore README** - Update links section

4. **Nexus Mods description** - Add Thunderstore link

### Announce Release

Consider posting about the release:

- **r/valheim** subreddit (check rules first)
- **Valheim Modding Discord**
- **Your social media**
- **Steam Community Hub** (Valheim discussions)

### Monitor Feedback

Keep an eye on:
- Thunderstore comments
- Nexus Mods comments/posts
- GitHub issues
- Discord messages

Respond to bug reports and feature requests promptly.

---

## Version Updates

### Semantic Versioning

Follow semver: `MAJOR.MINOR.PATCH`

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, incompatible API changes
- **MINOR** (1.0.0 → 1.1.0): New features, backward-compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, backward-compatible

### Examples

**Bug fix release** (1.0.0 → 1.0.1):
- Fixed music not stopping
- Fixed config not loading
- No new features

**Feature release** (1.0.0 → 1.1.0):
- Added support for FLAC files
- Added volume fade customization
- Backward compatible with 1.0.0

**Major release** (1.0.0 → 2.0.0):
- Changed config file format (breaking)
- Changed track directory structure (breaking)
- Requires users to reconfigure

### Update Process

1. **Code**: Update `PluginVersion` in Plugin.cs
2. **Manifest**: Update `version_number` in manifest.json
3. **Changelog**: Add new version entry
4. **Build**: Clean and rebuild
5. **Package**: Run packaging scripts
6. **Upload**: New versions to Thunderstore and Nexus Mods
7. **GitHub**: Create new release tag and upload

**Thunderstore**: Uploading a new version with the same name but different version_number will create an update.

**Nexus Mods**: Upload as a new file version in the Files tab.

---

## Troubleshooting Release Issues

### Thunderstore rejects package

**Common issues**:
- manifest.json is invalid JSON
- version_number format wrong (must be X.Y.Z)
- icon.png missing or wrong size
- README.md missing
- ZIP structure incorrect (zipped folder instead of contents)

**Fix**: Validate manifest.json, check ZIP structure, verify icon.png

### Nexus Mods upload fails

**Common issues**:
- File too large (max 5GB)
- Network timeout
- Invalid file structure

**Fix**: Check file size, retry upload, verify structure

### Mod doesn't appear in r2modman

**Wait time**: Thunderstore may take a few minutes to index new mods

**Fix**: Wait 5-10 minutes, refresh r2modman, search by exact name

### Downloads but doesn't install correctly

**Issue**: ZIP structure wrong

**Fix**:
- Thunderstore: Contents should be at root (manifest.json, plugins/, etc.)
- Nexus: BepInEx/ folder should be at root

---

## Release Checklist Template

Use this for each release:

```
Pre-Release:
[ ] Version updated in Plugin.cs
[ ] Version updated in manifest.json
[ ] CHANGELOG.md updated
[ ] Code builds without errors
[ ] All tests pass
[ ] Documentation reviewed
[ ] icon.png ready (Thunderstore)

Packaging:
[ ] Built Release configuration
[ ] Ran package_thunderstore.bat
[ ] Created Thunderstore ZIP
[ ] Ran package_nexus.bat
[ ] Created Nexus Mods ZIP
[ ] Verified ZIP contents

Thunderstore:
[ ] Uploaded package
[ ] Verified mod page
[ ] Tested installation with r2modman
[ ] Tested in-game

Nexus Mods:
[ ] Uploaded package
[ ] Set requirements (BepInEx)
[ ] Verified mod page
[ ] Tested installation with Vortex
[ ] Tested in-game

GitHub:
[ ] Created version tag
[ ] Created GitHub Release
[ ] Uploaded packages
[ ] Release notes added

Post-Release:
[ ] Updated links in documentation
[ ] Announced release (optional)
[ ] Monitoring comments/issues
```

---

## Support

If you encounter issues with the release process:

- **Thunderstore Support**: https://thunderstore.io/
- **Nexus Mods Help**: https://help.nexusmods.com/
- **GitHub Docs**: https://docs.github.com/en/repositories/releasing-projects-on-github

---

**Good luck with your release!**
