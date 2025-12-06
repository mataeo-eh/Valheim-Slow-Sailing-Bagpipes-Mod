# Quick Start Guide - Valheim Slow Sailing Bagpipes

This is a quick reference for building and testing the mod. See **DEVELOPMENT.md** for complete documentation.

---

## Build the Mod (Quick Steps)

```bash
# Navigate to project
cd "c:\Users\matae\OneDrive\Desktop\Coding-Projects\Valheim-Slow-Sailing-Bagpipes-Mod\src\SlowSailingBagpipes"

# Build
"C:\Program Files\dotnet\dotnet.exe" build -c Release
```

**Output:** `bin\Release\net472\SailingBagpipes.dll`

---

## Install in Valheim

### 1. Copy the DLL

```bash
# From:
src\SlowSailingBagpipes\bin\Release\net472\SailingBagpipes.dll

# To:
C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\SailingBagpipes.dll
```

### 2. Copy Audio Folder

```bash
# From:
BagPipesTracks\

# To:
C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\BagPipesTracks\
```

### 3. Add Your Music

Replace `BagPipesTracks\ghost_bagpipe_track.mp3` with real MP3 files:
- Supported: MP3, OGG, WAV
- Recommended: Loopable tracks, 30-120 seconds
- Multiple files = random selection

---

## Test in Game

1. **Launch Valheim**
2. **Load a world**
3. **Get in a boat**
4. **Set speed to SLOW** (rowing speed - press W once or twice)
5. **Row for 10 seconds**
6. **Music should fade in!**

**To stop:**
- Stop rowing → music fades out
- Resume within 10 seconds → music resumes instantly

---

## Check Logs

**Mod log:**
```
Valheim\BepInEx\plugins\Logs\SlowSailingBagpipes-YYYY-MM-DD-HH-mm.log
```

**BepInEx log:**
```
Valheim\BepInEx\LogOutput.log
```

**Look for:**
- `[Info: SlowSailingBagpipes] Loaded X bagpipe track(s)`
- Any error messages

---

## Configuration

**Config file** (created after first launch):
```
Valheim\BepInEx\config\eh.mataeo.valheim.slowsailingbagpipes.cfg
```

**Settings:**
- `Enabled = true` - Master toggle
- `Volume = 0.85` - Music volume (0.0-1.0)
- `TrackDirectory = BagPipesTracks` - Audio folder path

---

## Troubleshooting

### No music plays
- Check audio files exist and are non-empty
- Ensure you're at SLOW speed (rowing)
- Wait full 10 seconds
- Check log for "No bagpipe tracks found"

### Mod doesn't load
- Verify BepInEx is installed
- Check `BepInEx\LogOutput.log` for errors
- Ensure DLL is in `plugins\` folder

### Build fails
- Ensure `Environment.props` has correct Valheim path
- Run: `dotnet restore`
- Check `DEVELOPMENT.md` Troubleshooting section

---

## Quick Build Script (Windows)

Create `build_and_install.bat` in project root:

```batch
@echo off
cd src\SlowSailingBagpipes
"C:\Program Files\dotnet\dotnet.exe" build -c Release
if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

copy /Y "bin\Release\net472\SailingBagpipes.dll" "C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\"
echo.
echo Build successful! DLL copied to Valheim.
echo Restart Valheim to load the updated mod.
pause
```

---

## Full Documentation

See **DEVELOPMENT.md** for:
- Complete project structure
- Dependency details
- Advanced troubleshooting
- API documentation
- Publishing guide
