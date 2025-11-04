@echo off
REM Compress all MP3 and M4A audio files using ffmpeg
REM MP3: 128kbps (good quality for game audio)
REM M4A/AAC: 96kbps (better compression than MP3)

setlocal enabledelayedexpansion

set MP3_BITRATE=128k
set AAC_BITRATE=96k
set BACKUP_DIR=..\backups-originals

echo 🎵 Starting audio compression...
echo Settings: MP3=%MP3_BITRATE%, AAC=%AAC_BITRATE%
echo Backups will be saved to: %BACKUP_DIR%
echo.

REM Create backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
echo ✓ Backup directory ready
echo.

for /r "game-assets" %%F in (*.mp3) do (
    call :compress_mp3 "%%F"
)

for /r "assets" %%F in (*.mp3) do (
    call :compress_mp3 "%%F"
)

for /r "game-assets" %%F in (*.m4a) do (
    call :compress_m4a "%%F"
)

for /r "assets" %%F in (*.m4a) do (
    call :compress_m4a "%%F"
)

echo.
echo ✅ Audio compression complete!
goto :eof

:compress_mp3
    set "file=%~1"
    set "temp=%~dpn1.tmp.mp3"
    set "relpath=%~1"
    set "relpath=!relpath:%CD%\=!"
    set "backup=%BACKUP_DIR%\!relpath!"
    
    echo Processing: %~nx1...
    ffmpeg -i "%file%" -c:a libmp3lame -b:a %MP3_BITRATE% -y "%temp%" >nul 2>&1
    
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

:compress_m4a
    set "file=%~1"
    set "temp=%~dpn1.tmp.m4a"
    set "relpath=%~1"
    set "relpath=!relpath:%CD%\=!"
    set "backup=%BACKUP_DIR%\!relpath!"
    
    echo Processing: %~nx1...
    ffmpeg -i "%file%" -c:a aac -b:a %AAC_BITRATE% -y "%temp%" >nul 2>&1
    
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
