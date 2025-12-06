@echo off
REM ============================================================================
REM Thunderstore Package Builder - Slow Sailing Bagpipes
REM ============================================================================
REM This script creates a ready-to-upload Thunderstore package.
REM ============================================================================

echo.
echo ========================================
echo Thunderstore Package Builder
echo ========================================
echo.

REM Configuration
set "PROJECT_ROOT=%~dp0"
set "BUILD_DLL=%PROJECT_ROOT%src\SlowSailingBagpipes\bin\Release\net472\SailingBagpipes.dll"
set "AUDIO_SOURCE=%PROJECT_ROOT%BagPipesTracks"
set "DIST_DIR=%PROJECT_ROOT%dist\thunderstore"
set "OUTPUT_ZIP=%PROJECT_ROOT%dist\SlowSailingBagpipes-Thunderstore-v1.0.0.zip"
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
copy /Y "%BUILD_DLL%" "%DIST_DIR%\plugins\SailingBagpipes.dll" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy DLL
    pause
    exit /b 1
)

echo [3/5] Copying audio files...
if exist "%AUDIO_SOURCE%" (
    xcopy "%AUDIO_SOURCE%\*.*" "%DIST_DIR%\plugins\BagPipesTracks\" /E /I /Y /EXCLUDE:%~dp0.packageignore >nul 2>&1
    if errorlevel 1 (
        echo WARNING: No audio files copied (this is OK if using placeholder)
    )
) else (
    echo WARNING: Audio source folder not found at %AUDIO_SOURCE%
)

echo [4/5] Copying CHANGELOG.md...
if exist "%CHANGELOG%" (
    copy /Y "%CHANGELOG%" "%DIST_DIR%\CHANGELOG.md" >nul
) else (
    echo WARNING: CHANGELOG.md not found
)

echo [5/5] Verifying package contents...
echo.
echo Package structure:
dir "%DIST_DIR%" /b /s
echo.

REM Check for required files
if not exist "%DIST_DIR%\manifest.json" (
    echo ERROR: manifest.json is missing!
    pause
    exit /b 1
)

if not exist "%DIST_DIR%\README.md" (
    echo ERROR: README.md is missing!
    pause
    exit /b 1
)

if not exist "%DIST_DIR%\icon.png" (
    if exist "%DIST_DIR%\icon.png.PLACEHOLDER" (
        echo.
        echo ========================================
        echo WARNING: icon.png is still a placeholder!
        echo ========================================
        echo.
        echo You need to create a 256x256 PNG icon:
        echo 1. Create or obtain a 256x256 PNG image
        echo 2. Rename icon.png.PLACEHOLDER to icon.png
        echo 3. Replace with your actual icon
        echo.
        echo Package will be incomplete without icon.png
        echo.
        pause
    ) else (
        echo ERROR: icon.png is missing!
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo Package Ready!
echo ========================================
echo.
echo Location: %DIST_DIR%
echo.
echo Next steps:
echo 1. Verify icon.png exists (256x256 PNG)
echo 2. Review README.md
echo 3. Check manifest.json version
echo 4. Manually create ZIP from dist\thunderstore\ contents
echo 5. Upload to Thunderstore: https://thunderstore.io/
echo.
echo IMPORTANT: Thunderstore requires you to ZIP the contents INSIDE
echo the thunderstore folder, not the folder itself!
echo.
echo To create the ZIP:
echo 1. Navigate to dist\thunderstore\
echo 2. Select ALL files/folders (manifest.json, README.md, icon.png, plugins/, CHANGELOG.md)
echo 3. Right-click -^> Send to -^> Compressed (zipped) folder
echo 4. Name it: SlowSailingBagpipes-v1.0.0.zip
echo.
pause
