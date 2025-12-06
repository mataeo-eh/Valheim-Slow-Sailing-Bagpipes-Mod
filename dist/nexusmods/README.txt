===========================================
Slow Sailing Bagpipes - Valheim Mod
===========================================

Version: 1.0.0
Author: mataeo-eh
Date: 2025-12-06

===========================================
DESCRIPTION
===========================================

Play custom bagpipe music while rowing your Viking longship!

This mod automatically plays atmospheric bagpipe music when you row
at slow speed (forward or backward) in any boat. Perfect for those
long ocean voyages!

Features:
- Automatic music after 3 seconds of rowing
- Works with forward AND backward rowing
- Custom MP3/OGG/WAV support
- Random track selection
- Smooth fade transitions
- Configurable volume

===========================================
REQUIREMENTS
===========================================

REQUIRED:
- Valheim (latest version)
- BepInEx 5.4.2202 or later

BepInEx Download:
https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/

You MUST install BepInEx first or this mod will not work!

===========================================
INSTALLATION (Vortex Mod Manager)
===========================================

1. Install BepInEx for Valheim using Vortex
2. Click "Mod Manager Download" on Nexus Mods page
3. Install through Vortex
4. Enable the mod
5. Deploy mods
6. Launch Valheim!

The mod will be installed to:
[Valheim]\BepInEx\plugins\

===========================================
INSTALLATION (Manual)
===========================================

1. Install BepInEx for Valheim first
2. Extract this archive
3. Copy the "BepInEx" folder to your Valheim installation directory
4. Merge with existing BepInEx folder when prompted
5. Launch Valheim!

Your Valheim folder should look like:
Valheim\
├── BepInEx\
│   └── plugins\
│       ├── SailingBagpipes.dll
│       └── BagPipesTracks\
│           ├── README.md
│           └── [music files]
└── valheim.exe

Default Valheim location:
C:\Program Files (x86)\Steam\steamapps\common\Valheim\

===========================================
HOW TO USE
===========================================

1. Get in a boat (Raft, Karve, or Longship)
2. Set speed to SLOW (press W until rowing animation)
3. Row for 3 seconds
4. Music will fade in!
5. Stop rowing - music fades out
6. Resume within 10 seconds - music continues instantly!

===========================================
CUSTOMIZING MUSIC
===========================================

Add Your Own Music Files:

1. Navigate to:
   [Valheim]\BepInEx\plugins\BagPipesTracks\

2. Delete or replace: ghost_bagpipe_track.mp3

3. Add your MP3/OGG/WAV files

4. Restart Valheim

Supported formats: MP3, OGG, WAV
Recommended: Loopable tracks, 30-120 seconds, 192 kbps

Finding Music:
- Freesound.org (search "bagpipes")
- Pixabay Music (royalty-free)
- YouTube Audio Library
- Incompetech.com (Kevin MacLeod)

Included track: "Hidden Past" by Kevin MacLeod from Uppbeat
License: ZYTOPY5OYRRTR1FG

===========================================
CONFIGURATION
===========================================

After first launch, edit:
[Valheim]\BepInEx\config\eh.mataeo.valheim.slowsailingbagpipes.cfg

Settings:
[General]
Enabled = true           # Master on/off switch
Volume = 0.85            # Music volume (0.0 to 1.0)

[Audio]
TrackDirectory = BagPipesTracks  # Music folder location

===========================================
TROUBLESHOOTING
===========================================

No music plays:
- Check BagPipesTracks folder has MP3/OGG/WAV files (not 0 bytes!)
- Ensure you're rowing at SLOW speed (not half/full)
- Wait full 3 seconds of continuous rowing
- Check log: BepInEx\LogOutput.log

Mod doesn't load:
- Install BepInEx first!
- Check BepInEx\LogOutput.log for errors
- Verify SailingBagpipes.dll is in BepInEx\plugins\

Music volume too loud/quiet:
- Edit config file: change "Volume = 0.85"
- Range: 0.0 (silent) to 1.0 (full)

===========================================
COMPATIBILITY
===========================================

Multiplayer: Client-side only
Each player hears their own music independently.

Other mods: Should be compatible with most mods.
If you experience issues, report them on Nexus Mods or GitHub.

===========================================
TECHNICAL DETAILS
===========================================

Trigger delay: 3 seconds
Fade-in: 1.5 seconds
Fade-out: 0.5 seconds
Grace period: 10 seconds
Detection: Forward OR backward rowing at slow speed

===========================================
CHANGELOG
===========================================

v1.0.0 (2025-12-06)
- Initial release
- Forward and backward rowing support
- 3-second trigger delay
- Custom music support (MP3/OGG/WAV)
- Random track selection
- Configurable volume and directory

===========================================
CREDITS
===========================================

Mod by: mataeo-eh
BepInEx: BepInEx Team
Jotunn: Valheim Modding Team
Game: Iron Gate Studio (Valheim)
Music: Kevin MacLeod (Uppbeat)

===========================================
LINKS
===========================================

GitHub: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod
Issues: https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/issues
Nexus Mods: [Your Nexus Mods page]
Thunderstore: [Your Thunderstore page]

===========================================
LICENSE
===========================================

MIT License
See GitHub repository for full license text.

===========================================

Enjoy your Viking sea voyages with bagpipes!

===========================================
