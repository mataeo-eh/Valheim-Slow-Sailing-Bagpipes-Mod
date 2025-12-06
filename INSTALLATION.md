# Installation Guide - Slow Sailing Bagpipes

This guide covers all installation methods for the Slow Sailing Bagpipes Valheim mod.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Method 1: r2modman (Recommended)](#method-1-r2modman-recommended)
3. [Method 2: Thunderstore Mod Manager](#method-2-thunderstore-mod-manager)
4. [Method 3: Vortex (Nexus Mods)](#method-3-vortex-nexus-mods)
5. [Method 4: Manual Installation](#method-4-manual-installation)
6. [Verifying Installation](#verifying-installation)
7. [Adding Custom Music](#adding-custom-music)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required

- **Valheim** (latest version from Steam)
- **BepInEx** 5.4.2202 or later

BepInEx will be installed automatically by mod managers, or you can install it manually:
- **Thunderstore**: https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/
- **Nexus Mods**: https://www.nexusmods.com/valheim/mods/

### Recommended

- **Mod Manager** (r2modman, Thunderstore, or Vortex)
- Using a mod manager makes installation and updates much easier!

---

## Method 1: r2modman (Recommended)

r2modman is the most popular and easiest mod manager for Valheim.

### Step 1: Install r2modman

1. Download r2modman: https://thunderstore.io/package/ebkr/r2modman/
2. Install and launch r2modman
3. Select **Valheim** from the game list
4. Choose a profile or create a new one

### Step 2: Install the Mod

1. Click **"Online"** tab in r2modman
2. Search for **"Slow Sailing Bagpipes"** or **"SlowSailingBagpipes"**
3. Click **"Download"**
4. Click **"Download with dependencies"** (installs BepInEx automatically)
5. Wait for installation to complete

### Step 3: Launch Valheim

1. Click **"Start modded"** in r2modman
2. Valheim will launch with mods enabled
3. Check the BepInEx console for mod loading confirmation

### Step 4: Add Custom Music (Optional)

1. In r2modman, click **"Settings"** (gear icon)
2. Click **"Browse profile folder"**
3. Navigate to: `BepInEx/plugins/BagPipesTracks/`
4. Delete `ghost_bagpipe_track.mp3` (0-byte placeholder)
5. Add your own MP3/OGG/WAV files
6. Restart Valheim

**Full path example**:
```
C:\Users\[YourName]\AppData\Roaming\r2modmanPlus-local\Valheim\profiles\[ProfileName]\BepInEx\plugins\BagPipesTracks\
```

---

## Method 2: Thunderstore Mod Manager

Similar to r2modman but with a different interface.

### Step 1: Install Thunderstore Mod Manager

1. Download from: https://www.overwolf.com/app/Thunderstore-Thunderstore_Mod_Manager
2. Install and launch
3. Select **Valheim**

### Step 2: Install the Mod

1. Go to **"Get Mods"** or **"Browse"**
2. Search for **"Slow Sailing Bagpipes"**
3. Click **"Install"**
4. Dependencies (BepInEx) install automatically

### Step 3: Launch and Configure

1. Click **"Play"** to start Valheim with mods
2. To add custom music:
   - Click **"Settings"** or **"Browse profile folder"**
   - Navigate to: `BepInEx/plugins/BagPipesTracks/`
   - Add your music files

---

## Method 3: Vortex (Nexus Mods)

Vortex is Nexus Mods' official mod manager.

### Step 1: Install Vortex

1. Download Vortex: https://www.nexusmods.com/about/vortex/
2. Install and launch Vortex
3. Add **Valheim** to Vortex (if not auto-detected)

### Step 2: Install BepInEx

1. Search for **BepInEx** on Nexus Mods Valheim section
2. Click **"Mod Manager Download"**
3. Install through Vortex
4. Enable and deploy

### Step 3: Install Slow Sailing Bagpipes

1. Go to Nexus Mods Slow Sailing Bagpipes page
2. Click **"Mod Manager Download"**
3. Install through Vortex
4. Enable the mod
5. Click **"Deploy Mods"**

### Step 4: Add Custom Music

1. Navigate to your Valheim installation:
   ```
   C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\BagPipesTracks\
   ```
2. Delete the placeholder file
3. Add your MP3/OGG/WAV files
4. Launch Valheim

---

## Method 4: Manual Installation

For users who prefer not to use a mod manager.

### Step 1: Install BepInEx

1. Download BepInEx: https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/
2. Extract the ZIP file
3. Copy **all contents** to your Valheim installation folder:
   ```
   C:\Program Files (x86)\Steam\steamapps\common\Valheim\
   ```
4. Your Valheim folder should now have:
   - `BepInEx/` folder
   - `doorstop_config.ini`
   - `winhttp.dll`
   - Original Valheim files

5. Launch Valheim **once** to initialize BepInEx
6. Close Valheim after reaching the main menu

### Step 2: Install Slow Sailing Bagpipes

1. Download the mod ZIP:
   - From **Thunderstore**: https://thunderstore.io/
   - From **Nexus Mods**: https://www.nexusmods.com/valheim/mods/
   - From **GitHub Releases**: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/releases

2. Extract the ZIP file

3. Copy the mod files to Valheim:
   ```
   # Copy from the extracted ZIP:
   BepInEx/plugins/SailingBagpipes.dll
   BepInEx/plugins/BagPipesTracks/

   # To your Valheim installation:
   C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\
   ```

4. Final structure:
   ```
   Valheim\
   ├── BepInEx\
   │   └── plugins\
   │       ├── SailingBagpipes.dll
   │       └── BagPipesTracks\
   │           ├── README.md
   │           └── [music files]
   └── valheim.exe
   ```

### Step 3: Add Custom Music

1. Navigate to:
   ```
   C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\BagPipesTracks\
   ```
2. Delete `ghost_bagpipe_track.mp3` (0 bytes)
3. Add your MP3/OGG/WAV files
4. Launch Valheim

---

## Verifying Installation

### Check BepInEx Console

When you launch Valheim with BepInEx, a console window appears showing mod loading.

**Look for these messages**:
```
[Info   : BepInEx] Loading [SlowSailingBagpipes 1.0.0]
[Info   : SlowSailingBagpipes] Loaded X bagpipe track(s) from [path]
```

If you see these, the mod is installed correctly!

### Check Log File

If the console closes too quickly:

1. Navigate to:
   ```
   [Valheim]\BepInEx\LogOutput.log
   ```
2. Open in a text editor
3. Search for "SlowSailingBagpipes"
4. Verify it loaded without errors

### Test In-Game

1. Load any world
2. Craft or spawn a boat (Raft is easiest)
3. Get in the boat
4. Set speed to **SLOW** (press W until rowing animation)
5. Row for **3 seconds**
6. Music should fade in!

---

## Adding Custom Music

Regardless of installation method, you need to find the `BagPipesTracks` folder.

### Finding the Folder

**r2modman / Thunderstore**:
```
Settings → Browse profile folder → BepInEx/plugins/BagPipesTracks/
```

**Vortex / Manual**:
```
[Valheim Install]\BepInEx\plugins\BagPipesTracks\
```

### Adding Files

1. **Delete** the placeholder: `ghost_bagpipe_track.mp3` (0 bytes)
2. **Add** your audio files (MP3, OGG, or WAV)
3. **Recommended**: Loopable tracks, 30-120 seconds, 192 kbps
4. **Multiple files**: The mod randomly selects one each time
5. **Restart** Valheim to detect new files

### Example

```
BagPipesTracks/
├── README.md
├── celtic_bagpipes_1.mp3
├── scottish_march.mp3
└── viking_rowing_tune.ogg
```

Result: 3 tracks loaded, random selection working!

---

## Troubleshooting

### Mod doesn't load

**Check**:
- BepInEx is installed correctly
- `SailingBagpipes.dll` is in `BepInEx/plugins/`
- BepInEx console shows no errors
- Log file: `BepInEx/LogOutput.log`

**Common fixes**:
- Reinstall BepInEx
- Verify Valheim file integrity (Steam)
- Check for conflicting mods

### No music plays

**Check**:
- Audio files exist in `BagPipesTracks/`
- Files are **not 0 bytes**
- File extensions: `.mp3`, `.ogg`, or `.wav`
- Log shows: `Loaded X bagpipe track(s)` (X > 0)
- You're rowing at **SLOW speed** (not half/full)
- Waited full **3 seconds** of continuous rowing

**Common fixes**:
- Delete placeholder file
- Add real audio files
- Restart Valheim
- Check mod config (see below)

### Configuration Issues

**Config file location**:
```
[Valheim]\BepInEx\config\eh.mataeo.valheim.slowsailingbagpipes.cfg
```

**Check settings**:
```ini
[General]
Enabled = true      # Make sure it's true!
Volume = 0.85       # 0.0 to 1.0

[Audio]
TrackDirectory = BagPipesTracks  # Check path is correct
```

**Fix**:
- Open config file
- Verify `Enabled = true`
- Check `TrackDirectory` path
- Save and restart

### BepInEx console closes immediately

**Enable console**:
1. Edit: `[Valheim]\BepInEx\config\BepInEx.cfg`
2. Find: `[Logging.Console]`
3. Change: `Enabled = false` to `Enabled = true`
4. Save and restart

### Mod works but music is too loud/quiet

**Adjust volume**:
1. Edit config: `eh.mataeo.valheim.slowsailingbagpipes.cfg`
2. Change: `Volume = 0.85` (0.0 to 1.0)
3. Save and restart

---

## Uninstalling

### r2modman / Thunderstore

1. Go to **"Installed"** tab
2. Find **Slow Sailing Bagpipes**
3. Click **"Disable"** or **"Uninstall"**

### Vortex

1. Go to **"Mods"** tab
2. Find **Slow Sailing Bagpipes**
3. Click **"Disable"** or **"Remove"**
4. Deploy mods

### Manual

Delete these files:
```
[Valheim]\BepInEx\plugins\SailingBagpipes.dll
[Valheim]\BepInEx\plugins\BagPipesTracks\
[Valheim]\BepInEx\config\eh.mataeo.valheim.slowsailingbagpipes.cfg
```

---

## Need Help?

- **GitHub Issues**: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/issues
- **Thunderstore**: Comment on the mod page
- **Nexus Mods**: Post in the mod's forum
- **Discord**: Valheim Modding Discord server

**When reporting issues, include**:
- Installation method
- Valheim version
- BepInEx version
- Log file: `BepInEx/LogOutput.log`
- Screenshots of errors

---

**Enjoy your Viking sea voyages with custom bagpipe music!**
