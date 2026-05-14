using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using BepInEx;
using BepInEx.Configuration;
using SailingBagpipes.Logging;
using UnityEngine;
using UnityEngine.Networking;

namespace SailingBagpipes;

/// <summary>
/// Main entry point for the Slow Sailing Bagpipes mod.
/// </summary>
[BepInPlugin(PluginGuid, PluginName, PluginVersion)]
public class Plugin : BaseUnityPlugin
{
    private const string PluginGuid = "eh.mataeo.valheim.slowsailingbagpipes";
    private const string PluginName = "SlowSailingBagpipes";
    private const string PluginVersion = "1.0.5";

    private const float PaddleThresholdSeconds = 0.1f;
    private const float ResumeGraceSeconds = 10f;
    private const float FadeInDuration = 1.5f;
    private const float FadeOutDuration = 0.5f;
    private const string PlaceholderTrackName = "ghost_bagpipe_track.mp3";
    private const string DefaultTrackDirectoryName = "BagPipesTracks";

    private static readonly string[] SupportedExtensions = { ".mp3", ".ogg", ".wav" };
    private static readonly FieldInfo? ShipPlayersField = typeof(Ship).GetField("m_players", BindingFlags.Instance | BindingFlags.NonPublic);
    private static readonly FieldInfo? MusicManMusicSourceField = typeof(MusicMan).GetField("m_musicSource", BindingFlags.Instance | BindingFlags.NonPublic);

    private ConfigEntry<bool>? _enabled;
    private ConfigEntry<float>? _volume;
    private ConfigEntry<string>? _trackDirectoryConfig;

    private PluginLogger? _fileLogger;
    private GameObject? _audioHolder;
    private AudioSource? _audioSource;

    private readonly Dictionary<string, AudioClip> _clipCache = new();
    private readonly System.Random _rng = new();

    private string? _pluginDirectory;
    private string? _trackDirectory;
    private List<string> _trackPaths = new();
    private Coroutine? _clipLoadRoutine;
    private Coroutine? _fadeRoutine;
    private string? _pendingTrackPath;
    private bool _pendingPlayback;

    private bool _isPlaying;
    private bool _isPausedForGrace;
    private float _paddleTimer;
    private float _resumeUntil;
    private float _storedMusicVolume = 1f;
    private bool _musicManSuppressed;
    private bool _musicManWasPlaying;
    private bool _audioSourceConfiguredFromMusicMan;
    private int _lastControlledShipId = -1;
    private string _lastControlledShipName = "None";
    private Ship.Speed? _lastSpeedSetting;
    private bool _lastEligibleRowingState;
    private string _lastControllerDescription = "None";
    private bool? _lastAttachedToShip;

    private void Awake()
    {
        _pluginDirectory = Path.GetDirectoryName(Info.Location) ?? Paths.PluginPath;
        _fileLogger = new PluginLogger(PluginName, _pluginDirectory);

        _enabled = Config.Bind("General", "Enabled", true, "Master toggle for the Slow Sailing Bagpipes mod.");
        _volume = Config.Bind("General", "Volume", 0.85f, new ConfigDescription("Playback volume for the bagpipe loop.", new AcceptableValueRange<float>(0f, 1f)));
        _trackDirectoryConfig = Config.Bind(
            "Audio",
            "TrackDirectory",
            DefaultTrackDirectoryName,
            "Directory (absolute or relative to the plugin folder) that contains bagpipe audio clips."
        );

        UpdateTrackDirectory(_trackDirectoryConfig.Value);
        _audioSource = CreateAudioSource();

        Config.SettingChanged += OnConfigSettingChanged;

        LogInfo($"Initialized. Watching track directory: {_trackDirectory}");
    }

    private void OnDestroy()
    {
        Config.SettingChanged -= OnConfigSettingChanged;
        StopBagpipes(immediate: true);
        ClearClipCache();

        if (_audioHolder != null)
        {
            Destroy(_audioHolder);
            _audioHolder = null;
        }
    }

