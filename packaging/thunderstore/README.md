# Slow Sailing Bagpipes

Play custom bagpipe music while rowing your Viking longship!

## Description

Tired of the silence while rowing your boat in Valheim? This mod adds atmospheric bagpipe music that plays automatically when you row at slow speed (forward or backward). Perfect for those long journeys across the ocean!

**Now multiplayer compatible for helmsmen and passengers!** Music plays only for
players aboard an eligible rowing boat. This mod is **client-side**: every player
who wants to hear the bagpipes needs the mod and audio tracks installed. Players
without it can join normally and hear vanilla music. The server does not need the mod.

## Features

- **Automatic Music Playback**: Music starts after about 0.1 seconds of eligible rowing, then fades in over 1.5 seconds
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
3. **Row briefly** - after about 0.1 seconds, the music will start fading in
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
Volume = 0.85               # Bagpipe volume (0.0 to 1.0), scaled by the in-game Master and Music sliders

[Audio]
TrackDirectory = BagPipesTracks  # Audio folder (relative or absolute path)
```

## Troubleshooting

### No music plays

- Ensure you have audio files in the `BagPipesTracks` folder
- Check that files are **not** 0 bytes (delete placeholder)
- Verify you're rowing at **slow speed** (not half or full)
- Keep rowing for at least **0.1 seconds**
- Check the log: `BepInEx/LogOutput.log`

### Music doesn't stop

- This is a known Valheim API quirk - try stopping and starting rowing
- Check `BepInEx/plugins/Logs/` for the mod's detailed log

### Want different music volume?

- The bagpipes follow the in-game **Master** and **Music** volume sliders, so adjust those first
- To change the bagpipes relative to the game's music, edit the config file and change `Volume = 0.85` (0.0 to 1.0)
- `Volume` and `TrackDirectory` changes apply immediately while the mod is running

## Technical Details

- **Trigger delay**: 0.1 seconds
- **Fade-in**: 1.5 seconds
- **Fade-out**: 0.5 seconds
- **Grace period**: 10 seconds
- **Rowing detection**: Forward (Ship.Speed.Slow) OR Backward (Ship.Speed.Back)

## Compatibility

- **Valheim**: 1.0 and later (verified against 1.0, Unity 6000.0.75f1)
- **BepInEx**: 5.4.2350+
- **Multiplayer**: Install on each client that wants bagpipes; the server does not need it. Helmsmen and standing/seated passengers hear their own tracks only on their eligible rowing boat. Unmodded players keep vanilla music. Leaving the boat stops playback immediately. Track selection is independent between clients.

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

### v1.0.6 (2026-09-11) - Valheim 1.0 update
- **Updated for Valheim 1.0 (Unity 6).** Now requires BepInExPack_Valheim 5.4.2350 or later -
  older packs cannot load plugins on Unity 6 at all.
- Fixed vanilla music bleeding over the bagpipes on track changes
- Fixed the bagpipes going silent or playing on the wrong audio bus after returning from the
  main menu
- Rebuilt against the Valheim 1.0 game assemblies

### v1.0.5 (2026-05-14)
- Initial public release
- Forward AND backward rowing support
- 0.1-second trigger delay
- Live config reload for volume and track directory updates
- Configurable volume and track directory
- Random track selection
- Smooth fade transitions

---

**Enjoy your Viking sea voyages with custom bagpipe music!**
