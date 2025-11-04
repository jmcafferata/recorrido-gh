@echo off
REM Compress all WEBM and MP4 videos using ffmpeg
REM WEBM: VP9 codec with CRF 35 (good quality/size balance)
REM MP4: H.264 codec with CRF 28

setlocal enabledelayedexpansion

set CRF_VP9=35
set CRF_H264=28
set BACKUP_DIR=..\backups-originals

echo 🎬 Starting video compression...
echo Settings: WEBM CRF=%CRF_VP9%, MP4 CRF=%CRF_H264%
echo Backups will be saved to: %BACKUP_DIR%
echo This may take a while...
echo.

REM Create backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
echo ✓ Backup directory ready
echo.

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
    ffmpeg -i "%file%" -c:v libvpx-vp9 -crf %CRF_VP9% -b:v 0 -c:a libopus -b:a 96k -y "%temp%" >nul 2>&1
    
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
    ffmpeg -i "%file%" -c:v libx264 -crf %CRF_H264% -preset medium -c:a aac -b:a 128k -y "%temp%" >nul 2>&1
    
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
