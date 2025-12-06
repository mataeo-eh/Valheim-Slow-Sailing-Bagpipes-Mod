@echo off
REM ============================================================================
REM Valheim Slow Sailing Bagpipes - Build and Install Script
REM ============================================================================
REM This script:
REM   1. Builds the mod in Release configuration
REM   2. Copies the DLL to Valheim's BepInEx plugins folder
REM   3. Copies the audio folder if not already present
REM
REM USAGE:
REM   build_and_install.bat [OPTIONS]
REM
REM OPTIONS:
REM   /help, -h, --help  : Show this help message
REM   /build-only        : Only build, don't install to Valheim
REM
REM ENVIRONMENT VARIABLES (optional):
REM   VALHEIM_PATH       : Override default Valheim installation path
REM   DOTNET_PATH        : Override default .NET SDK path
REM
REM EXAMPLES:
REM   build_and_install.bat
REM   build_and_install.bat /build-only
REM   set VALHEIM_PATH=D:\Games\Valheim && build_and_install.bat
REM ============================================================================

REM Check for help flag
if "%1"=="/help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help
goto :start

:show_help
echo.
echo Valheim Slow Sailing Bagpipes - Build and Install Script
echo.
echo USAGE: build_and_install.bat [OPTIONS]
echo.
echo OPTIONS:
echo   /help, -h, --help  : Show this help message
echo   /build-only        : Only build, don't install to Valheim
echo.
echo ENVIRONMENT VARIABLES (optional):
echo   VALHEIM_PATH       : Override Valheim installation path
echo   DOTNET_PATH        : Override .NET SDK path
echo.
echo EXAMPLES:
echo   build_and_install.bat
echo   build_and_install.bat /build-only
echo   set VALHEIM_PATH=D:\Games\Valheim ^&^& build_and_install.bat
echo.
pause
exit /b 0

:start
echo.
echo ========================================
echo Valheim Slow Sailing Bagpipes - Build
echo ========================================
echo.

REM Configuration
set "PROJECT_DIR=%~dp0src\SlowSailingBagpipes"
set "OUTPUT_DLL=%PROJECT_DIR%\bin\Release\net472\SailingBagpipes.dll"
set "AUDIO_SOURCE=%~dp0BagPipesTracks"

REM Check if build-only mode
set "BUILD_ONLY=0"
if "%1"=="/build-only" set "BUILD_ONLY=1"

REM Determine .NET path (check environment variable first, then defaults)
if defined DOTNET_PATH (
    set "DOTNET=%DOTNET_PATH%"
    echo Using custom .NET path from DOTNET_PATH: %DOTNET%
) else if exist "C:\Program Files\dotnet\dotnet.exe" (
    set "DOTNET=C:\Program Files\dotnet\dotnet.exe"
) else if exist "C:\Program Files (x86)\dotnet\dotnet.exe" (
    set "DOTNET=C:\Program Files (x86)\dotnet\dotnet.exe"
) else (
    set "DOTNET=dotnet.exe"
    echo .NET SDK not found in default locations, trying PATH...
)

REM Determine Valheim plugins path (check environment variable first, then defaults)
if defined VALHEIM_PATH (
    set "VALHEIM_PLUGINS=%VALHEIM_PATH%\BepInEx\plugins"
    echo Using custom Valheim path from VALHEIM_PATH: %VALHEIM_PATH%
) else (
    set "VALHEIM_PLUGINS=C:\Program Files (x86)\Steam\steamapps\common\Valheim\BepInEx\plugins"
)

REM Check if .NET SDK exists
if not exist "%DOTNET%" (
    echo ERROR: .NET SDK not found at: %DOTNET%
    echo Please install .NET SDK 10 or later
    pause
    exit /b 1
)

REM Navigate to project directory
cd /d "%PROJECT_DIR%"
if errorlevel 1 (
    echo ERROR: Could not navigate to project directory
    pause
    exit /b 1
)

REM Clean previous build
echo [1/4] Cleaning previous build...
"%DOTNET%" clean >nul 2>&1

REM Build the project
echo [2/4] Building mod (Release configuration)...
"%DOTNET%" build -c Release

if errorlevel 1 (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo.
    echo Check the error messages above.
    echo See DEVELOPMENT.md for troubleshooting.
    pause
    exit /b 1
)

REM Verify output exists
if not exist "%OUTPUT_DLL%" (
    echo.
    echo ERROR: Build succeeded but DLL not found at:
    echo %OUTPUT_DLL%
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.

REM Get DLL file size
for %%A in ("%OUTPUT_DLL%") do set "DLL_SIZE=%%~zA"
echo Built: SailingBagpipes.dll (%DLL_SIZE% bytes)
echo.

REM Skip installation if build-only mode
if "%BUILD_ONLY%"=="1" (
    echo.
    echo ========================================
    echo BUILD COMPLETE (Build-Only Mode)
    echo ========================================
    echo.
    echo Build output: %OUTPUT_DLL%
    echo.
    echo To install manually:
    echo 1. Copy %OUTPUT_DLL% to Valheim\BepInEx\plugins\
    echo 2. Copy %AUDIO_SOURCE% to Valheim\BepInEx\plugins\BagPipesTracks\
    echo.
    pause
    exit /b 0
)

REM Check if Valheim BepInEx plugins folder exists
if not exist "%VALHEIM_PLUGINS%" (
    echo WARNING: Valheim BepInEx plugins folder not found at:
    echo %VALHEIM_PLUGINS%
    echo.
    echo Possible solutions:
    echo 1. Install BepInEx: https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/
    echo 2. Set VALHEIM_PATH environment variable to your Valheim installation
    echo    Example: set VALHEIM_PATH=D:\Games\Valheim
    echo 3. Use /build-only flag to skip installation
    echo.
    echo Build completed but not installed.
    pause
    exit /b 0
)

REM Install the DLL
echo [3/4] Installing mod to Valheim...
copy /Y "%OUTPUT_DLL%" "%VALHEIM_PLUGINS%\SailingBagpipes.dll" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy DLL to Valheim plugins folder
    echo You may need to run this script as Administrator
    pause
    exit /b 1
)
echo    Copied: SailingBagpipes.dll

REM Install audio folder if not already there
if not exist "%VALHEIM_PLUGINS%\BagPipesTracks" (
    echo [4/4] Installing audio folder...
    xcopy "%AUDIO_SOURCE%" "%VALHEIM_PLUGINS%\BagPipesTracks\" /E /I /Y >nul
    if errorlevel 1 (
        echo WARNING: Failed to copy audio folder
    ) else (
        echo    Copied: BagPipesTracks folder
    )
) else (
    echo [4/4] Audio folder already exists (not overwriting)
)

echo.
echo ========================================
echo INSTALLATION COMPLETE!
echo ========================================
echo.
echo Installed to: %VALHEIM_PLUGINS%
echo.
echo IMPORTANT:
echo 1. Add MP3 files to: %VALHEIM_PLUGINS%\BagPipesTracks\
echo 2. Restart Valheim to load the updated mod
echo 3. Check logs for errors: BepInEx\LogOutput.log
echo.
echo See QUICKSTART.md for testing instructions.
echo.
pause
