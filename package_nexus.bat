@echo off
REM ============================================================================
REM Nexus Mods Package Builder - Slow Sailing Bagpipes
REM ============================================================================
REM Creates a ready-to-test and ready-to-upload ZIP with BepInEx-compatible
REM folder structure at the root of the archive.
REM ============================================================================

echo.
echo ========================================
echo Nexus Mods Package Builder
echo ========================================
echo.

set "VERSION=1.0.5"
set "PROJECT_ROOT=%~dp0"
set "BUILD_DLL=%PROJECT_ROOT%src\SlowSailingBagpipes\bin\Release\net472\SailingBagpipes.dll"
set "AUDIO_SOURCE=%PROJECT_ROOT%BagPipesTracks"
set "DIST_DIR=%PROJECT_ROOT%dist\nexusmods"
set "PLUGIN_DIR=%DIST_DIR%\BepInEx\plugins"
set "OUTPUT_ZIP=%PROJECT_ROOT%dist\SlowSailingBagpipes-NexusMods-v%VERSION%.zip"
set "CHANGELOG=%PROJECT_ROOT%CHANGELOG.md"

if not exist "%BUILD_DLL%" (
    echo ERROR: DLL not found at:
    echo %BUILD_DLL%
    echo.
    echo Build first:
    echo   cd src\SlowSailingBagpipes
    echo   dotnet build -c Release
    pause
    exit /b 1
)

echo [1/6] Cleaning package staging area...
if exist "%OUTPUT_ZIP%" del "%OUTPUT_ZIP%"
if exist "%PLUGIN_DIR%\SailingBagpipes.dll" del "%PLUGIN_DIR%\SailingBagpipes.dll"
if exist "%PLUGIN_DIR%\BagPipesTracks" rmdir /S /Q "%PLUGIN_DIR%\BagPipesTracks"
if exist "%DIST_DIR%\CHANGELOG.txt" del "%DIST_DIR%\CHANGELOG.txt"

if not exist "%PLUGIN_DIR%" mkdir "%PLUGIN_DIR%"

echo [2/6] Copying DLL...
copy /Y "%BUILD_DLL%" "%PLUGIN_DIR%\SailingBagpipes.dll" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy DLL
    pause
    exit /b 1
)

echo [3/6] Copying BagPipesTracks...
if exist "%AUDIO_SOURCE%" (
    xcopy "%AUDIO_SOURCE%\*" "%PLUGIN_DIR%\BagPipesTracks\" /E /I /Y >nul
    if errorlevel 1 (
        echo ERROR: Failed to copy BagPipesTracks
        pause
        exit /b 1
    )
) else (
    echo ERROR: Audio source folder not found at %AUDIO_SOURCE%
    pause
    exit /b 1
)

echo [4/6] Copying changelog...
if exist "%CHANGELOG%" (
    copy /Y "%CHANGELOG%" "%DIST_DIR%\CHANGELOG.txt" >nul
) else (
    echo WARNING: CHANGELOG.md not found
)

echo [5/6] Verifying staged package...
if not exist "%DIST_DIR%\README.txt" (
    echo ERROR: README.txt is missing from %DIST_DIR%
    pause
    exit /b 1
)

if not exist "%PLUGIN_DIR%\SailingBagpipes.dll" (
    echo ERROR: SailingBagpipes.dll is missing after copy
    pause
    exit /b 1
)

if not exist "%PLUGIN_DIR%\BagPipesTracks" (
    echo ERROR: BagPipesTracks folder is missing after copy
    pause
    exit /b 1
)

echo [6/6] Creating ZIP package...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Compress-Archive -Path @('%DIST_DIR%\BepInEx','%DIST_DIR%\README.txt','%DIST_DIR%\CHANGELOG.txt') -DestinationPath '%OUTPUT_ZIP%' -Force"
if errorlevel 1 (
    echo ERROR: Failed to create ZIP package
    pause
    exit /b 1
)

echo.
echo ========================================
echo Nexus Package Ready
echo ========================================
echo.
echo ZIP: %OUTPUT_ZIP%
echo Staging folder: %DIST_DIR%
echo.
echo For local testing, extract the ZIP and merge its root BepInEx folder into:
echo   [Valheim]\BepInEx\
echo or install the ZIP through Vortex.
echo.
pause
