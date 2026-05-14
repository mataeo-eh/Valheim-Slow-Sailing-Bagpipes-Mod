@echo off
REM ============================================================================
REM Thunderstore Package Builder - Slow Sailing Bagpipes
REM ============================================================================
REM Creates a ready-to-upload Thunderstore ZIP. This requires a real icon.png
REM at dist\thunderstore\icon.png.
REM ============================================================================

echo.
echo ========================================
echo Thunderstore Package Builder
echo ========================================
echo.

set "VERSION=1.0.5"
set "PROJECT_ROOT=%~dp0"
set "BUILD_DLL=%PROJECT_ROOT%src\SlowSailingBagpipes\bin\Release\net472\SailingBagpipes.dll"
set "AUDIO_SOURCE=%PROJECT_ROOT%BagPipesTracks"
set "DIST_DIR=%PROJECT_ROOT%dist\thunderstore"
set "PLUGIN_DIR=%DIST_DIR%\plugins"
set "OUTPUT_ZIP=%PROJECT_ROOT%dist\SlowSailingBagpipes-Thunderstore-v%VERSION%.zip"
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

echo [1/7] Cleaning package staging area...
if exist "%OUTPUT_ZIP%" del "%OUTPUT_ZIP%"
if exist "%PLUGIN_DIR%\SailingBagpipes.dll" del "%PLUGIN_DIR%\SailingBagpipes.dll"
if exist "%PLUGIN_DIR%\BagPipesTracks" rmdir /S /Q "%PLUGIN_DIR%\BagPipesTracks"
if exist "%DIST_DIR%\CHANGELOG.md" del "%DIST_DIR%\CHANGELOG.md"

if not exist "%PLUGIN_DIR%" mkdir "%PLUGIN_DIR%"

echo [2/7] Verifying Thunderstore metadata...
if not exist "%DIST_DIR%\manifest.json" (
    echo ERROR: manifest.json is missing from %DIST_DIR%
    pause
    exit /b 1
)

if not exist "%DIST_DIR%\README.md" (
    echo ERROR: README.md is missing from %DIST_DIR%
    pause
    exit /b 1
)

if not exist "%DIST_DIR%\icon.png" (
    echo ERROR: dist\thunderstore\icon.png is required for a real Thunderstore package.
    if exist "%DIST_DIR%\icon.png.PLACEHOLDER" (
        echo A placeholder file exists. Replace it with an actual 256x256 PNG named icon.png.
    )
    pause
    exit /b 1
)

echo [3/7] Copying DLL...
copy /Y "%BUILD_DLL%" "%PLUGIN_DIR%\SailingBagpipes.dll" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy DLL
    pause
    exit /b 1
)

echo [4/7] Copying BagPipesTracks...
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

echo [5/7] Copying changelog...
if exist "%CHANGELOG%" (
    copy /Y "%CHANGELOG%" "%DIST_DIR%\CHANGELOG.md" >nul
) else (
    echo WARNING: CHANGELOG.md not found
)

echo [6/7] Verifying staged package...
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

echo [7/7] Creating ZIP package...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Compress-Archive -Path @('%DIST_DIR%\manifest.json','%DIST_DIR%\README.md','%DIST_DIR%\icon.png','%DIST_DIR%\CHANGELOG.md','%DIST_DIR%\plugins') -DestinationPath '%OUTPUT_ZIP%' -Force"
if errorlevel 1 (
    echo ERROR: Failed to create ZIP package
    pause
    exit /b 1
)

echo.
echo ========================================
echo Thunderstore Package Ready
echo ========================================
echo.
echo ZIP: %OUTPUT_ZIP%
echo Staging folder: %DIST_DIR%
echo.
echo This ZIP can be uploaded directly to Thunderstore.
echo.
pause
