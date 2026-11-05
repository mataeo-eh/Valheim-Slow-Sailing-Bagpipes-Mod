# Multiplayer verification

## Automated checks

Run `dotnet run --project tests/BoatPlayback.Tests.csproj` from the mod repository.
The resolver is compiled directly from production source against small API test
doubles. Eleven scenarios cover passengers without controllers, remote occupants,
stale membership/control, rudder handoff and separate boats. These checks do not
execute Unity physics, audio or networking.

Run `tools/Verify-BoatPlayback.ps1` with `-ManagedDir`, `-CecilPath` and
`-PluginPath` pointing to the current build. It checks the game's boarding APIs
and speed replication path, compiled resolver integration, cancellation/restoration
paths, and absence of RPC/ZDO/network-prefab calls. These are static checks.

Build the plugin against current game assemblies. On systems where Jotunn's
legacy publicizer cannot write to the game installation, use this override from
the mod repository (with the usual ignored `Environment.props` configured):

```powershell
$refs = (Resolve-Path tools/CurrentGameReferences.targets).Path
dotnet build src/SlowSailingBagpipes/SlowSailingBagpipes.csproj -c Release `
    -p:ExecutePrebuild=false "-p:CustomAfterMicrosoftCommonTargets=$refs"
```

`tools/Inspect-MultiplayerAudio.ps1` reproduces the server-only investigation;
see [MULTIPLAYER.md](MULTIPLAYER.md) for parameters, evidence and scope.

## In-game checks still required

Use a host/client session and repeat the relevant cases on a dedicated server.
Use at least two modded clients with playable tracks and one unmodded client.
Check BepInEx logs for exceptions and RPC/missing-prefab warnings.

| Scenario | Expected result |
| --- | --- |
| Host rows forward slowly, modded guest stands aboard without touching a seat/rudder | Both hear their own bagpipes after the threshold and fade. |
| Modded guest sits or holds the mast; helmsman reverses | Passenger still hears bagpipes. |
| Unmodded helmsman rows; modded passenger rides | Passenger hears bagpipes; helmsman hears vanilla audio. |
| Modded observer stands on nearby dock or swims outside boarding volume | Observer's soundtrack stays vanilla. |
| Two nearby boats: A rows, B stops or sails at Half/Full | Only occupants of A hear bagpipes. Repeat with boats swapped. |
| Stop, Half, Full; then return to Slow/Back within 10 seconds on the same boat | Existing 0.5-second fade-out and 1.5-second fade-in/resume behavior; same paused track resumes. |
| Resume after more than 10 seconds | Normal threshold and new random selection. |
| Release rudder or transfer control/network ownership | Passengers retain eligibility; no need for the listener to own the boat. |
| Jump out during playback or while a large clip is loading | Immediate stop/cancellation; vanilla music restored; no late custom playback ashore. |
| Transfer directly to another boat during playback/grace | Old boat's clip, timer and grace are cleared; destination boat governs playback. |
| Boat is destroyed, player dies, teleports, disconnects, exits to menu or joins another world | No orphaned music or stale grace state; vanilla music restored. |
| Disable/re-enable mod during rowing, grace or loading | Playback is cancelled and threshold resets. |
| Music and Master sliders, Volume config, empty/corrupt tracks | Existing volume behavior; failed loads do not leave vanilla music muted. |
| Server without the mod, mixed modded/unmodded clients | Normal join; only opted-in onboard clients have changed music. |
| Dedicated server with the mod installed | No playback without a local player; mixed clients can join normally. |
| Overlapping boat triggers, walk between boats, leave boarding volume | No music after leaving all boat volumes; verify native selection at overlap boundaries. |

As of 2026-11-05, automated resolver checks and the build passed. This matrix has
not been run in-game; do not treat static validation as a multiplayer runtime pass.
