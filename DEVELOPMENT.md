# Valheim Slow Sailing Bagpipes - Development Pipeline

## Overview

This document provides a complete development and testing pipeline for the Valheim Slow Sailing Bagpipes mod. The mod plays custom bagpipe music when the player is rowing forward OR backward at slow speed.

**Status:** Version 1.0.0 - Ready for public release

**Last Updated:** 2025-12-06

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Prerequisites](#prerequisites)
3. [Dependencies](#dependencies)
4. [Build Process](#build-process)
5. [Audio File Management](#audio-file-management)
6. [Installation](#installation)
7. [Testing](#testing)
8. [Troubleshooting](#troubleshooting)
9. [Development Workflow](#development-workflow)
10. [Technical Details](#technical-details)

---

## Project Structure

```
Valheim-Slow-Sailing-Bagpipes-Mod/
├── BagPipesTracks/                    # Audio files folder (MP3/OGG/WAV)
│   └── ghost_bagpipe_track.mp3       # Placeholder (replace with real audio)
├── src/
│   ├── Environment.props.example      # Template for Valheim path config
│   ├── Environment.props              # Your local config (gitignored, create from .example)
│   ├── DoPrebuild.props.example       # Template for build settings
│   ├── DoPrebuild.props               # Your local settings (gitignored, create from .example)
│   └── SlowSailingBagpipes/           # Main plugin source
│       ├── Plugin.cs                  # Main mod logic
│       ├── Logging/
│       │   └── PluginLogger.cs        # Custom rolling file logger
│       ├── SlowSailingBagpipes.csproj # Project file
│       ├── Environment.props.example  # Template (copy to Environment.props)
│       ├── DoPrebuild.props.example   # Template (copy to DoPrebuild.props)
│       └── bin/Release/net472/        # Build output (gitignored)
│           └── SailingBagpipes.dll    # The compiled mod
├── NuGet.config                       # NuGet package sources
├── build_and_install.bat              # Automated build and install script
├── README.md                          # User-facing documentation
└── DEVELOPMENT.md                     # This file
```

**IMPORTANT:** The `Environment.props` and `DoPrebuild.props` files are gitignored to prevent
committing user-specific paths. You must create these from the `.example` templates on first setup.

---

## Prerequisites

### Required Software

1. **Valheim** (installed via Steam)
   - Default path: `C:\Program Files (x86)\Steam\steamapps\common\Valheim`

2. **.NET SDK**
   - Version: 10.0.100 or later
   - Download: https://dotnet.microsoft.com/download
   - Location: `C:\Program Files\dotnet\`

3. **BepInEx** (for running mods in Valheim)
   - Install BepInExPack for Valheim from Thunderstore
   - Instructions: https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/

### Recommended Software

- **Visual Studio 2022** or **VS Code** with C# extension
- **dnSpy** for inspecting publicized assemblies (optional)

---

## Dependencies

The mod uses the following NuGet packages (configured in `SlowSailingBagpipes.csproj`):

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **BepInEx.Core** | 5.* | Mod framework for Unity games |
| **JotunnLib** | 2.* | Valheim modding library with autopublicize |

### NuGet Sources

Configured in `NuGet.config`:
- **nuget.org**: Standard NuGet packages
- **BepInEx**: https://nuget.bepinex.dev/v3/index.json

### Valheim Assembly References

JotunnLib automatically publicizes and references these Valheim assemblies:
- `assembly_valheim_publicized.dll` - Core game classes (Player, Ship, MusicMan, etc.)
- `assembly_utils_publicized.dll`
- `gui_framework_publicized.dll`
- Plus various Unity engine modules

These are created automatically from your Valheim installation when you build.

---

## Build Process

### Initial Setup (One-Time)

1. **Create Local Configuration Files**

   Copy the example templates to create your local configuration:

   ```bash
   # From the project root
   copy src\Environment.props.example src\Environment.props
   copy src\DoPrebuild.props.example src\DoPrebuild.props
   copy src\SlowSailingBagpipes\Environment.props.example src\SlowSailingBagpipes\Environment.props
   copy src\SlowSailingBagpipes\DoPrebuild.props.example src\SlowSailingBagpipes\DoPrebuild.props
   ```

2. **Configure Valheim Installation Path**

   Edit `src/Environment.props` and `src/SlowSailingBagpipes/Environment.props` to match your Valheim installation:

   ```xml
   <PropertyGroup>
     <VALHEIM_INSTALL>C:\Program Files (x86)\Steam\steamapps\common\Valheim</VALHEIM_INSTALL>
   </PropertyGroup>
   ```

   **Note:** If Valheim is installed in a custom location, update the path accordingly.

3. **Verify .NET SDK**

   ```bash
   dotnet --version
   # Should output: 10.0.100 or higher
   ```

   If not found, download from: https://dotnet.microsoft.com/download/dotnet/10.0

### Building the Mod

#### Option 1: Automated Build Script (Easiest)

Use the provided build script from the project root:

```bash
# Build and install to Valheim (default)
build_and_install.bat

# Build only (don't install)
build_and_install.bat /build-only

# Show help and options
build_and_install.bat /help

# Use custom Valheim path
set VALHEIM_PATH=D:\Games\Valheim
build_and_install.bat
```

#### Option 2: Command Line (Manual)

```bash
# Navigate to project directory
cd src\SlowSailingBagpipes

# Clean previous builds
dotnet clean

# Build in Release configuration
dotnet build -c Release
```

#### Option 2: Visual Studio

1. Open `src\SlowSailingBagpipes\SlowSailingBagpipes.csproj` in Visual Studio
2. Select **Release** configuration
3. Build > Build Solution (Ctrl+Shift+B)

### Build Output

Successful build creates:
- **DLL**: `src\SlowSailingBagpipes\bin\Release\net472\SailingBagpipes.dll` (≈20 KB)
- **PDB**: Debug symbols file
- **Dependencies**: All required DLLs copied to output directory

### First Build Process

On first build, JotunnLib will:
1. Detect Valheim installation from `Environment.props`
2. Locate game assemblies in `Valheim\Valheim_Data\Managed\`
3. Create publicized versions in `Managed\publicized_assemblies\`
4. This takes 3-5 seconds extra on first build
5. Subsequent builds are faster (publicized DLLs are cached)

**Console output:**
```
Executing Jotunn Prebuild Task
Publicizing C:\Program Files (x86)\Steam\steamapps\common\Valheim\Valheim_Data\Managed\assembly_valheim.dll
...
Build succeeded.
```

---

## Audio File Management

### Audio Folder Location

The mod looks for audio files in:
```
Valheim-Slow-Sailing-Bagpipes-Mod/BagPipesTracks/
```

This folder is relative to the mod DLL location when installed in Valheim.

### Supported Audio Formats

- **MP3** (recommended)
- **OGG** (Ogg Vorbis)
- **WAV** (uncompressed, large files)

### Adding Audio Files

1. **Obtain or create bagpipe music files**
   - Must be loopable for seamless playback
   - Recommended length: 30-120 seconds
   - Format: MP3, 192kbps or higher

2. **Add files to the folder**
   ```bash
   # Example:
   Valheim-Slow-Sailing-Bagpipes-Mod/BagPipesTracks/
   ├── celtic_bagpipes_1.mp3
   ├── scottish_march.mp3
   └── slow_rowing_tune.ogg
   ```

3. **No code changes required**
   - The mod scans the folder on startup
   - Randomly selects one file each time the sailing condition triggers

### Testing with Sample Audio

For development/testing, you can use any royalty-free audio:
- Download from: https://freesound.org/
- Or use: https://pixabay.com/music/
- Search for "bagpipe" or use any placeholder music

**Quick test:**
```bash
# Download a sample file and place it in BagPipesTracks/
# Any MP3 will work for testing the mod functionality
```

### Empty Folder Handling

If no audio files are found:
- The mod will **not crash**
- It logs a warning: `No bagpipe tracks found in [path]`
- The trigger logic still runs, but no audio plays
- Add files and reload the mod (or restart game)

---

## Installation

### Installing the Mod in Valheim

1. **Ensure BepInEx is installed**
   - Launch Valheim once with BepInEx to create the plugin folder
   - Quit the game

2. **Copy the mod DLL**
   ```bash
   # From:
   src\SlowSailingBagpipes\bin\Release\net472\SailingBagpipes.dll

   # To:
   C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\SailingBagpipes.dll
   ```

3. **Copy the audio folder**
   ```bash
   # From:
   BagPipesTracks/

   # To:
   C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\BagPipesTracks/
   ```

   **Final structure:**
   ```
   Valheim/BepInEx/plugins/
   ├── SailingBagpipes.dll
   └── BagPipesTracks/
       ├── your_music_1.mp3
       └── your_music_2.mp3
   ```

4. **Launch Valheim**
   - The BepInEx console will show mod loading
   - Look for: `[Info: SlowSailingBagpipes] Loaded X bagpipe track(s)`

### Configuration

After first launch, BepInEx creates a config file:
```
Valheim/BepInEx/config/eh.mataeo.valheim.slowsailingbagpipes.cfg
```

**Available settings:**

```ini
[General]
## Master toggle for the mod
# Setting type: Boolean
# Default value: true
Enabled = true

## Playback volume (0.0 - 1.0)
# Setting type: Single
# Default value: 0.85
Volume = 0.85

[Audio]
## Directory containing bagpipe audio clips
## Can be absolute path or relative to plugin DLL
# Setting type: String
# Default value: BagPipesTracks
TrackDirectory = BagPipesTracks
```

**To use a different audio folder:**
```ini
TrackDirectory = C:\MyValheimMusic\Bagpipes
```

---

## Testing

### Pre-Flight Checklist

Before testing in-game:

- [ ] Mod DLL built successfully (`SailingBagpipes.dll` exists)
- [ ] BepInEx installed in Valheim
- [ ] Mod DLL copied to `BepInEx/plugins/`
- [ ] Audio folder exists with at least one MP3/OGG/WAV file
- [ ] Audio files are non-zero size and playable

### In-Game Testing Procedure

#### 1. Launch and Verify Mod Loading

1. **Start Valheim**
2. **Check BepInEx console** (if enabled) or log file:
   ```
   BepInEx/LogOutput.log
   ```
3. **Look for these messages:**
   ```
   [Info: BepInEx] Loading [SlowSailingBagpipes 0.1.0]
   [Info: SlowSailingBagpipes] Loaded X bagpipe track(s) from [path]
   ```

#### 2. Enter a World

1. Load any world or create a new one
2. Craft or spawn a boat:
   - Raft (easiest to test)
   - Karve
   - Longship

#### 3. Test Rowing Trigger (Forward)

1. **Get in the boat**
2. **Set speed to SLOW** (rowing speed)
   - Press W (forward) until at slowest speed setting
   - You should see the rowing animation
3. **Row for 3 seconds**
   - Timer requirement: 3 seconds of continuous rowing
4. **Expected behavior:**
   - After 3 seconds: Bagpipe music fades in (1.5 second fade)
   - Game music (MusicMan) volume is reduced to 0
   - Bagpipe music loops seamlessly

#### 4. Test Backward Rowing Trigger

1. **While in boat, press S to row backward**
2. **Row backward for 3 seconds**
3. **Expected behavior:**
   - After 3 seconds: Bagpipe music fades in (same as forward)
   - Music plays while rowing backward
   - Stop rowing backward - music fades out

#### 5. Test Stopping Trigger

1. **While music is playing, stop rowing**
   - Release W/S, or change speed
2. **Expected behavior:**
   - Music fades out (0.5 seconds - quick fade)
   - Game music resumes at normal volume
   - Grace period of 10 seconds granted

#### 6. Test Grace Period

1. **Resume rowing within 10 seconds** of stopping
2. **Expected behavior:**
   - Bagpipe music resumes **immediately** (no 3-second delay)
   - This allows for brief pauses without restarting the timer

#### 7. Test Random Selection (Multiple Files)

1. **Add 2+ different audio files** to the folder
2. **Restart the game** (or reload the mod)
3. **Trigger the music multiple times**
   - Exit to menu and rejoin world
   - Or wait for full stop and re-trigger
4. **Expected behavior:**
   - Each time music starts, a random file is selected
   - Different tracks should play across multiple sessions

### Testing Checklist

- [ ] Mod loads without errors
- [ ] Audio files are detected (check log)
- [ ] **Forward** rowing at slow speed for 3 seconds triggers music
- [ ] **Backward** rowing at slow speed for 3 seconds triggers music
- [ ] Music fades in smoothly (1.5 seconds)
- [ ] Game music is muted during bagpipe playback
- [ ] Stopping rowing fades out bagpipe music (0.5 seconds - quick)
- [ ] Game music resumes after bagpipe stops
- [ ] Grace period works (resume within 10 sec = instant restart)
- [ ] Random selection works with multiple files
- [ ] Config file changes take effect (test Volume setting)

### Debug Logging

The mod creates detailed log files in:
```
Valheim/BepInEx/plugins/Logs/SlowSailingBagpipes-YYYY-MM-DD-HH-mm.log
```

**Log retention:** 7 most recent files

**What's logged:**
- Mod initialization
- Audio file discovery
- Track directory changes
- Rowing state changes
- Paddle timer progress
- Audio playback start/stop
- Fade in/out progress
- MusicMan mute/unmute
- Config changes

**Log levels:**
- **DEBUG**: Every Update() tick and state change (very verbose)
- **INFO**: Significant events (music start/stop, file loading)
- **WARN**: Non-critical issues (empty folder, missing MusicMan)
- **ERROR**: Critical failures (file load errors)

**To reduce log spam:**
- The DEBUG level logs are extensive but useful for troubleshooting
- Consider commenting out LogDebug calls in Update() if not needed

---

## Troubleshooting

### Build Issues

#### Error: "Unable to find package BepInEx.Core"

**Cause:** NuGet source not configured

**Fix:**
1. Verify `NuGet.config` exists in project root
2. Contains: `<add key="BepInEx" value="https://nuget.bepinex.dev/v3/index.json" />`
3. Run: `dotnet restore`

#### Error: "Could not locate the assembly 'assembly_valheim_publicized'"

**Cause:** JotunnLib prebuild task not running

**Fix:**
1. Check `src/Environment.props` exists and has correct Valheim path
2. Check `src/DoPrebuild.props` has `<ExecutePrebuild>true</ExecutePrebuild>`
3. Check both .props files are also copied to `src/SlowSailingBagpipes/`
4. The .csproj must have: `<Import Project="Environment.props" />` and `<Import Project="DoPrebuild.props" />`
5. Clean and rebuild: `dotnet clean && dotnet build`

#### Error: "'Player' does not contain a definition for 'm_shipControl'"

**Cause:** Valheim API changed (this was fixed in current code)

**Fix:**
- The current code uses `Player.GetControlledShip()` which is the correct API
- If you see this error, ensure you have the latest `Plugin.cs`

### Runtime Issues

#### Mod doesn't load in Valheim

**Checks:**
1. BepInEx is installed and working (other mods load?)
2. `SailingBagpipes.dll` is in `BepInEx/plugins/`
3. Check `BepInEx/LogOutput.log` for errors
4. Ensure .NET Framework 4.7.2 is installed on Windows

#### No audio plays when rowing

**Checks:**
1. Audio folder exists in correct location
2. At least one .mp3/.ogg/.wav file present
3. Audio file is not empty (0 bytes)
4. Check mod log file for: "No bagpipe tracks found"
5. Ensure you're rowing at **SLOW speed** (forward or backward)
6. Wait full **3 seconds** of continuous rowing

#### Music plays but game crashes

**Checks:**
1. Audio file is valid and playable (test in media player)
2. File format is supported (MP3/OGG/WAV)
3. File is not corrupted
4. Check Valheim log for Unity audio errors

#### Music doesn't stop when I stop rowing

**Checks:**
1. This is likely a code bug - check the fade-out logic
2. Verify `HandleNonPaddlingState()` is being called
3. Check debug logs for "Exiting Paddle" message

#### Game music doesn't resume after bagpipes stop

**Cause:** MusicMan might not be restored properly

**Fix:**
- This may be a Valheim API change
- Check `ToggleMusicManMute()` implementation
- Verify `source.volume` is being restored
- The current code uses `source.Stop()` and volume control

---

## Development Workflow

### Making Code Changes

1. **Edit source files** in `src/SlowSailingBagpipes/`
2. **Build the mod:**
   ```bash
   cd "src/SlowSailingBagpipes"
   "C:\Program Files\dotnet\dotnet.exe" build -c Release
   ```
3. **Copy DLL to Valheim:**
   ```bash
   copy "bin\Release\net472\SailingBagpipes.dll" "C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\"
   ```
4. **Restart Valheim** to load new code

### Hot Reload (Not Supported)

Valheim requires a full restart to reload mod DLLs. BepInEx does not support hot-reload for code changes.

### Testing Iteration Loop

For rapid testing:

1. Make code changes
2. Build: `dotnet build -c Release`
3. Use a batch script to copy DLL:
   ```batch
   @echo off
   copy /Y "bin\Release\net472\SailingBagpipes.dll" "C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\"
   echo Mod updated! Restart Valheim.
   ```
4. Restart Valheim
5. Load a world with a nearby boat for quick testing
6. Test the specific feature you changed

### Version Control

Current version: **0.1.0** (defined in `Plugin.cs`)

To update version:
1. Edit `Plugin.cs`, line 22: `private const string PluginVersion = "0.1.0";`
2. Rebuild
3. Update changelog/README if needed

---

## Technical Details

### How the Mod Works

#### Trigger Logic

The mod runs `Update()` every frame and checks:

1. **Is there a local player?**
   - `Player.m_localPlayer` must be non-null

2. **Is the player controlling a ship?**
   - `player.GetControlledShip()` returns the Ship instance or null

3. **Is the ship at slow speed OR rowing backward?**
   - `ship.GetSpeedSetting() == Ship.Speed.Slow` (forward rowing)
   - OR `ship.GetSpeedSetting() == Ship.Speed.Back` (backward rowing)
   - Both trigger the music!

4. **Has the player been rowing for 3 seconds?**
   - `_paddleTimer` increments while rowing
   - Threshold: `PaddleThresholdSeconds = 3f`

5. **Start music:**
   - Select random track from `_trackPaths` list
   - Check if already cached in `_clipCache` dictionary
   - If not cached, start coroutine to load via `UnityWebRequestMultimedia`
   - Fade in volume from 0 to configured volume (1.5 seconds)
   - Mute `MusicMan` (game's music system)

#### Stop Logic

When player stops rowing or exceeds slow speed:

1. **Grant grace period:**
   - `_resumeUntil = Time.time + 10f`
   - If rowing resumes within 10 seconds, music continues

2. **Fade out music:**
   - Fade volume from current to 0 (0.5 seconds - quick fade)
   - Stop audio playback
   - Restore `MusicMan` volume

#### Audio Loading

- Uses Unity's `UnityWebRequestMultimedia.GetAudioClip()`
- Loads asynchronously via coroutine (doesn't freeze game)
- Caches loaded clips in `_clipCache` dictionary
- Supports file:// URIs for local files

#### Random Selection

- `System.Random _rng` with `_rng.Next(0, _trackPaths.Count)`
- New selection each time `StartBagpipes()` is called
- Not per-loop, but per trigger event

### Configuration System

Uses BepInEx's `Config.Bind<T>()`:

```csharp
_enabled = Config.Bind("General", "Enabled", true, "Description");
_volume = Config.Bind("General", "Volume", 0.85f, new ConfigDescription(...));
_trackDirectoryConfig = Config.Bind("Audio", "TrackDirectory", "BagPipesTracks", "Description");
```

Config changes detected via event:
```csharp
Config.SettingChanged += (_, args) => { ... }
```

### Performance Considerations

- **Update() runs every frame:** Keep logic lightweight
- **Debug logging is verbose:** Consider disabling DEBUG level for release
- **Audio caching:** Prevents reloading same file multiple times
- **Coroutine for loading:** Doesn't block main thread

### Known Limitations

1. **Multiplayer synchronization:** Music is client-side only
   - Other players don't hear your bagpipes
   - Each player's music is independent

2. **No in-game UI:** Configuration is file-based only
   - No BepInEx ConfigurationManager integration (yet)

3. **Rowing detection:** Based on ship speed setting (Slow OR Back)
   - May need tuning if Valheim changes ship mechanics
   - Currently works with both forward and backward rowing

4. **MusicMan API:** Current implementation uses basic volume control
   - May need updates if Valheim changes music system

---

## API Changes and Fixes

### Valheim API Compatibility (v0.1.0)

The mod was updated to work with current Valheim version. Key changes:

| Old API (Broken) | New API (Working) | Notes |
|------------------|-------------------|-------|
| `player.m_shipControl == ShipControlls.ShipControlType.Paddle` | `player.GetControlledShip() != null && (ship.GetSpeedSetting() == Ship.Speed.Slow \|\| ship.GetSpeedSetting() == Ship.Speed.Back)` | Ship control detection - forward OR backward |
| `musicMan.ManualStopMusic()` | `source.Stop()` | Music stopping |
| `musicMan.ManualStartMusic()` | Volume restoration only | Music resuming |

**If Valheim updates break the mod:**

1. Check Valheim patch notes for API changes
2. Use dnSpy to inspect `assembly_valheim_publicized.dll`
3. Search for `Player`, `Ship`, `MusicMan` classes
4. Update method calls in `Plugin.cs`
5. Rebuild and test

---

## Additional Resources

### Documentation

- **BepInEx Docs:** https://docs.bepinex.dev/
- **JotunnLib Docs:** https://valheim-modding.github.io/Jotunn/
- **Valheim Modding Discord:** https://discord.gg/valheim-modding

### Tools

- **dnSpy:** https://github.com/dnSpy/dnSpy (inspect assemblies)
- **BepInEx ConfigurationManager:** https://github.com/BepInEx/BepInEx.ConfigurationManager
- **Thunderstore:** https://thunderstore.io/c/valheim/ (publish your mod)

### Related Mods

- **MusicMod (joeyparrish):** https://github.com/joeyparrish/valheim-musicmod
- **ValheimRAFT (ship mechanics):** https://github.com/zolantris/ValheimMods

---

## Publishing the Mod

When ready to release:

1. **Test thoroughly** (see Testing section)
2. **Create a Thunderstore package:**
   - `manifest.json`
   - `README.md`
   - `icon.png` (256x256)
   - Zip with DLL and audio folder
3. **Upload to Thunderstore:** https://thunderstore.io/
4. **Create GitHub release** with version tag

---

## Support and Contributing

### Reporting Issues

- GitHub Issues: (add your repo URL)
- Include:
  - Valheim version
  - BepInEx version
  - Mod version
  - Log files (`BepInEx/LogOutput.log` and mod's log)

### Contributing

- Fork the repository
- Create a feature branch
- Make changes
- Test thoroughly
- Submit pull request

---

## License

(Add your chosen license here, e.g., MIT, GPL, etc.)

---

## Credits

- **BepInEx Team:** For the modding framework
- **Valheim Modding Team:** For Jotunn library
- **Iron Gate Studio:** For creating Valheim

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

### v1.0.0 (2025-12-06)
- **Public release**
- Forward AND backward rowing support (Ship.Speed.Slow OR Ship.Speed.Back)
- 3-second trigger delay (reduced from 10s)
- Separate fade durations: 1.5s fade-in, 0.5s fade-out
- 10-second grace period
- Custom music support (MP3/OGG/WAV)
- Random track selection
- Configurable volume and track directory
- Complete documentation for release

### v0.1.0 (2025-12-05)
- Initial development version
- Basic rowing detection (forward only)
- Audio playback with 10-second delay
- Rolling file logger
- JotunnLib autopublicize integration
- Fixed Valheim API compatibility issues
