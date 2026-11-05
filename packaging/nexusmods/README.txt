===========================================
Slow Sailing Bagpipes - Valheim Mod
===========================================

Version: 1.1.0
Author: Therunner
Date: 2026-11-05

===========================================
DESCRIPTION
===========================================

Play custom bagpipe music while rowing your Viking longship!

This mod automatically plays atmospheric bagpipe music when you row
at slow speed (forward or backward) in any boat. Perfect for those
long ocean voyages!

Now multiplayer compatible for helmsmen and passengers! Music plays only for
players aboard an eligible rowing boat. This mod is client-side: every player
who wants to hear the bagpipes needs the mod and audio tracks installed.
Players without it can join normally and hear vanilla music. The server does
not need the mod.

Features:
- Automatic music after about 0.1 seconds of eligible rowing
- Works with forward AND backward rowing
- Custom MP3/OGG/WAV support
- Random track selection
- Smooth fade transitions
- Configurable volume

===========================================
REQUIREMENTS
===========================================

REQUIRED:
- Valheim 1.0 or later (verified against the 1.0 / Unity 6 build)
- BepInEx 5.4.2350 or later

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
3. Row briefly
4. Music will start fading in after about 0.1 seconds
5. Stop rowing - music fades out
6. Resume within 10 seconds - music resumes without waiting through the trigger threshold again!

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
Volume = 0.85            # Bagpipe volume (0.0 to 1.0), scaled by in-game Master and Music sliders

[Audio]
TrackDirectory = BagPipesTracks  # Music folder location

===========================================
TROUBLESHOOTING
===========================================

No music plays:
- Check BagPipesTracks folder has MP3/OGG/WAV files (not 0 bytes!)
- Ensure you're rowing at SLOW speed (not half/full)
- Keep rowing for at least 0.1 seconds
- Check log: BepInEx\LogOutput.log

Mod doesn't load:
- Install BepInEx first!
- Check BepInEx\LogOutput.log for errors
- Verify SailingBagpipes.dll is in BepInEx\plugins\

Music volume too loud/quiet:
- The bagpipes follow the in-game Master and Music volume sliders - adjust those first
- To change the bagpipes relative to the game's music, edit config file: change "Volume = 0.85"
- Range: 0.0 (silent) to 1.0 (as loud as the in-game sliders allow)

===========================================
COMPATIBILITY
===========================================

Multiplayer: Optional on each client; the server does not need the mod.
Helmsmen and standing/seated passengers hear their own tracks on their rowing boat.
Unmodded players keep vanilla music. Leaving the boat stops playback immediately.
Track selection is independent between clients. Host-only installation does not
send custom audio to guests.
Each player hears their own music independently.

Other mods: Should be compatible with most mods.
If you experience issues, report them on Nexus Mods or GitHub.

===========================================
TECHNICAL DETAILS
===========================================

Trigger delay: 0.1 seconds
Fade-in: 1.5 seconds
Fade-out: 0.5 seconds
Grace period: 10 seconds
Detection: Forward OR backward rowing at slow speed

===========================================
CHANGELOG
===========================================

v1.0.6 (2026-09-11) - VALHEIM 1.0 UPDATE
- Current release
- Updated for Valheim 1.0 (Unity 6)
- REQUIRES BepInExPack_Valheim 5.4.2350 or later. Older BepInEx packs cannot
  load any plugin on Unity 6 - update BepInEx before reporting problems.
- Fixed vanilla music bleeding over the bagpipes on track changes
- Fixed bagpipes going silent or playing on the wrong audio bus after
  returning from the main menu
- Rebuilt against the Valheim 1.0 game assemblies

v1.0.5 (2026-05-14)
- Forward and backward rowing support
- 0.1-second trigger delay
- Live config reload for volume and track directory updates
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