    private void Update()
    {
        if (_enabled is not { Value: true })
        {
            if (_isPlaying || _isPausedForGrace || _pendingPlayback)
            {
                StopBagpipes(immediate: true);
            }

            return;
        }

        if (_audioSource == null)
        {
            LogWarn("Audio source not initialized; skipping update.");
            return;
        }

        SyncAudioSourceWithMusicMan();

        var player = Player.m_localPlayer;
        if (player == null)
        {
            if (_isPlaying || _isPausedForGrace || _pendingPlayback)
            {
                StopBagpipes(immediate: true);
            }

            LogControlState(null, null, null, "None");
            return;
        }

        var ship = ResolveControlledShip(player, out var controllerDescription);
        Ship.Speed? speedSetting = ship?.GetSpeedSetting();
        LogControlState(player, ship, speedSetting, controllerDescription);

        var isRowingAtTriggerSpeed = speedSetting.HasValue && IsRowingAtTriggerSpeed(speedSetting.Value);

        if (isRowingAtTriggerSpeed)
        {
            HandleRowingState(ship!, speedSetting!.Value);
            return;
        }

        HandleNonRowingState(ship, speedSetting);
    }

    private void OnConfigSettingChanged(object? sender, SettingChangedEventArgs args)
    {
        if (_audioSource == null)
        {
            return;
        }

        if (args.ChangedSetting == _volume)
        {
            if (_isPlaying)
            {
                _audioSource.volume = _volume!.Value;
            }

            return;
        }

        if (_trackDirectoryConfig != null && args.ChangedSetting == _trackDirectoryConfig)
        {
            LogInfo($"Track directory changed to {_trackDirectoryConfig.Value}; reloading library.");
            StopBagpipes(immediate: true);
            ClearClipCache();
            UpdateTrackDirectory(_trackDirectoryConfig.Value);
        }
    }

    private static bool IsRowingAtTriggerSpeed(Ship.Speed speedSetting) =>
        speedSetting == Ship.Speed.Slow || speedSetting == Ship.Speed.Back;

    private void HandleRowingState(Ship ship, Ship.Speed speedSetting)
    {
        if (!_lastEligibleRowingState)
        {
            LogInfo($"Detected eligible rowing on {GetShipDisplayName(ship)} at speed setting {speedSetting}; waiting for {PaddleThresholdSeconds:F1}s threshold.");
        }

        _lastEligibleRowingState = true;
        _paddleTimer += Time.deltaTime;

        if (_isPausedForGrace && Time.time <= _resumeUntil)
        {
            LogInfo($"Resuming paused clip on {GetShipDisplayName(ship)} within grace window.");
            ResumeBagpipes();
            return;
        }

        var canSkipDelay = _resumeUntil > 0f && Time.time <= _resumeUntil;
        if (!_isPlaying && !_pendingPlayback && !_isPausedForGrace && (_paddleTimer >= PaddleThresholdSeconds || canSkipDelay))
        {
            LogInfo($"Rowing threshold satisfied on {GetShipDisplayName(ship)} at speed setting {speedSetting}; starting bagpipes.");
            StartBagpipes();
        }
    }

    private void HandleNonRowingState(Ship? ship, Ship.Speed? speedSetting)
    {
        if (_lastEligibleRowingState)
        {
            var shipName = ship != null ? GetShipDisplayName(ship) : _lastControlledShipName;
            var speedDescription = speedSetting?.ToString() ?? "None";
            LogInfo($"Eligible rowing ended on {shipName}; current speed setting {speedDescription}; timer reached {_paddleTimer:F2}s.");
        }

        _lastEligibleRowingState = false;
        _paddleTimer = 0f;

        if (_pendingPlayback)
        {
            CancelPendingPlayback();
        }

        if (_isPlaying)
        {
            _resumeUntil = Time.time + ResumeGraceSeconds;
            PauseBagpipesForGrace();
            return;
        }

        if (_isPausedForGrace && Time.time > _resumeUntil)
        {
            StopBagpipes(immediate: true);
            return;
        }

        if (!_isPausedForGrace && Time.time > _resumeUntil)
        {
            _resumeUntil = 0f;
        }
    }

    private AudioSource CreateAudioSource()
    {
        _audioHolder = new GameObject("SlowSailingBagpipes_AudioCarrier");
        DontDestroyOnLoad(_audioHolder);

        var source = _audioHolder.AddComponent<AudioSource>();
        source.playOnAwake = false;
        source.loop = true;
        source.volume = 0f;
        source.spatialBlend = 0f;
        source.priority = 64;
        return source;
    }

