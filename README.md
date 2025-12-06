# Valheim Slow Sailing Bagpipes

> Play custom bagpipe music while rowing your Viking longship across the seas of Valheim!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/releases)
[![BepInEx](https://img.shields.io/badge/BepInEx-5.4.2202-green.svg)](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/)

## Description

The **Slow Sailing Bagpipes** mod adds atmospheric bagpipe music that plays automatically when you row your boat at slow speed in Valheim. Whether you're traversing the ocean in a Raft, Karve, or Longship, this mod enhances your rowing experience with custom Celtic-inspired music.

Perfect for those peaceful moments when you're paddling along the coastline or crossing between islands!

## Features

- **Automatic Playback**: Music starts automatically after 3 seconds of rowing
- **Bidirectional Support**: Works with both forward and backward rowing
- **Custom Music**: Add your own MP3, OGG, or WAV files
- **Random Selection**: Multiple tracks? The mod picks one randomly each time
- **Smooth Transitions**:
  - 1.5-second fade-in when music starts
  - 0.5-second fade-out when you stop rowing
- **Grace Period**: Stop briefly and resume within 10 seconds - music continues instantly
- **Game Music Integration**: Automatically mutes Valheim's soundtrack during playback
- **Fully Configurable**: Adjust volume, music folder, and enable/disable the mod

## Installation

### Quick Install (r2modman - Recommended)

1. Download and install [r2modman](https://thunderstore.io/package/ebkr/r2modman/)
2. Select **Valheim** and create/select a profile
3. Search for **"Slow Sailing Bagpipes"**
4. Click **Download** → **Download with dependencies**
5. Launch Valheim via r2modman

### Other Installation Methods

- **Thunderstore Mod Manager**: Search and install from the mod browser
- **Vortex (Nexus Mods)**: Use the "Mod Manager Download" button
- **Manual Installation**: See [INSTALLATION.md](INSTALLATION.md) for detailed instructions

For complete installation guides for all methods, see **[INSTALLATION.md](INSTALLATION.md)**.

## How to Use

1. **Get in a boat** (Raft, Karve, or Longship)
2. **Set speed to SLOW** - Press W until you see the rowing animation
3. **Row for 3 seconds** - The music will automatically fade in
4. **Enjoy your voyage!**

When you stop rowing, the music fades out. If you start rowing again within 10 seconds, it resumes instantly without delay!

## Customizing Your Music

### Quick Guide

Want to use your own bagpipe tracks? Here's how:

1. **Find the music folder**:
   - **r2modman**: Settings → Browse profile folder → `BepInEx/plugins/BagPipesTracks/`
   - **Manual**: `[Valheim]\BepInEx\plugins\BagPipesTracks/`

2. **Delete** the placeholder file: `ghost_bagpipe_track.mp3` (it's 0 bytes)

3. **Add your audio files**:
   - Supported formats: MP3, OGG, WAV
   - Recommended: Loopable tracks, 30-120 seconds, 192 kbps or higher

4. **Restart Valheim**

### Example

```
BagPipesTracks/
├── README.md
├── celtic_bagpipes_1.mp3
├── scottish_march.mp3
└── viking_rowing_tune.ogg
```

The mod will randomly select one track each time you start rowing!

### Finding Bagpipe Music

**Free Royalty-Free Sources**:
- [Freesound](https://freesound.org/) - Search "bagpipes"
- [Pixabay Music](https://pixabay.com/music/) - Search "bagpipes" or "celtic"
- [YouTube Audio Library](https://www.youtube.com/audiolibrary)
- [Incompetech](https://incompetech.com/music/) - Kevin MacLeod's music

**Included Track**: Hidden Past by Kevin MacLeod from [Uppbeat](https://uppbeat.io/t/kevin-macleod/hidden-past)
License code: ZYTOPY5OYRRTR1FG

## Configuration

After first launch, the mod creates a config file at:
```
[Valheim]\BepInEx\config\eh.mataeo.valheim.slowsailingbagpipes.cfg
```

### Available Settings

```ini
[General]
Enabled = true              # Master toggle (true/false)
Volume = 0.85               # Music volume (0.0 to 1.0)

[Audio]
TrackDirectory = BagPipesTracks  # Audio folder path (relative or absolute)
```

Edit the file and restart Valheim for changes to take effect.

## Technical Details

| Setting | Value |
|---------|-------|
| **Trigger delay** | 3 seconds of continuous rowing |
| **Fade-in duration** | 1.5 seconds |
| **Fade-out duration** | 0.5 seconds |
| **Grace period** | 10 seconds |
| **Rowing detection** | Forward (Ship.Speed.Slow) OR Backward (Ship.Speed.Back) |
| **Audio formats** | MP3, OGG, WAV |
| **Multiplayer** | Client-side only (each player hears their own music) |

## Troubleshooting

### No music plays

**Check these**:
- Audio files exist in `BagPipesTracks/` folder
- Files are **not 0 bytes** (delete the placeholder!)
- You're rowing at **SLOW speed** (not half or full speed)
- You waited the full **3 seconds**
- Check the log: `BepInEx/LogOutput.log` should show `Loaded X bagpipe track(s)`

### Mod doesn't load

**Verify**:
- BepInEx is installed correctly
- `SailingBagpipes.dll` is in `BepInEx/plugins/`
- Check `BepInEx/LogOutput.log` for errors
- Make sure you're using BepInEx 5.4.2202 or later

### Music is too loud/quiet

Edit the config file and change `Volume = 0.85` (range: 0.0 to 1.0)

For more troubleshooting, see **[INSTALLATION.md](INSTALLATION.md#troubleshooting)**.

## Compatibility

- **Valheim Version**: Latest (tested on current build)
- **BepInEx**: 5.4.2202 or later
- **Multiplayer**: ✅ Compatible (client-side, each player independent)
- **Other Mods**: ✅ Should be compatible with most mods

## Development

### Building from Source

```bash
# Prerequisites: .NET SDK 10.0.100+, Valheim with BepInEx

# Clone the repository
git clone https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod.git
cd Valheim-Slow-Sailing-Bagpipes-Mod

# Configure Valheim path (edit if needed)
# src/Environment.props

# Build
cd src/SlowSailingBagpipes
dotnet build -c Release

# Output: bin/Release/net472/SailingBagpipes.dll
```

See **[DEVELOPMENT.md](DEVELOPMENT.md)** for complete development documentation.

### Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Documentation

- **[INSTALLATION.md](INSTALLATION.md)** - Complete installation guide for all methods
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Development, building, and testing guide
- **[RELEASING.md](RELEASING.md)** - Guide for creating releases and publishing
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## Credits

- **Mod Author**: mataeo-eh
- **Framework**: [BepInEx Team](https://github.com/BepInEx/BepInEx) - Mod loading framework
- **Library**: [Valheim Modding Team](https://github.com/Valheim-Modding/Jotunn) - JotunnLib for Valheim modding
- **Game**: [Iron Gate Studio](https://www.irongatestudio.se/) - Creators of Valheim
- **Music**: Kevin MacLeod - Hidden Past ([Uppbeat](https://uppbeat.io/t/kevin-macleod/hidden-past))

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

You are free to:
- Use the mod for personal or commercial purposes
- Modify the code
- Distribute the mod
- Include it in modpacks

Just give credit and include the license!

## Links

- **GitHub Repository**: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod
- **Issues/Bug Reports**: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/issues
- **Thunderstore**: *(Will be added after release)*
- **Nexus Mods**: *(Will be added after release)*

## Changelog

### v1.0.0 (2025-12-06)

**Initial public release!**

- Automatic bagpipe music playback while rowing
- Support for forward AND backward rowing
- 3-second trigger delay for responsive playback
- Smooth fade transitions (1.5s in, 0.5s out)
- 10-second grace period for seamless resuming
- Custom music support (MP3, OGG, WAV)
- Random track selection from multiple files
- Configurable volume and track directory
- Rolling file logger for debugging
- Complete documentation and installation guides

See **[CHANGELOG.md](CHANGELOG.md)** for complete version history.

---

## Support

Having issues or questions?

- **GitHub Issues**: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/issues
- **Thunderstore Comments**: *(After release)*
- **Nexus Mods Forum**: *(After release)*

When reporting issues, please include:
- Valheim version
- BepInEx version
- Mod version
- Log file: `BepInEx/LogOutput.log`
- Steps to reproduce the issue

---

**Enjoy your Viking sea voyages with custom bagpipe music!** ⚓🎵🏴󐁧󐁢󐁳󐁣󐁴󐁿
