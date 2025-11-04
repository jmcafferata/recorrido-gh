@echo off
REM Compress all WEBM and MP4 videos using ffmpeg
REM WEBM: VP9 codec with CRF 35 (good quality/size balance)
REM MP4: H.264 NVENC codec with CRF 28 (GPU accelerated)

setlocal enabledelayedexpansion

set CRF_VP9=30
set CRF_VP9_ALPHA=25
set CRF_H264=28
set BACKUP_DIR=..\backups-originals

echo 🎬 Starting video compression...
echo Settings: WEBM CRF=%CRF_VP9% (Alpha: %CRF_VP9_ALPHA%), MP4 CRF=%CRF_H264%
echo Backups will be saved to: %BACKUP_DIR%
echo This may take a while...
echo.

REM Create backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
echo ✓ Backup directory ready
echo.

REM Change to parent directory to find game-assets and assets folders
cd ..

for /r "game-assets" %%F in (*.webm) do (
    call :compress_webm "%%F"
)

for /r "assets" %%F in (*.webm) do (
    call :compress_webm "%%F"
)

for /r "game-assets" %%F in (*.mp4) do (
    call :compress_mp4 "%%F"
)

for /r "assets" %%F in (*.mp4) do (
    call :compress_mp4 "%%F"
)

echo.
echo ✅ Video compression complete!
goto :eof

:compress_webm
    set "file=%~1"
    set "temp=%~dpn1.tmp.webm"
    set "relpath=%~1"
    set "relpath=!relpath:%CD%\=!"
    set "backup=%BACKUP_DIR%\!relpath!"
    
    echo Processing: %~nx1...
    REM Check if video has alpha channel
    ffmpeg -i "%file%" 2>&1 | findstr /C:"alpha_mode" >nul
    if %ERRORLEVEL% EQU 0 (
        REM Video has alpha channel - use better quality settings
        echo   [Alpha channel detected - using CRF %CRF_VP9_ALPHA%]
        ffmpeg -i "%file%" -c:v libvpx-vp9 -crf %CRF_VP9_ALPHA% -b:v 0 -pix_fmt yuva420p -auto-alt-ref 0 -c:a libopus -b:a 96k -y "%temp%"
    ) else (
        REM Standard video without alpha
        ffmpeg -i "%file%" -c:v libvpx-vp9 -crf %CRF_VP9% -b:v 0 -c:a libopus -b:a 96k -y "%temp%"
    )
    
    if exist "%temp%" (
        for %%A in ("%file%") do set "size1=%%~zA"
        for %%A in ("%temp%") do set "size2=%%~zA"
        
        if !size2! LSS !size1! (
            REM Create backup directory structure and backup original
            for %%B in ("!backup!") do if not exist "%%~dpB" mkdir "%%~dpB"
            copy /y "%file%" "!backup!" >nul 2>&1
            
            set /a "saved=!size1! - !size2!"
            set /a "saved_mb=!saved! / 1048576"
            echo ✓ %~nx1: !saved_mb! MB saved
            move /y "%temp%" "%file%" >nul
        ) else (
            echo → %~nx1: No improvement
            del "%temp%"
        )
    )
    goto :eof

:compress_mp4
    set "file=%~1"
    set "temp=%~dpn1.tmp.mp4"
    set "relpath=%~1"
    set "relpath=!relpath:%CD%\=!"
    set "backup=%BACKUP_DIR%\!relpath!"
    
    echo Processing: %~nx1...
    echo   [Using NVIDIA GPU acceleration - h264_nvenc]
    ffmpeg -i "%file%" -c:v h264_nvenc -cq %CRF_H264% -preset p4 -c:a aac -b:a 128k -y "%temp%"
    
    if exist "%temp%" (
        for %%A in ("%file%") do set "size1=%%~zA"
        for %%A in ("%temp%") do set "size2=%%~zA"
        
        if !size2! LSS !size1! (
            REM Create backup directory structure and backup original
            for %%B in ("!backup!") do if not exist "%%~dpB" mkdir "%%~dpB"
            copy /y "%file%" "!backup!" >nul 2>&1
            
            set /a "saved=!size1! - !size2!"
            set /a "saved_mb=!saved! / 1048576"
            echo ✓ %~nx1: !saved_mb! MB saved
            move /y "%temp%" "%file%" >nul
        ) else (
            echo → %~nx1: No improvement
            del "%temp%"
        )
    )
    goto :eof
