@echo off
REM ============================================================================
REM Nexus Mods Package Builder - Slow Sailing Bagpipes
REM ============================================================================
REM This script creates a ready-to-upload Nexus Mods package (Vortex-compatible).
REM ============================================================================

echo.
echo ========================================
echo Nexus Mods Package Builder
echo ========================================
echo.

REM Configuration
set "PROJECT_ROOT=%~dp0"
set "BUILD_DLL=%PROJECT_ROOT%src\SlowSailingBagpipes\bin\Release\net472\SailingBagpipes.dll"
set "AUDIO_SOURCE=%PROJECT_ROOT%BagPipesTracks"
set "DIST_DIR=%PROJECT_ROOT%dist\nexusmods"
set "OUTPUT_ZIP=%PROJECT_ROOT%dist\SlowSailingBagpipes-NexusMods-v1.0.0.zip"
set "CHANGELOG=%PROJECT_ROOT%CHANGELOG.md"

REM Check if DLL exists
if not exist "%BUILD_DLL%" (
    echo ERROR: DLL not found at:
    echo %BUILD_DLL%
    echo.
    echo Please build the mod first:
    echo cd src\SlowSailingBagpipes
    echo dotnet build -c Release
    pause
    exit /b 1
)

echo [1/5] Cleaning previous package...
if exist "%OUTPUT_ZIP%" del "%OUTPUT_ZIP%"

echo [2/5] Copying DLL to package...
copy /Y "%BUILD_DLL%" "%DIST_DIR%\BepInEx\plugins\SailingBagpipes.dll" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy DLL
    pause
    exit /b 1
)

echo [3/5] Copying audio files...
if exist "%AUDIO_SOURCE%" (
    xcopy "%AUDIO_SOURCE%\*.*" "%DIST_DIR%\BepInEx\plugins\BagPipesTracks\" /E /I /Y /EXCLUDE:%~dp0.packageignore >nul 2>&1
    REM Copy the updated README from dist structure
    copy /Y "%PROJECT_ROOT%dist\thunderstore\plugins\BagPipesTracks\README.md" "%DIST_DIR%\BepInEx\plugins\BagPipesTracks\README.md" >nul 2>&1
) else (
    echo WARNING: Audio source folder not found at %AUDIO_SOURCE%
)

echo [4/5] Copying CHANGELOG...
if exist "%CHANGELOG%" (
    copy /Y "%CHANGELOG%" "%DIST_DIR%\CHANGELOG.txt" >nul
) else (
    echo WARNING: CHANGELOG.md not found
)

echo [5/5] Verifying package contents...
echo.
echo Package structure:
dir "%DIST_DIR%" /b /s
echo.

REM Check for required files
if not exist "%DIST_DIR%\README.txt" (
    echo ERROR: README.txt is missing!
    pause
    exit /b 1
)

if not exist "%DIST_DIR%\BepInEx\plugins\SailingBagpipes.dll" (
    echo ERROR: SailingBagpipes.dll is missing!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Package Ready!
echo ========================================
echo.
echo Location: %DIST_DIR%
echo.
echo Next steps:
echo 1. Review README.txt
echo 2. Verify BagPipesTracks folder contents
echo 3. Manually create ZIP from dist\nexusmods\ contents
echo 4. Upload to Nexus Mods
echo.
echo IMPORTANT: Nexus Mods requires you to ZIP the BepInEx folder
echo and README.txt together (the contents of dist\nexusmods\)
echo.
echo To create the ZIP:
echo 1. Navigate to dist\nexusmods\
echo 2. Select ALL files/folders (BepInEx/, README.txt, CHANGELOG.txt)
echo 3. Right-click -^> Send to -^> Compressed (zipped) folder
echo 4. Name it: SlowSailingBagpipes-v1.0.0.zip
echo.
echo When uploading to Nexus Mods:
echo - Category: Gameplay
echo - Requirements: List BepInEx as required
echo - Installation: Vortex compatible (automatic)
echo.
pause
