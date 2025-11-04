@echo off
REM Compress all JPG and PNG images in game-assets and assets folders
REM Requires: ffmpeg in PATH

setlocal enabledelayedexpansion

set QUALITY=75
set PNG_QUALITY=90
set BACKUP_DIR=..\backups-originals

echo 🖼️  Starting image compression...
echo Quality: JPG=%QUALITY%, PNG=%PNG_QUALITY%
echo Backups will be saved to: %BACKUP_DIR%
echo.

REM Create backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
echo ✓ Backup directory ready
echo.

for /r "game-assets" %%F in (*.jpg *.jpeg) do (
    call :compress_jpg "%%F"
)

for /r "assets" %%F in (*.jpg *.jpeg) do (
    call :compress_jpg "%%F"
)

for /r "game-assets" %%F in (*.png) do (
    call :compress_png "%%F"
)

for /r "assets" %%F in (*.png) do (
    call :compress_png "%%F"
)

echo.
echo ✅ Image compression complete!
goto :eof

:compress_jpg
    set "file=%~1"
    set "temp=%~1.tmp%~x1"
    set "relpath=%~1"
    set "relpath=!relpath:%CD%\=!"
    set "backup=%BACKUP_DIR%\!relpath!"
    
    ffmpeg -i "%file%" -q:v %QUALITY% -y "%temp%" >nul 2>&1
    
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
            del "%temp%"
        )
    )
    goto :eof

:compress_png
    set "file=%~1"
    set "temp=%~1.tmp%~x1"
    set "relpath=%~1"
    set "relpath=!relpath:%CD%\=!"
    set "backup=%BACKUP_DIR%\!relpath!"
    
    ffmpeg -i "%file%" -compression_level 9 -y "%temp%" >nul 2>&1
    
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
            del "%temp%"
        )
    )
    goto :eof