    private void SyncAudioSourceWithMusicMan()
    {
        if (_audioSource == null || _audioSourceConfiguredFromMusicMan)
        {
            return;
        }

        var template = GetMusicManAudioSource();
        if (template == null)
        {
            return;
        }

        _audioSource.outputAudioMixerGroup = template.outputAudioMixerGroup;
        _audioSource.priority = template.priority;
        _audioSource.pitch = 1f;
        _audioSource.panStereo = 0f;
        _audioSource.reverbZoneMix = template.reverbZoneMix;
        _audioSource.bypassEffects = template.bypassEffects;
        _audioSource.bypassListenerEffects = template.bypassListenerEffects;
        _audioSource.bypassReverbZones = template.bypassReverbZones;
        _audioSource.ignoreListenerPause = template.ignoreListenerPause;
        _audioSource.ignoreListenerVolume = template.ignoreListenerVolume;
        _audioSource.mute = false;
        _audioSource.spatialBlend = 0f;
        _audioSource.dopplerLevel = 0f;
        _audioSource.spread = 0f;

        _audioSourceConfiguredFromMusicMan = true;
        LogInfo("Audio source synced to Valheim music mixer settings.");
    }

    private void LogControlState(Player? player, Ship? ship, Ship.Speed? speedSetting, string controllerDescription)
    {
        if (player == null)
        {
            if (_lastControlledShipId != -1 || _lastSpeedSetting != null || _lastControllerDescription != "None" || _lastAttachedToShip != null)
            {
                LogInfo("No local player is active; cleared ship control state.");
            }

            _lastControlledShipId = -1;
            _lastControlledShipName = "None";
            _lastSpeedSetting = null;
            _lastControllerDescription = "None";
            _lastAttachedToShip = null;
            return;
        }

        var attachedToShip = player.IsAttachedToShip();

        if (ship == null)
        {
            if (_lastControlledShipId != -1 || _lastSpeedSetting != null || controllerDescription != _lastControllerDescription || attachedToShip != _lastAttachedToShip)
            {
                LogInfo($"No controlled ship resolved. AttachedToShip={attachedToShip} controller={controllerDescription}.");
            }

            _lastControlledShipId = -1;
            _lastControlledShipName = "None";
            _lastSpeedSetting = null;
            _lastControllerDescription = controllerDescription;
            _lastAttachedToShip = attachedToShip;
            return;
        }

        var shipId = ship.GetInstanceID();
        var shipName = GetShipDisplayName(ship);
        if (shipId != _lastControlledShipId || speedSetting != _lastSpeedSetting || controllerDescription != _lastControllerDescription || attachedToShip != _lastAttachedToShip)
        {
            LogInfo(
                $"Ship control state: ship={shipName} speedSetting={speedSetting} speed={ship.GetSpeed():F2} rudder={ship.GetRudder():F2} attached={attachedToShip} controller={controllerDescription}."
            );
        }

        _lastControlledShipId = shipId;
        _lastControlledShipName = shipName;
        _lastSpeedSetting = speedSetting;
        _lastControllerDescription = controllerDescription;
        _lastAttachedToShip = attachedToShip;
    }

    private static string GetShipDisplayName(Ship ship)
    {
        var objectName = ship.gameObject != null ? ship.gameObject.name : ship.name;
        return string.IsNullOrWhiteSpace(objectName) ? ship.GetType().Name : objectName;
    }

    private static Ship? ResolveControlledShip(Player player, out string controllerDescription)
    {
        var directShip = player.GetControlledShip();
        if (directShip != null)
        {
            controllerDescription = "Player.GetControlledShip";
            return directShip;
        }

        var controller = player.GetDoodadController();
        if (controller == null)
        {
            controllerDescription = "None";
            return null;
        }

        var controlledComponent = controller.GetControlledComponent();
        controllerDescription = controlledComponent == null
            ? controller.GetType().Name
            : $"{controller.GetType().Name}->{controlledComponent.GetType().Name}";

        if (controlledComponent is Ship controlledShip)
        {
            return controlledShip;
        }

        if (controlledComponent == null)
        {
            return ResolveAttachedShip(player, ref controllerDescription);
        }

        var resolvedShip = controlledComponent.GetComponent<Ship>() ?? controlledComponent.GetComponentInParent<Ship>();
        return resolvedShip ?? ResolveAttachedShip(player, ref controllerDescription);
    }

