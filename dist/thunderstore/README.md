# Slow Sailing Bagpipes

Play custom bagpipe music while rowing your Viking longship!

## Description

Tired of the silence while rowing your boat in Valheim? This mod adds atmospheric bagpipe music that plays automatically when you row at slow speed (forward or backward). Perfect for those long journeys across the ocean!

## Features

- **Automatic Music Playback**: Music starts after 3 seconds of rowing at slow speed
- **Forward & Backward Rowing**: Works with both rowing directions
- **Custom Music Support**: Add your own MP3, OGG, or WAV files
- **Random Selection**: Multiple tracks? The mod randomly picks one each time
- **Smooth Transitions**: 1.5-second fade-in, 0.5-second fade-out
- **Grace Period**: Stop rowing briefly? Music resumes instantly within 10 seconds
- **Game Music Muting**: Automatically mutes Valheim's soundtrack during playback
- **Configurable**: Adjust volume and track folder location

## How to Use

1. **Get in a boat** (Raft, Karve, or Longship)
2. **Set speed to slow** (press W until you see the rowing animation)
3. **Row for 3 seconds** - the music will fade in!
4. **Stop rowing** - music fades out, but resumes instantly if you start again within 10 seconds

## Customizing Your Music

### Using r2modman (Recommended)

1. Launch r2modman and select your Valheim profile
2. Click "Settings" → "Browse profile folder"
3. Navigate to: `BepInEx/plugins/BagPipesTracks/`
4. Add your MP3/OGG/WAV files to this folder
5. Delete or replace the placeholder `ghost_bagpipe_track.mp3`
6. Launch the game!

### Supported Audio Formats

- **MP3** (recommended) - 192 kbps or higher
- **OGG** (Ogg Vorbis)
- **WAV** (uncompressed)

### Tips for Best Results

- Use **loopable tracks** for seamless playback
- Recommended length: **30-120 seconds**
- Multiple files will be randomly selected each time
- Files should be non-zero size (delete the 0-byte placeholder!)

## Finding Bagpipe Music

Looking for royalty-free bagpipe music?

- **Freesound**: https://freesound.org/ (search "bagpipes")
- **Pixabay Music**: https://pixabay.com/music/ (search "bagpipes" or "celtic")
- **YouTube Audio Library**: https://www.youtube.com/audiolibrary
- **Incompetech**: https://incompetech.com/music/ (Kevin MacLeod)

**Note**: The included track is from [Uppbeat](https://uppbeat.io/t/kevin-macleod/hidden-past) - License code: ZYTOPY5OYRRTR1FG

## Configuration

After first launch, edit the config file at:
```
BepInEx/config/eh.mataeo.valheim.slowsailingbagpipes.cfg
```

### Available Settings

```ini
[General]
Enabled = true              # Master toggle (true/false)
Volume = 0.85               # Music volume (0.0 to 1.0)

[Audio]
TrackDirectory = BagPipesTracks  # Audio folder (relative or absolute path)
```

## Troubleshooting

### No music plays

- Ensure you have audio files in the `BagPipesTracks` folder
- Check that files are **not** 0 bytes (delete placeholder)
- Verify you're rowing at **slow speed** (not half or full)
- Wait the full **3 seconds** of continuous rowing
- Check the log: `BepInEx/LogOutput.log`

### Music doesn't stop

- This is a known Valheim API quirk - try stopping and starting rowing
- Check `BepInEx/plugins/Logs/` for the mod's detailed log

### Want different music volume?

- Edit the config file and change `Volume = 0.85` (0.0 to 1.0)
- Save and restart the game

## Technical Details

- **Trigger delay**: 3 seconds
- **Fade-in**: 1.5 seconds
- **Fade-out**: 0.5 seconds
- **Grace period**: 10 seconds
- **Rowing detection**: Forward (Ship.Speed.Slow) OR Backward (Ship.Speed.Back)

## Compatibility

- **Valheim**: Latest version (tested on current build)
- **BepInEx**: 5.4.2202+
- **Multiplayer**: Client-side only (each player hears their own music)

## Source Code & Issues

- **GitHub**: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod
- **Report bugs**: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/issues

## Credits

- **BepInEx Team**: Mod framework
- **Valheim Modding Team**: Jotunn library
- **Iron Gate Studio**: Creating Valheim
- **Music**: Hidden Past by Kevin MacLeod (from Uppbeat)

## License

MIT License - See GitHub repository for details

## Changelog

### v1.0.0 (2025-12-06)
- Initial public release
- Forward AND backward rowing support
- 3-second trigger delay
- Configurable volume and track directory
- Random track selection
- Smooth fade transitions

---

**Enjoy your Viking sea voyages with custom bagpipe music!**
