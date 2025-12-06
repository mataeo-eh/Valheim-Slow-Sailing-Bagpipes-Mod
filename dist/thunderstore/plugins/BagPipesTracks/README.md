# Custom Music for Slow Sailing Bagpipes

This folder contains the audio files that play when rowing in Valheim.

## Quick Start

1. **Delete or replace** the placeholder `ghost_bagpipe_track.mp3` (it's 0 bytes!)
2. **Add your own audio files** - MP3, OGG, or WAV
3. **Launch the game** - the mod will automatically detect them
4. **Row at slow speed** for 3 seconds to hear your music!

## How to Find This Folder

### Using r2modman (Recommended)

1. Launch **r2modman**
2. Select your **Valheim profile**
3. Click **"Settings"** (gear icon)
4. Click **"Browse profile folder"**
5. Navigate to: `BepInEx/plugins/BagPipesTracks/`

**Full path example**:
```
C:\Users\[YourName]\AppData\Roaming\r2modmanPlus-local\Valheim\profiles\[ProfileName]\BepInEx\plugins\BagPipesTracks\
```

### Using Thunderstore Mod Manager

1. Open **Thunderstore Mod Manager**
2. Go to your **Valheim profile**
3. Click **"Browse profile folder"** or **"Settings"**
4. Navigate to: `BepInEx/plugins/BagPipesTracks/`

### Manual Installation

If you installed the mod manually:
```
[Valheim Install]\BepInEx\plugins\BagPipesTracks\
```

**Default Valheim path**:
```
C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\BagPipesTracks\
```

## Supported Audio Formats

- **MP3** - Recommended (192 kbps or higher)
- **OGG** - Ogg Vorbis format
- **WAV** - Uncompressed audio (large files!)

## Tips for Best Music

### File Requirements

- **Loopable**: The music loops continuously while rowing
- **Length**: 30-120 seconds recommended
- **Quality**: 192 kbps or higher for MP3
- **Non-zero size**: Delete the 0-byte placeholder!

### Multiple Files

- Add 2 or more files for variety
- The mod randomly selects one each time rowing starts
- Each new rowing session may play a different track

### Finding Royalty-Free Music

**Free Sources**:
- [Freesound](https://freesound.org/) - Search "bagpipes"
- [Pixabay Music](https://pixabay.com/music/) - Search "bagpipes" or "celtic"
- [YouTube Audio Library](https://www.youtube.com/audiolibrary)
- [Incompetech](https://incompetech.com/music/) - Kevin MacLeod's music

**Included Track**:
- **Hidden Past** by Kevin MacLeod
- Source: [Uppbeat](https://uppbeat.io/t/kevin-macleod/hidden-past)
- License: ZYTOPY5OYRRTR1FG

## Changing the Music

### Step-by-Step

1. **Find this folder** (see paths above)
2. **Delete** `ghost_bagpipe_track.mp3` if present
3. **Copy** your MP3/OGG/WAV files here
4. **Example**:
   ```
   BagPipesTracks/
   ├── celtic_bagpipes_1.mp3
   ├── scottish_march.mp3
   └── slow_rowing_tune.ogg
   ```
5. **Restart Valheim** (if already running)
6. **Check the log** to confirm files were loaded:
   - Log location: `BepInEx/LogOutput.log`
   - Look for: `[Info: SlowSailingBagpipes] Loaded X bagpipe track(s)`

### Using a Custom Folder

Want to use a different folder location?

1. Edit the config file: `BepInEx/config/eh.mataeo.valheim.slowsailingbagpipes.cfg`
2. Change: `TrackDirectory = BagPipesTracks`
3. To: `TrackDirectory = C:\MyMusic\ValheimBagpipes` (use full path)
4. Save and restart the game

## Troubleshooting

### No music plays

**Check these**:
- Files exist in the folder (not empty)
- Files are **not 0 bytes** (delete placeholder!)
- File extensions are `.mp3`, `.ogg`, or `.wav`
- Game log shows: `Loaded X bagpipe track(s)` (X > 0)

**How to check**:
1. Open: `BepInEx/LogOutput.log`
2. Search for: `SlowSailingBagpipes`
3. Look for: `Loaded X bagpipe track(s) from [path]`
4. If X = 0, no files were found!

### Music sounds wrong or cuts out

**Possible issues**:
- File is corrupted (test in media player first)
- Format not supported (re-encode as MP3)
- File is too large (WAV files can be huge!)
- Track doesn't loop well (use a loopable track)

### Can't find the folder

**For r2modman users**:
1. r2modman → Settings → Browse profile folder
2. Look for: `BepInEx\plugins\BagPipesTracks\`
3. If missing, the mod may not be installed correctly

**For manual users**:
1. Check Valheim install location
2. Navigate to: `BepInEx\plugins\BagPipesTracks\`
3. If missing, reinstall the mod

## File Examples

### Good Setup

```
BagPipesTracks/
├── README.md (this file)
├── bagpipe_loop_1.mp3 (2.5 MB, 128 kbps)
├── bagpipe_loop_2.mp3 (3.1 MB, 192 kbps)
└── celtic_march.ogg (1.8 MB)
```

Result: 3 tracks loaded, random selection working!

### Bad Setup

```
BagPipesTracks/
├── README.md
└── ghost_bagpipe_track.mp3 (0 bytes)
```

Result: 0 tracks loaded (placeholder is empty), no music plays!

## Need Help?

- **GitHub Issues**: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/issues
- **Thunderstore**: Comment on the mod page
- **Logs**: Always check `BepInEx/LogOutput.log` first!

---

**Happy sailing with your custom Viking tunes!**