    private static Ship? ResolveAttachedShip(Player player, ref string controllerDescription)
    {
        Ship? nearestAttachedShip = null;
        var nearestDistance = float.MaxValue;

        foreach (var ship in FindObjectsByType<Ship>(FindObjectsSortMode.None))
        {
            if (ShipContainsPlayer(ship, player))
            {
                controllerDescription = AppendResolutionSource(controllerDescription, "Ship.m_players");
                return ship;
            }

            if (!player.IsAttachedToShip())
            {
                continue;
            }

            var distance = Vector3.Distance(player.transform.position, ship.transform.position);
            if (distance < nearestDistance)
            {
                nearestDistance = distance;
                nearestAttachedShip = ship;
            }
        }

        if (nearestAttachedShip != null && nearestDistance <= 25f)
        {
            controllerDescription = AppendResolutionSource(controllerDescription, $"NearestAttachedShip({nearestDistance:F1}m)");
            return nearestAttachedShip;
        }

        return null;
    }

    private static bool ShipContainsPlayer(Ship ship, Player player)
    {
        if (ShipPlayersField?.GetValue(ship) is not List<Player> players)
        {
            return false;
        }

        return players.Contains(player);
    }

    private static string AppendResolutionSource(string currentDescription, string source)
    {
        if (string.IsNullOrWhiteSpace(currentDescription) || currentDescription == "None")
        {
            return source;
        }

        return $"{currentDescription}+{source}";
    }

    private void EnsurePlaceholderTrackExists(string trackDirectory)
    {
        var placeholderPath = Path.Combine(trackDirectory, PlaceholderTrackName);
        if (!File.Exists(placeholderPath))
        {
            File.WriteAllBytes(placeholderPath, Array.Empty<byte>());
            LogInfo("Created placeholder track file. Replace it with a real MP3, OGG, or WAV file.");
        }
    }

    private void RefreshTrackLibrary()
    {
        if (_trackDirectory == null)
        {
            return;
        }

        _trackPaths = Directory
            .EnumerateFiles(_trackDirectory, "*.*", SearchOption.TopDirectoryOnly)
            .Where(path => SupportedExtensions.Contains(Path.GetExtension(path), StringComparer.OrdinalIgnoreCase))
            .Where(path => new FileInfo(path).Length > 0)
            .OrderBy(path => path, StringComparer.OrdinalIgnoreCase)
            .ToList();

        if (_trackPaths.Count == 0)
        {
            LogWarn($"No playable bagpipe tracks found in {_trackDirectory}. Add non-empty MP3, OGG, or WAV files.");
            return;
        }

        LogInfo($"Loaded {_trackPaths.Count} playable bagpipe track(s) from {_trackDirectory}.");
    }

    private void UpdateTrackDirectory(string directorySetting)
    {
        if (string.IsNullOrWhiteSpace(directorySetting))
        {
            directorySetting = DefaultTrackDirectoryName;
            if (_trackDirectoryConfig != null)
            {
                _trackDirectoryConfig.Value = DefaultTrackDirectoryName;
            }
        }

        var resolvedPath = ResolveTrackDirectory(directorySetting);
        _trackDirectory = resolvedPath;
        Directory.CreateDirectory(resolvedPath);

        if (IsDefaultTrackDirectory(directorySetting))
        {
            EnsurePlaceholderTrackExists(resolvedPath);
        }

        RefreshTrackLibrary();
    }

    private string ResolveTrackDirectory(string configuredPath)
    {
        if (Path.IsPathRooted(configuredPath))
        {
            return configuredPath;
        }

        var baseDir = _pluginDirectory ?? Paths.PluginPath;
        return Path.Combine(baseDir, configuredPath);
    }

    private static bool IsDefaultTrackDirectory(string directorySetting) =>
        string.Equals(directorySetting, DefaultTrackDirectoryName, StringComparison.OrdinalIgnoreCase);

