using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
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
    private const string PluginVersion = "1.0.0";

    private const float PaddleThresholdSeconds = 3f;
    private const float ResumeGraceSeconds = 10f;
    private const float FadeInDuration = 1.5f;
    private const float FadeOutDuration = 0.5f;
    private const string PlaceholderTrackName = "ghost_bagpipe_track.mp3";
    private const string DefaultTrackDirectoryName = "BagPipesTracks";

    private static readonly string[] SupportedExtensions = { ".mp3", ".ogg", ".wav" };

    private ConfigEntry<bool>? _enabled;
    private ConfigEntry<float>? _volume;
    private ConfigEntry<string>? _trackDirectoryConfig;

    private PluginLogger? _fileLogger;
    private AudioSource? _audioSource;

    private readonly Dictionary<string, AudioClip> _clipCache = new();
    private readonly System.Random _rng = new();

    private string? _pluginDirectory;
    private string? _trackDirectory;
    private List<string> _trackPaths = new();
    private Coroutine? _clipLoadRoutine;
    private string? _pendingTrackPath;
    private bool _pendingPlayback;

    private bool _isPlaying;
    private float _paddleTimer;
    private float _resumeUntil;
    private float _storedMusicVolume = 1f;
    private bool _musicManMuted;

    private void Awake()
    {
        LogDebug("Awake invoked; binding configuration and initializing logging.");

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

        Config.SettingChanged += (_, args) =>
        {
            LogDebug($"Config setting changed: {args.ChangedSetting.Definition.Key}.");
            if (args.ChangedSetting == _volume && _isPlaying && _audioSource != null)
            {
                _audioSource.volume = _volume!.Value;
            }
            else if (_trackDirectoryConfig != null && args.ChangedSetting == _trackDirectoryConfig)
            {
                LogInfo($"Track directory changed to {_trackDirectoryConfig.Value}; refreshing library.");
                UpdateTrackDirectory(_trackDirectoryConfig.Value);
            }
        };
    }

    private void Update()
    {
        LogDebug("Update tick invoked.");

        if (_enabled is not { Value: true })
        {
            LogInfo("Mod disabled via config; ensuring playback is stopped.");
            StopBagpipes(immediate: true);
            return;
        }

        if (_audioSource == null)
        {
            LogWarn("Audio source not initialized; aborting update.");
            return;
        }

        var player = Player.m_localPlayer;
        if (player == null)
        {
            LogDebug("No local player present; stopping audio.");
            StopBagpipes(immediate: true);
            return;
        }

        // Check if player is controlling a ship and paddling at slow speed (forward rowing) or backward
        var ship = player.GetControlledShip();
        var isPaddling = ship != null && (ship.GetSpeedSetting() == Ship.Speed.Slow || ship.GetSpeedSetting() == Ship.Speed.Back);
        LogDebug($"Player paddling state: {isPaddling}.");

        if (isPaddling)
        {
            HandlePaddlingState();
        }
        else
        {
            HandleNonPaddlingState();
        }
    }

    private void HandlePaddlingState()
    {
        LogDebug("Handling paddling state.");

        _paddleTimer += Time.deltaTime;
        var skipDelay = Time.time <= _resumeUntil;
        LogDebug($"Paddle timer: {_paddleTimer:F2}, skipDelay: {skipDelay}.");

        if (!_isPlaying && !_pendingPlayback && (_paddleTimer >= PaddleThresholdSeconds || skipDelay))
        {
            LogInfo("Paddling conditions met; requesting bagpipe playback.");
            StartBagpipes();
        }
    }

    private void HandleNonPaddlingState()
    {
        LogDebug("Handling non-paddling state.");

        _paddleTimer = 0f;

        if (_pendingPlayback)
        {
            LogInfo("Cancelling pending playback due to paddling stop.");
            CancelPendingPlayback();
        }

        if (_isPlaying)
        {
            _resumeUntil = Time.time + ResumeGraceSeconds;
            LogInfo($"Exiting Paddle; granting resume window until {_resumeUntil:F2}.");
            StopBagpipes();
        }
        else if (Time.time > _resumeUntil)
        {
            _resumeUntil = 0f;
        }
    }

    private AudioSource CreateAudioSource()
    {
        LogDebug("Creating persistent audio source.");

        var holder = new GameObject("SlowSailingBagpipes_AudioCarrier");
        DontDestroyOnLoad(holder);

        var source = holder.AddComponent<AudioSource>();
        source.playOnAwake = false;
        source.loop = true;
        source.volume = 0f;
        source.spatialBlend = 0f;
        return source;
    }

    private void EnsurePlaceholderTrackExists(string trackDirectory)
    {
        LogDebug("Ensuring placeholder bagpipe track exists.");
        var placeholderPath = Path.Combine(trackDirectory, PlaceholderTrackName);
        if (!File.Exists(placeholderPath))
        {
            File.WriteAllBytes(placeholderPath, Array.Empty<byte>());
            LogInfo("Created ghost_bagpipe_track.mp3 placeholder. Replace with a real loop when available.");
        }
    }

    private void RefreshTrackLibrary()
    {
        LogDebug("Refreshing track library from disk.");

        if (_trackDirectory == null)
        {
            return;
        }

        _trackPaths = Directory
            .EnumerateFiles(_trackDirectory, "*.*", SearchOption.TopDirectoryOnly)
            .Where(path => SupportedExtensions.Contains(Path.GetExtension(path), StringComparer.OrdinalIgnoreCase))
            .ToList();

        if (_trackPaths.Count == 0)
        {
            LogWarn($"No bagpipe tracks found in {_trackDirectory}. Playback will be skipped until files are added.");
        }
        else
        {
            LogInfo($"Loaded {_trackPaths.Count} bagpipe track(s) from {_trackDirectory}. A random clip will be selected per session.");
        }
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
        LogDebug("Attempting to start bagpipe playback.");

        if (_audioSource == null)
        {
            LogWarn("AudioSource missing; cannot play bagpipes.");
            return;
        }

        if (_trackPaths.Count == 0)
        {
            RefreshTrackLibrary();
            if (_trackPaths.Count == 0)
            {
                LogWarn($"Still no available tracks after refresh (search path: {_trackDirectory}). Aborting playback request.");
                return;
            }
        }

        var nextTrack = SelectRandomTrack();
        if (nextTrack == null)
        {
            LogWarn("Random selection returned null; aborting playback.");
            return;
        }

        _pendingPlayback = true;

        if (_clipCache.TryGetValue(nextTrack, out var cachedClip) && cachedClip != null)
        {
            LogDebug($"Using cached clip for {Path.GetFileName(nextTrack)}.");
            PlayClip(cachedClip, nextTrack);
            return;
        }

        _pendingTrackPath = nextTrack;
        if (_clipLoadRoutine != null)
        {
            StopCoroutine(_clipLoadRoutine);
        }

        _clipLoadRoutine = StartCoroutine(LoadClipCoroutine(nextTrack));
    }

    private void StopBagpipes(bool immediate = false)
    {
        LogDebug($"Stopping bagpipes (immediate={immediate}).");

        if (!_isPlaying || _audioSource == null)
        {
            if (immediate)
            {
                CancelPendingPlayback();
            }
            return;
        }

        if (immediate)
        {
            _audioSource.Stop();
            _audioSource.volume = 0f;
            _isPlaying = false;
            ToggleMusicManMute(shouldMute: false);
            CancelPendingPlayback();
            return;
        }

        StartCoroutine(FadeVolume(targetVolume: 0f, FadeOutDuration, onComplete: () =>
        {
            _audioSource.Stop();
            _isPlaying = false;
            ToggleMusicManMute(shouldMute: false);
        }));
    }

    private IEnumerator FadeVolume(float targetVolume, float fadeDuration, Action? onComplete = null)
    {
        LogDebug($"Fading audio towards {targetVolume} over {fadeDuration}s.");

        if (_audioSource == null)
        {
            yield break;
        }

        var startVolume = _audioSource.volume;
        var elapsed = 0f;

        while (elapsed < fadeDuration)
        {
            elapsed += Time.deltaTime;
            var t = Mathf.Clamp01(elapsed / fadeDuration);
            _audioSource.volume = Mathf.Lerp(startVolume, targetVolume, t);
            yield return null;
        }

        _audioSource.volume = targetVolume;
        onComplete?.Invoke();
    }

    private void ToggleMusicManMute(bool shouldMute)
    {
        LogDebug($"ToggleMusicManMute called with shouldMute={shouldMute}.");

        var musicMan = MusicMan.instance;
        if (musicMan == null)
        {
            LogWarn("MusicMan instance not found; cannot toggle default soundtrack.");
            return;
        }

        var source = musicMan.m_musicSource;
        if (source == null)
        {
            LogWarn("MusicMan audio source missing.");
            return;
        }

        if (shouldMute && !_musicManMuted)
        {
            _storedMusicVolume = source.volume;
            source.volume = 0f;
            source.Stop();
            _musicManMuted = true;
            LogInfo("MusicMan muted.");
        }
        else if (!shouldMute && _musicManMuted)
        {
            source.volume = _storedMusicVolume;
            _musicManMuted = false;
            LogInfo("MusicMan restored.");
        }
    }

    private string? SelectRandomTrack()
    {
        LogDebug("Selecting a random bagpipe track.");

        if (_trackPaths.Count == 0)
        {
            return null;
        }

        var index = _rng.Next(0, _trackPaths.Count);
        return _trackPaths[index];
    }

    private IEnumerator LoadClipCoroutine(string trackPath)
    {
        LogInfo($"Loading track {Path.GetFileName(trackPath)} from disk.");

        var uri = new Uri(trackPath);
        var audioType = GetAudioTypeForExtension(Path.GetExtension(trackPath));

        using var request = UnityWebRequestMultimedia.GetAudioClip(uri.AbsoluteUri, audioType);
        yield return request.SendWebRequest();

        if (request.result != UnityWebRequest.Result.Success)
        {
            LogError($"Failed to load {trackPath}: {request.error}");
            _pendingPlayback = false;
            _clipLoadRoutine = null;
            yield break;
        }

        var clip = DownloadHandlerAudioClip.GetContent(request);
        _clipCache[trackPath] = clip;

        if (!_pendingPlayback || _pendingTrackPath != trackPath)
        {
            LogDebug("Clip loaded but playback is no longer pending.");
            _clipLoadRoutine = null;
            yield break;
        }

        PlayClip(clip, trackPath);
        _clipLoadRoutine = null;
    }

    private void PlayClip(AudioClip clip, string trackPath)
    {
        LogInfo($"Starting clip {Path.GetFileName(trackPath)}.");

        if (_audioSource == null)
        {
            LogWarn("AudioSource missing during PlayClip.");
            return;
        }

        _pendingPlayback = false;
        _pendingTrackPath = null;

        _audioSource.clip = clip;
        _audioSource.volume = 0f;
        _audioSource.Play();
        _isPlaying = true;

        StartCoroutine(FadeVolume(targetVolume: _volume!.Value, FadeInDuration));
        ToggleMusicManMute(shouldMute: true);
    }

    private void CancelPendingPlayback()
    {
        LogDebug("Cancelling pending playback request.");

        _pendingPlayback = false;
        _pendingTrackPath = null;
        if (_clipLoadRoutine != null)
        {
            StopCoroutine(_clipLoadRoutine);
            _clipLoadRoutine = null;
        }
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
