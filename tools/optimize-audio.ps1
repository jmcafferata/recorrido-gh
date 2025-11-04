# Audio Optimization Script for Game Assets
# Compresses MP3 files to reduce file size while maintaining acceptable quality
# Requires FFmpeg to be installed

$MP3_BITRATE = "128k"  # Good quality for game audio
$SAMPLE_RATE = "44100" # Standard audio quality

Write-Host "🎵 Starting audio compression..." -ForegroundColor Cyan
Write-Host "Settings: Bitrate=$MP3_BITRATE, Sample Rate=$SAMPLE_RATE" -ForegroundColor Gray
Write-Host ""

# Check if ffmpeg is available
try {
    $null = Get-Command ffmpeg -ErrorAction Stop
} catch {
    Write-Host "❌ FFmpeg not found. Please install FFmpeg first." -ForegroundColor Red
    Write-Host "Download from: https://ffmpeg.org/download.html" -ForegroundColor Yellow
    exit 1
}

$totalSaved = 0
$processedCount = 0

function Compress-MP3 {
    param(
        [string]$FilePath
    )
    
    $file = Get-Item $FilePath
    $tempFile = Join-Path $file.DirectoryName "$($file.BaseName).tmp.mp3"
    
    Write-Host "Processing: $($file.Name)..." -ForegroundColor Yellow
    
    # Compress with FFmpeg
    & ffmpeg -i "$FilePath" -c:a libmp3lame -b:a $MP3_BITRATE -ar $SAMPLE_RATE -y "$tempFile" 2>$null
    
    if (Test-Path $tempFile) {
        $originalSize = $file.Length
        $newSize = (Get-Item $tempFile).Length
        
        if ($newSize -lt $originalSize) {
            $saved = $originalSize - $newSize
            $savedMB = [math]::Round($saved / 1MB, 2)
            $reduction = [math]::Round(($saved / $originalSize) * 100, 1)
            
            Write-Host "  ✓ Saved: $savedMB MB ($reduction% reduction)" -ForegroundColor Green
            
            # Replace original with compressed version
            Move-Item -Path $tempFile -Destination $FilePath -Force
            
            return $saved
        } else {
            Write-Host "  → No improvement, keeping original" -ForegroundColor Gray
            Remove-Item $tempFile -Force
            return 0
        }
    } else {
        Write-Host "  ❌ Failed to compress" -ForegroundColor Red
        return 0
    }
}

# Find all MP3 files in game-assets
$gameAssetsPath = Join-Path (Split-Path $PSScriptRoot -Parent) "game-assets"
$mp3Files = Get-ChildItem -Path $gameAssetsPath -Recurse -Include *.mp3 | Where-Object { -not $_.Name.EndsWith(".tmp.mp3") }

Write-Host "Found $($mp3Files.Count) MP3 files to process" -ForegroundColor Cyan
Write-Host ""

foreach ($file in $mp3Files) {
    $saved = Compress-MP3 -FilePath $file.FullName
    $totalSaved += $saved
    $processedCount++
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ Compression Complete!" -ForegroundColor Green
Write-Host "Files processed: $processedCount" -ForegroundColor White
Write-Host "Total space saved: $([math]::Round($totalSaved / 1MB, 2)) MB" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