    private void StartBagpipes()
    {
        if (_audioSource == null)
        {
            LogWarn("Audio source missing; cannot start playback.");
            return;
        }

        SyncAudioSourceWithMusicMan();

        if (_trackPaths.Count == 0)
        {
            RefreshTrackLibrary();
            if (_trackPaths.Count == 0)
            {
                return;
            }
        }

        var nextTrack = SelectRandomTrack();
        if (nextTrack == null)
        {
            LogWarn("Track selection returned no result.");
            return;
        }

        _pendingPlayback = true;
        _pendingTrackPath = nextTrack;

        if (_clipCache.TryGetValue(nextTrack, out var cachedClip) && cachedClip != null)
        {
            PlayClip(cachedClip, nextTrack);
            return;
        }

        CancelFade();

        if (_clipLoadRoutine != null)
        {
            StopCoroutine(_clipLoadRoutine);
        }

        _clipLoadRoutine = StartCoroutine(LoadClipCoroutine(nextTrack));
    }

    private void PauseBagpipesForGrace()
    {
        if (_audioSource == null || _audioSource.clip == null)
        {
            return;
        }

        if (_isPausedForGrace)
        {
            return;
        }

        _isPlaying = false;
        _isPausedForGrace = true;

        StartFade(targetVolume: 0f, FadeOutDuration, () =>
        {
            if (_audioSource == null)
            {
                return;
            }

            if (_isPausedForGrace && Time.time <= _resumeUntil)
            {
                _audioSource.Pause();
            }
            else
            {
                _audioSource.Stop();
                _audioSource.clip = null;
                _isPausedForGrace = false;
            }

            SetGameMusicSuppressed(shouldSuppress: false);
        });
    }

    private void ResumeBagpipes()
    {
        if (_audioSource == null || _audioSource.clip == null)
        {
            _isPausedForGrace = false;
            StartBagpipes();
            return;
        }

        CancelFade();

        if (!_audioSource.isPlaying)
        {
            _audioSource.UnPause();
        }

        _isPausedForGrace = false;
        _isPlaying = true;
        SetGameMusicSuppressed(shouldSuppress: true);
        StartFade(targetVolume: _volume!.Value, FadeInDuration);
    }

    private void StopBagpipes(bool immediate = false)
    {
        CancelPendingPlayback();

        if (_audioSource == null)
        {
            _isPlaying = false;
            _isPausedForGrace = false;
            _resumeUntil = 0f;
            return;
        }

        CancelFade();
        _isPlaying = false;
        _isPausedForGrace = false;
        _resumeUntil = 0f;

        if (immediate)
        {
            _audioSource.Stop();
            _audioSource.clip = null;
            _audioSource.volume = 0f;
            SetGameMusicSuppressed(shouldSuppress: false);
            return;
        }

        StartFade(targetVolume: 0f, FadeOutDuration, () =>
        {
            if (_audioSource == null)
            {
                return;
            }

            _audioSource.Stop();
            _audioSource.clip = null;
            SetGameMusicSuppressed(shouldSuppress: false);
        });
    }

    private void StartFade(float targetVolume, float fadeDuration, Action? onComplete = null)
    {
        CancelFade();
        _fadeRoutine = StartCoroutine(FadeVolume(targetVolume, fadeDuration, onComplete));
    }

    private void CancelFade()
    {
        if (_fadeRoutine != null)
        {
            StopCoroutine(_fadeRoutine);
            _fadeRoutine = null;
        }
    }

    private IEnumerator FadeVolume(float targetVolume, float fadeDuration, Action? onComplete = null)
    {
        if (_audioSource == null)
        {
            yield break;
        }

        if (fadeDuration <= 0f)
        {
            _audioSource.volume = targetVolume;
            _fadeRoutine = null;
            onComplete?.Invoke();
            yield break;
        }

        var startVolume = _audioSource.volume;
        var elapsed = 0f;

        while (elapsed < fadeDuration)
        {
            if (_audioSource == null)
            {
                yield break;
            }

            elapsed += Time.deltaTime;
            var t = Mathf.Clamp01(elapsed / fadeDuration);
            _audioSource.volume = Mathf.Lerp(startVolume, targetVolume, t);
            yield return null;
        }

        if (_audioSource != null)
        {
            _audioSource.volume = targetVolume;
        }

        _fadeRoutine = null;
        onComplete?.Invoke();
    }

