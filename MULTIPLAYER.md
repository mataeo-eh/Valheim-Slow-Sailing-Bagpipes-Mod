# Multiplayer design and server-only investigation

Investigated on 2026-11-05 against the installed game, rather than relying on
older modding advice. The inspected `assembly_valheim.dll` SHA-256 was
`9F959C0396EC4240D47FCBE5D0D062C428CC627244506DB5EA567F9D77B2B769`.

## Conclusion

There is no supported server-only route in this inspected build that delivers
arbitrary bagpipe tracks to an unmodified client and replaces music only while
that player is aboard an eligible boat. The server can identify recipients;
the missing capability is a vanilla receiver that loads or decodes custom audio.

This is an engineering conclusion from the available protocol and loading paths,
not a proof against every possible engine exploit or future game feature. No
exploit research, arbitrary code execution, or client modification disguised as
server-only behavior is part of this implementation.

## Routes checked

| Candidate | Evidence and outcome |
| --- | --- |
| Targeted RPCs to boat occupants | Targeting is possible. `ZRoutedRpc.HandleRoutedRPC`, `ZNetView.HandleRoutedRPC` and `ZRpc.HandlePackage` dispatch through registered method dictionaries. Sending a new method name cannot make vanilla clients execute a new audio handler. |
| Built-in `RPC_PlayMusic` | A real endpoint exists on `MusicVolume`, registered in `Awake`. Its only parameter is the sender ID, not a track name, URL, bytes, volume or stop command. It checks distance, then invokes `PlayMusic` on that existing local component. |
| Change that volume's music name | `MusicVolume.PlayMusic` reads its local component field `m_musicName` and calls `MusicMan.LocationMusic`. `MusicMan.FindMusic` looks up a name hash in the client's `m_musicHashes` dictionary; it does not interpret a name as a file path or URL. Changing server-side component fields does not change the client's component fields. |
| Networked sound-effect prefab | `ZNetScene.RPC_SpawnObject` accepts position, rotation and prefab hash. `GetPrefab` resolves a local dictionary and rejects a missing prefab. `ZSFX.Play` chooses from that local object's `m_audioClips`. Reusing a vanilla prefab produces its vanilla sounds; putting a custom clip on the server copy does not transmit it. |
| Networked objects / ZDO keys / animations | These synchronize data used by pre-existing client code, not arbitrary Unity components or `AudioClip` contents. A custom key has no audio behavior unless a client reads it. Animation triggers can invoke existing effects; they do not introduce a custom track decoder. |
| Asset bundles / automatic downloads | In the inspected `SoftReferenceableAssets` assembly, bundle loading uses `AssetBundle.LoadFromFile` and `LoadFromFileAsync`. The official asset guide requires shipping bundle files and registering a manifest in code. No automatic server-to-client mod-asset download path was found. |
| Send MP3/OGG/WAV bytes or stream them | Scanned the game logic and utility/platform/asset assemblies for runtime audio creation, sample injection and audio-download calls. No `GetAudioClip`, `AudioClip.Create` or `AudioClip.SetData` call sites were found in those assemblies. Unity having these APIs available does not mean a network handler invokes them. Custom streaming remains possible with a client receiver mod. |
| Reuse voice chat / Steam / PlayFab | No voice capture/playback integration was found in the scanned game code. A platform SDK exposing voice APIs is insufficient without a receiving application using them. Iron Gate's FAQ directs players to external voice software. |
| Remote console / commands | `ZNet.RPC_RemoteCommand` checks the sender against the admin list, then calls `InternalCommand` to run a command on the receiving instance. The ordinary admin-to-server path does not supply a client custom-audio loader. No remotely loadable code/audio route was found in the inspected call sites. |
| URL, chat, signs, profile pictures or cinematics | A URL as text is not audio. Observed web-opening calls are UI actions; the texture download call handles a profile image. `CinematicsManager` assigns pre-existing `VideoClip` assets; no `VideoPlayer.set_url` use was found in the scan. These do not expose a network audio player. |
| Synthesize music using existing sound effects | Repeated vanilla effects might approximate notes in principle. This does not reproduce arbitrary supplied recordings, and the inspected spawn endpoint supplies no per-note pitch, music mixer, fade or soundtrack-suppression controls. It is a different sound-effects feature, not this mod's music replacement. |
| Browser player, Discord bot or companion program | Could stream to selected listeners outside the game, but requires each listener to open/join/run another client. It cannot independently restore/suppress vanilla game music and does not meet the unchanged-client experience. |
| Preinstall audio without a mod | Still changes each client installation. Merely placing files there supplies neither the rowing/boarding logic nor a vanilla remote custom-track loader. A generic audio mod would also be a client requirement, even if this particular DLL were absent. |

The scan enumerated **194 RPC registration sites** in `assembly_valheim` and
also examined `assembly_utils`, `SoftReferenceableAssets` and `Splatform`,
recursing into nested types. Registration sites can repeat endpoint names.
The registration inventory and API-call scan are discovery aids; the key dispatch,
music, sound, prefab and ship methods above were also inspected directly.

Reproduce the inspection with `tools/Inspect-MultiplayerAudio.ps1`, supplying
`-ManagedDir`, a locally available `-CecilPath` (Mono.Cecil), and `-OutputPath`.
The output contains assembly hashes, the RPC registration inventory, capability
call sites and the selected method IL. Keep this generated game-code report
outside tracked source and packages. The local report for this investigation is
in the shared parent's `dist/SlowSailingBagpipes/multiplayer-audio-audit.json`.

Supporting primary documentation:

- [Jotunn RPCs](https://valheim-modding.github.io/Jotunn/tutorials/rpcs.html): custom handlers must be registered on receiving clients.
- [Iron Gate asset loading FAQ](https://www.valheimgame.com/support/modding-faq-for-the-asset-bundle-update-0-217-40/): bundle files, manifests and local registration.
- [Iron Gate communication FAQ](https://www.valheimgame.com/faq/): external software for voice communication.
- [Jotunn network compatibility](https://valheim-modding.github.io/Jotunn/tutorials/networkcompatibility.html): connection enforcement is separate from asset availability.

## Implemented client behavior

Install the mod and playable tracks on each client that wants bagpipes. The
server does not need the mod. Unmodded players can join and retain vanilla music;
installing it only on a host affects that host's listening experience. A dedicated
server has no local player, so this mod initiates no playback there.

The local helmsman or passenger must be registered aboard a ship by Valheim's
boarding trigger. `Player.GetControlledShip` is accepted only with confirmed
`Ship.IsPlayerInBoat(player)` membership. Standing/seated passengers use
`Ship.GetLocalShip`, also with confirmed membership. There is no nearest-boat
distance fallback or global ship scan.

Music follows that ship's `Slow`/`Back` setting, which vanilla `Ship.UpdateControlls`
already replicates through `ZDOVars.s_forward`. It does not require the listening
player to own the ship or hold the rudder. The mod sends no custom RPCs, creates
no network prefabs, and writes no shared game state.

The existing 0.1-second threshold, random track choice, fades, local music
suppression and volume controls remain. The 10-second pause/resume grace applies
on the same boat. Disembarking, changing boat/player, death or teleporting cancels
playback and pending loads immediately and restores vanilla music. Disembarking
uses an immediate cutoff to avoid continuing custom music ashore.

Players choose and play tracks independently; matching track selection or
sample-accurate playback between clients is not implemented. This does not
affect who is eligible to hear music. Native boarding-volume boundaries and
network replication delays still need multiplayer gameplay verification.
