# Changelog

All notable changes to the Valheim Slow Sailing Bagpipes mod will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
