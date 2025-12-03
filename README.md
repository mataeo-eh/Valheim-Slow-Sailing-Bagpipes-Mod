# Valheim Slow Sailing Bagpipes Mod

A BepInEx/Jötunn Valheim mod that celebrates relaxed boat travel by fading in looping bagpipes whenever the player manually paddles at the slowest speed tick. The music replaces the in-game soundtrack (but leaves SFX intact) while paddling continues and gracefully fades back out once throttling up or stopping.

## Current Scope

- **Trigger condition**: Detect when the local player has `m_shipControl == ShipControlls.ShipControlType.Paddle` for roughly 10 seconds. Forward/reverse paddling counts, and leaving Paddle instantly stops the music and starts a 10-second grace period for instant resume.
- **Audio behavior**: Every time playback starts the mod randomly chooses a clip from `BagPipesTracks/`. The files can be MP3/OGG/WAV, loop with 1–3 second fade transitions, and temporarily mute `MusicMan` so only the custom track is audible.
- **Configuration**: BepInEx config entries for enable/disable, playback volume (0.0–1.0), and a configurable `TrackDirectory` that points to whichever folder of bagpipe loops you want to rotate through.
- **Non-goals** (for now): Multiplayer playback parity and end-user installation/testing. Multiplayer notes will live in `README.md` until implemented.

## Framework & Project Layout

| Component | Reason |
| --- | --- |
| **BepInEx 5** | De facto Valheim mod loader that injects managed plugins (`BaseUnityPlugin`). |
| **Jötunn** | Provides strongly-typed accessors/parsers for Valheim game classes (e.g., `Player`, `ShipControlls`, `MusicMan`) without manually bundling publicized assemblies. |
| **Unity Coroutines** | Used to poll ship control state, handle 10-second timers, and load audio clips from disk asynchronously.
| **Custom rolling logger** | Persists debug-level traces to `Logs/` with 7-file retention for easier agent troubleshooting.

```
Sailing_BagPipes/
├── BagPipesTracks/ghost_bagpipe_track.mp3   # placeholder asset; replace with your real loop
├── ENV/                                     # secrets (ignored)
├── scripts/codex_alert.sh                   # macOS completion notifier
├── src/SlowSailingBagpipes                  # BepInEx plugin source (csproj inside)
├── README.md                                # this file
└── TODO.md
```

> **Ghost track placeholder**: The repository ships an empty `ghost_bagpipe_track.mp3` so the mod can look up the default asset path without errors. Replace it with the eventual loop (OGG/WAV/MP3) or drop multiple clips in the folder—the plugin will pick one at random whenever it starts playing.

## Custom Audio Files

1. Drop MP3/OGG/WAV loops into `BagPipesTracks/` (default) or any other folder you prefer.
2. Launch the game once so BepInEx generates `BepInEx/config/eh.mataeo.valheim.slowsailingbagpipes.cfg`.
3. Open that config and set `Audio.TrackDirectory` to either the default folder name (relative to the plugin DLL) or an absolute path somewhere else on disk.
4. Save the file; the mod hot-reloads the directory and randomly selects a clip every time playback starts. Empty folders are handled gracefully (music just stays silent until files are added).

## Logging

`src/SlowSailingBagpipes` includes a rolling file logger that mirrors all BepInEx messages to `Logs/SlowSailingBagpipes-YYYY-MM-DD-HH-mm.log` inside the plugin folder (gitignored). Only the seven newest logs are retained. Every function, timer transition, and audio event writes at **DEBUG** level by default so you can inspect bagpipe behavior from the log files.

## macOS Completion Notification

Use `scripts/codex_alert.sh` to raise a native notification when Codex/the build pipeline finishes:

```bash
# Success case
scripts/codex_alert.sh --success

# Report remaining tasks
scripts/codex_alert.sh --remaining 2
```

The script automatically plays the default alert sound and is limited to macOS (`osascript`).

## Next Steps

1. Scaffold the BepInEx plugin (`src/SlowSailingBagpipes`).
2. Wire ship-state detection + music controller logic.
3. Replace the placeholder track with the real bagpipe recording and re-test.
