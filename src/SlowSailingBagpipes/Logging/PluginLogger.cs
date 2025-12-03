using System;
using System.IO;
using System.Linq;

namespace SailingBagpipes.Logging;

/// <summary>
/// Writes timestamped log lines to disk while keeping the seven newest files.
/// </summary>
internal sealed class PluginLogger
{
    private const int MaxLogFiles = 7;

    private readonly string _projectName;
    private readonly string _logDirectory;
    private readonly string _logPath;
    private readonly object _gate = new();

    internal PluginLogger(string projectName, string pluginDirectory)
    {
        _projectName = projectName;
        _logDirectory = Path.Combine(pluginDirectory, "Logs");
        Directory.CreateDirectory(_logDirectory);
        _logPath = Path.Combine(_logDirectory, $"{_projectName}-{DateTime.Now:yyyy-MM-dd-HH-mm}.log");
        CleanupOldLogs();
    }

    internal void Debug(string message) => Write("DEBUG", message);
    internal void Info(string message) => Write("INFO", message);
    internal void Warn(string message) => Write("WARN", message);
    internal void Error(string message) => Write("ERROR", message);

    private void Write(string level, string message)
    {
        var line = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}][{level}] {message}";
        lock (_gate)
        {
            File.AppendAllText(_logPath, line + Environment.NewLine);
        }
    }

    private void CleanupOldLogs()
    {
        var matchingFiles = Directory
            .GetFiles(_logDirectory, $"{_projectName}-*.log")
            .OrderByDescending(File.GetCreationTimeUtc)
            .ToList();

        foreach (var obsolete in matchingFiles.Skip(MaxLogFiles))
        {
            try
            {
                File.Delete(obsolete);
            }
            catch (IOException)
            {
                // Ignore failure; file may be locked by another process.
            }
        }
    }
}
