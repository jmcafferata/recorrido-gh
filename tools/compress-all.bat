@echo off
REM Master script to compress all game assets
REM Requires: ffmpeg installed and in PATH

echo ╔═══════════════════════════════════════════╗
echo ║  DELTA+ Asset Compression Tool            ║
echo ║  Compressing images, videos, and audio    ║
echo ╚═══════════════════════════════════════════╝
echo.

REM Check if ffmpeg is available
where ffmpeg >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERROR: ffmpeg is not installed or not in PATH
    echo Please install ffmpeg from https://ffmpeg.org/download.html
    pause
    exit /b 1
)

echo ✓ ffmpeg found
echo.

REM Run compression scripts
call "%~dp0compress-images.bat"
echo.
echo ════════════════════════════════════════════
echo.

call "%~dp0compress-videos.bat"
echo.
echo ════════════════════════════════════════════
echo.

call "%~dp0compress-audio.bat"
echo.
echo ════════════════════════════════════════════
echo.

echo ✅ All asset compression complete!
echo.
echo You can now commit the optimized files to git.
pause
