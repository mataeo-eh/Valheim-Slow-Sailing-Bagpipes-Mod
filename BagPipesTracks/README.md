# BagPipesTracks Audio Folder

## Purpose

This folder contains the audio files that will play when rowing at slow speed in Valheim.

## Current Status

- **Placeholder file:** `ghost_bagpipe_track.mp3` (empty, 0 bytes)
- **Action required:** Replace with real bagpipe music MP3 files

## Adding Your Music

1. **Delete or replace** `ghost_bagpipe_track.mp3`

2. **Add your audio files** (MP3, OGG, or WAV):
   ```
   BagPipesTracks/
   ├── celtic_bagpipes.mp3
   ├── scottish_march.mp3
   └── slow_rowing_tune.ogg
   ```

3. **File requirements:**
   - **Format:** MP3 (recommended), OGG, or WAV
   - **Loopable:** Should loop seamlessly for continuous playback
   - **Length:** 30-120 seconds recommended
   - **Quality:** 192 kbps or higher for MP3

4. **No code changes needed** - the mod automatically:
   - Scans this folder on startup
   - Randomly selects one file each time rowing triggers
   - Caches loaded files for performance

## Finding Bagpipe Music

### Royalty-Free Sources

- **Freesound:** https://freesound.org/ (search "bagpipes")
- **Pixabay Music:** https://pixabay.com/music/ (search "bagpipes" or "celtic")
- **YouTube Audio Library:** https://www.youtube.com/audiolibrary
- **Incompetech:** https://incompetech.com/music/ (Kevin MacLeod's music)

### Commercial Sources

- **AudioJungle:** https://audiojungle.net/
- **Pond5:** https://www.pond5.com/
- Commission a custom track from a musician

### DIY

- Record your own bagpipe performance
- Use a digital audio workstation (DAW) with bagpipe samples

## Testing

For quick testing, any audio file will work:
- The mod doesn't require actual bagpipe music to function
- You can test with placeholder music first
- Then replace with proper bagpipe tracks later

## Folder Location After Installation

When installed in Valheim, this folder should be at:
```
C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins\BagPipesTracks\
```

The mod looks for the audio folder relative to its DLL location.

## Troubleshooting

**No music plays:**
- Ensure files are non-empty (not 0 bytes like the placeholder)
- Check file extension is .mp3, .ogg, or .wav
- Verify mod log shows "Loaded X bagpipe track(s)"

**Music sounds wrong:**
- Check file is not corrupted (play in media player first)
- Verify format is supported
- Try re-encoding as MP3

**Random selection not working:**
- Add at least 2-3 different files
- Restart game between tests
- Each trigger event should select randomly

## License Note

Ensure you have the rights to use any audio files you add:
- Personal use: Most royalty-free sites allow this
- Public distribution: Check license terms carefully
- Commercial use: May require paid licenses

---

*This folder is part of the Valheim Slow Sailing Bagpipes mod.*
*See main README.md and DEVELOPMENT.md for full documentation.*
