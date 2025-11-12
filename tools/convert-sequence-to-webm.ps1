# Convert PNG sequence to WebM with alpha channel
# Requires FFmpeg installed and in PATH

$inputDir = "C:\Users\jmcaf\Desktop\recorrido-gh\game-assets\recorrido\interfaz\loading-text-box-animation"
$outputFile = "C:\Users\jmcaf\Desktop\recorrido-gh\game-assets\recorrido\interfaz\loading-text-box-animation.webm"
$fps = 30

Write-Host "Converting PNG sequence to WebM with alpha..." -ForegroundColor Cyan
Write-Host "Input: $inputDir" -ForegroundColor Gray
Write-Host "Output: $outputFile" -ForegroundColor Gray
Write-Host "FPS: $fps" -ForegroundColor Gray

# Check if ffmpeg is available
try {
    $ffmpegVersion = ffmpeg -version 2>&1 | Select-Object -First 1
    Write-Host "FFmpeg found: $ffmpegVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: FFmpeg not found in PATH" -ForegroundColor Red
    Write-Host "Please install FFmpeg from https://ffmpeg.org/download.html" -ForegroundColor Yellow
    exit 1
}

# Build FFmpeg command
# Using VP9 codec with alpha channel support
# -c:v libvpx-vp9: VP9 codec (supports alpha)
# -pix_fmt yuva420p: Pixel format with alpha channel
# -auto-alt-ref 0: Disable alt reference frames (required for alpha)
# -crf 20: Quality (lower = better, 15-25 recommended)
# -b:v 0: VBR mode

$ffmpegArgs = @(
    "-framerate", $fps,
    "-i", "`"$inputDir\BASE data especie_%05d.png`"",
    "-c:v", "libvpx-vp9",
    "-pix_fmt", "yuva420p",
    "-auto-alt-ref", "0",
    "-crf", "20",
    "-b:v", "0",
    "-y",
    "`"$outputFile`""
)

$ffmpegCommand = "ffmpeg " + ($ffmpegArgs -join " ")

Write-Host "`nRunning FFmpeg..." -ForegroundColor Cyan
Write-Host $ffmpegCommand -ForegroundColor Gray

try {
    Invoke-Expression $ffmpegCommand
    
    if (Test-Path $outputFile) {
        $fileSize = (Get-Item $outputFile).Length / 1MB
        Write-Host "`nSuccess! Created: $outputFile" -ForegroundColor Green
        Write-Host "File size: $($fileSize.ToString('0.00')) MB" -ForegroundColor Green
        
        # Compare with original PNGs size
        $pngFiles = Get-ChildItem -Path $inputDir -Filter "*.png"
        $totalPngSize = ($pngFiles | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "Original PNGs total size: $($totalPngSize.ToString('0.00')) MB" -ForegroundColor Gray
        $savings = (($totalPngSize - $fileSize) / $totalPngSize) * 100
        Write-Host "Compression savings: $($savings.ToString('0.00'))%" -ForegroundColor Green
    } else {
        Write-Host "`nERROR: Output file not created" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "`nERROR: FFmpeg failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "`nDone!" -ForegroundColor Cyan
