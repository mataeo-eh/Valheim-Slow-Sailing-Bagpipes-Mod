# Developer Setup Guide

This guide will help you set up the Valheim Slow Sailing Bagpipes mod for development.

## Prerequisites

1. **Valheim** - Installed with BepInEx mod loader
2. **.NET SDK 10.0 or later** - Download from [dotnet.microsoft.com](https://dotnet.microsoft.com/download/dotnet/10.0)
3. **Git** - For version control

## First-Time Setup

### 1. Clone the Repository

```bash
git clone https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod.git
cd Valheim-Slow-Sailing-Bagpipes-Mod
```

### 2. Create Local Configuration Files

These files are gitignored and must be created from the provided templates:

```bash
# Windows Command Prompt
copy src\Environment.props.example src\Environment.props
copy src\DoPrebuild.props.example src\DoPrebuild.props
copy src\SlowSailingBagpipes\Environment.props.example src\SlowSailingBagpipes\Environment.props
copy src\SlowSailingBagpipes\DoPrebuild.props.example src\SlowSailingBagpipes\DoPrebuild.props
```

```bash
# PowerShell
Copy-Item src\Environment.props.example src\Environment.props
Copy-Item src\DoPrebuild.props.example src\DoPrebuild.props
Copy-Item src\SlowSailingBagpipes\Environment.props.example src\SlowSailingBagpipes\Environment.props
Copy-Item src\SlowSailingBagpipes\DoPrebuild.props.example src\SlowSailingBagpipes\DoPrebuild.props
```

### 3. Configure Valheim Installation Path

Edit **both** of these files:
- `src\Environment.props`
- `src\SlowSailingBagpipes\Environment.props`

Update the `VALHEIM_INSTALL` path to match your installation:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <!-- Update this path to your Valheim installation -->
    <VALHEIM_INSTALL>C:\Program Files (x86)\Steam\steamapps\common\Valheim</VALHEIM_INSTALL>
  </PropertyGroup>
</Project>
```

**Common Steam paths:**
- Windows: `C:\Program Files (x86)\Steam\steamapps\common\Valheim`
- Linux: `~/.steam/steam/steamapps/common/Valheim`
- macOS: `~/Library/Application Support/Steam/steamapps/common/Valheim`

### 4. Verify .NET SDK Installation

```bash
dotnet --version
# Should output: 10.0.100 or higher
```

If not installed, download from: https://dotnet.microsoft.com/download/dotnet/10.0

## Building the Mod

### Option 1: Automated Script (Recommended)

The easiest way to build and install:

```bash
# Build and automatically install to Valheim
build_and_install.bat

# Build only (skip installation)
build_and_install.bat /build-only

# Use custom Valheim path
set VALHEIM_PATH=D:\Games\Valheim
build_and_install.bat
```

### Option 2: Manual Build

```bash
cd src\SlowSailingBagpipes
dotnet clean
dotnet build -c Release
```

The compiled DLL will be at: `src\SlowSailingBagpipes\bin\Release\net472\SailingBagpipes.dll`

## Installing the Mod

### Automatic Installation

The `build_and_install.bat` script handles this automatically.

### Manual Installation

1. Copy `src\SlowSailingBagpipes\bin\Release\net472\SailingBagpipes.dll` to:
   ```
   [Valheim]\BepInEx\plugins\SailingBagpipes.dll
   ```

2. Copy the audio folder `BagPipesTracks\` to:
   ```
   [Valheim]\BepInEx\plugins\BagPipesTracks\
   ```

## Adding Custom Audio

1. Place your MP3, OGG, or WAV files in:
   ```
   [Valheim]\BepInEx\plugins\BagPipesTracks\
   ```

2. The mod will randomly select one track when you start rowing.

## Troubleshooting

### Build Errors

**Error: VALHEIM_INSTALL not set**
- Make sure you created `Environment.props` from the `.example` template
- Verify the path in `Environment.props` is correct

**Error: .NET SDK not found**
- Install .NET SDK 10.0 or later
- Make sure `dotnet` is in your PATH

### Installation Issues

**DLL not copying to Valheim**
- Make sure Valheim is not running
- Try running the build script as Administrator
- Verify BepInEx is installed in your Valheim directory

## Development Workflow

1. Make changes to source code
2. Run `build_and_install.bat`
3. Launch Valheim
4. Test the mod
5. Check logs at `[Valheim]\BepInEx\LogOutput.log`

## Configuration Files (IMPORTANT)

The following files are **gitignored** and contain user-specific paths:
- `src/Environment.props`
- `src/DoPrebuild.props`
- `src/SlowSailingBagpipes/Environment.props`
- `src/SlowSailingBagpipes/DoPrebuild.props`

**Never commit these files!** They are automatically ignored by git to prevent
leaking local file paths.

## More Information

- **Full Development Guide:** See [DEVELOPMENT.md](DEVELOPMENT.md)
- **User Documentation:** See [README.md](README.md)
- **Installation Guide:** See [INSTALLATION.md](INSTALLATION.md)
- **Release Process:** See [RELEASING.md](RELEASING.md)

## Support

- **GitHub Issues:** https://github.com/mataeo-eh/Valheim-Slow-Sailing-Bagpipes-Mod/issues
- **Bug Reports:** Please include your BepInEx log when reporting issues
