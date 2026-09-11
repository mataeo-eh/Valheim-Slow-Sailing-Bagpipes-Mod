# Changelog

All notable changes to the Valheim Slow Sailing Bagpipes mod will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.6] - 2026-09-11

### Fixed
- **Valheim 1.0 compatibility.** Updated the required BepInEx pack to
  `denikson-BepInExPack_Valheim-5.4.2350`. Valheim 1.0 upgraded the game to Unity 6, and the
  previously pinned pack (`5.4.2202`) predates that - mod managers installing it would leave
  BepInEx unable to load *any* plugin.
- Vanilla music no longer bleeds over the bagpipes. Music is now suppressed by muting
  `MusicMan`'s audio source instead of zeroing its volume and pausing it; Valheim rewrites
  that volume every frame and restarts playback on track changes, which defeated both.
- The mod now re-syncs to `MusicMan` when Valheim recreates it on a scene transition. The
  previous build kept a reference to the destroyed instance's mixer group, so bagpipes could
  play on the wrong audio bus - or stay silenced - after returning from the main menu.

### Changed
- Rebuilt against the Valheim 1.0 (Unity 6, `6000.0.75f1`) game assemblies.
- Corrected the Thunderstore description, which claimed a 3-second rowing delay; the actual
  trigger threshold has been 0.1 seconds since 1.0.5.

### Verified (no change required)
- `Ship.Speed` (`Stop/Back/Slow/Half/Full`), `Ship.GetSpeedSetting()`, `Ship.m_players`,
  `Player.GetControlledShip()`, `Player.GetDoodadController()`, `Player.IsAttachedToShip()`,
  `IDoodadController.GetControlledComponent()` and `MusicMan.m_musicSource` are all unchanged
  in Valheim 1.0. `Ship.IsSailUp()` still excludes `Slow`/`Back`, so the rowing trigger
  remains correct.

## [1.0.5] - 2026-05-14

### Changed
- Reduced the rowing trigger threshold from 3 seconds to 0.1 seconds so playback starts almost immediately after eligible rowing begins.
- `Volume` and `TrackDirectory` config changes now apply live while the mod is running.

### Technical Details
- Trigger delay: 0.1 seconds
- Fade-in duration: 1.5 seconds
- Fade-out duration: 0.5 seconds
- Grace period: 10 seconds
- Rowing detection: Forward OR backward rowing at slow speed

## [1.0.0] - 2025-12-06

### Added
- Initial public release
- Custom bagpipe music playback while rowing in Valheim
- Support for MP3, OGG, and WAV audio formats
- Random track selection from BagPipesTracks folder
- Configurable volume and track directory settings
- Rolling file logger with 7-file retention
- BepInEx configuration file support

### Changed
- **BREAKING**: Rowing trigger now activates on BOTH forward (Ship.Speed.Slow) AND backward (Ship.Speed.Back) rowing
- Reduced trigger delay from 10 seconds to 3 seconds for more responsive music playback
- Changed fade-out duration from 1.5 seconds to 0.5 seconds for quicker transitions
- Updated version from 0.1.0 to 1.0.0

### Fixed
- Removed hard-coded absolute paths from documentation files (DEVELOPMENT.md, QUICKSTART.md)
- All paths now use placeholders (<project-root>) or relative paths for better portability

### Technical Details
- Fade-in duration: 1.5 seconds (unchanged)
- Fade-out duration: 0.5 seconds (reduced from 1.5s)
- Trigger delay: 3 seconds (reduced from 10s)
- Grace period: 10 seconds (unchanged)
- Rowing detection: Forward OR backward rowing at slow speed

## [0.1.0] - 2025-12-05

### Added
- Initial development version
- Basic rowing detection and audio playback
- JotunnLib autopublicize integration
- Fixed Valheim API compatibility issues

### Notes
- Internal development version, not publicly released