    private void SetGameMusicSuppressed(bool shouldSuppress)
    {
        var source = GetMusicManAudioSource();
        if (source == null)
        {
            return;
        }

        if (shouldSuppress && !_musicManSuppressed)
        {
            _storedMusicVolume = source.volume;
            _musicManWasPlaying = source.isPlaying;
            source.volume = 0f;

            if (_musicManWasPlaying)
            {
                source.Pause();
            }

            _musicManSuppressed = true;
            return;
        }

        if (!shouldSuppress && _musicManSuppressed)
        {
            source.volume = _storedMusicVolume;

            if (_musicManWasPlaying)
            {
                source.UnPause();
            }

            _musicManSuppressed = false;
            _musicManWasPlaying = false;
        }
    }

    private AudioSource? GetMusicManAudioSource()
    {
        var musicMan = MusicMan.instance;
        if (musicMan == null || MusicManMusicSourceField == null)
        {
            return null;
        }

        try
        {
            return MusicManMusicSourceField.GetValue(musicMan) as AudioSource;
        }
        catch (Exception ex)
        {
            LogWarn($"Unable to resolve MusicMan audio source via reflection: {ex.GetType().Name}: {ex.Message}");
            return null;
        }
    }

    private string? SelectRandomTrack()
    {
        if (_trackPaths.Count == 0)
        {
            return null;
        }

        var index = _rng.Next(0, _trackPaths.Count);
        return _trackPaths[index];
    }

    private IEnumerator LoadClipCoroutine(string trackPath)
    {
        LogInfo($"Loading track {Path.GetFileName(trackPath)}.");

        var uri = new Uri(trackPath);
        var audioType = GetAudioTypeForExtension(Path.GetExtension(trackPath));

        using var request = UnityWebRequestMultimedia.GetAudioClip(uri.AbsoluteUri, audioType);
        yield return request.SendWebRequest();

        if (request.result != UnityWebRequest.Result.Success)
        {
            LogError($"Failed to load {trackPath}: {request.error}");
            _pendingPlayback = false;
            _pendingTrackPath = null;
            _clipLoadRoutine = null;
            yield break;
        }

        var clip = DownloadHandlerAudioClip.GetContent(request);
        clip.name = Path.GetFileNameWithoutExtension(trackPath);
        _clipCache[trackPath] = clip;
        LogInfo($"Loaded clip metadata: length={clip.length:F1}s channels={clip.channels} frequency={clip.frequency}.");

        if (!_pendingPlayback || _pendingTrackPath != trackPath)
        {
            _clipLoadRoutine = null;
            yield break;
        }

        PlayClip(clip, trackPath);
        _clipLoadRoutine = null;
    }

    private void PlayClip(AudioClip clip, string trackPath)
    {
        if (_audioSource == null)
        {
            LogWarn("Audio source missing during playback start.");
            return;
        }

        LogInfo($"Starting clip {Path.GetFileName(trackPath)}.");

        CancelFade();

        _pendingPlayback = false;
        _pendingTrackPath = null;
        _isPausedForGrace = false;
        _isPlaying = true;

        _audioSource.clip = clip;
        _audioSource.volume = 0f;
        _audioSource.mute = false;
        _audioSource.Play();

        SetGameMusicSuppressed(shouldSuppress: true);
        StartFade(targetVolume: _volume!.Value, FadeInDuration);
    }

    private void CancelPendingPlayback()
    {
        _pendingPlayback = false;
        _pendingTrackPath = null;

        if (_clipLoadRoutine != null)
        {
            StopCoroutine(_clipLoadRoutine);
            _clipLoadRoutine = null;
        }
    }

    private void ClearClipCache()
    {
        foreach (var clip in _clipCache.Values)
        {
            if (clip != null)
            {
                Destroy(clip);
            }
        }

        _clipCache.Clear();
    }

    private static AudioType GetAudioTypeForExtension(string extension)
    {
        return extension.ToLowerInvariant() switch
        {
            ".mp3" => AudioType.MPEG,
            ".ogg" => AudioType.OGGVORBIS,
            ".wav" => AudioType.WAV,
            _ => AudioType.UNKNOWN
        };
    }

    private void LogDebug(string message)
    {
        Logger.LogDebug(message);
        _fileLogger?.Debug(message);
    }

    private void LogInfo(string message)
    {
        Logger.LogInfo(message);
        _fileLogger?.Info(message);
    }

    private void LogWarn(string message)
    {
        Logger.LogWarning(message);
        _fileLogger?.Warn(message);
    }

    private void LogError(string message)
    {
        Logger.LogError(message);
        _fileLogger?.Error(message);
    }
}
