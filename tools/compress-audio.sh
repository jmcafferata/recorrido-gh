#!/bin/bash
# Compress all MP3 and M4A audio files using ffmpeg
# MP3: 128kbps (good quality for game audio)
# M4A/AAC: 96kbps (better compression than MP3)

MP3_BITRATE=128k
AAC_BITRATE=96k

echo "🎵 Starting audio compression..."
echo "Settings: MP3=$MP3_BITRATE, AAC=$AAC_BITRATE"
echo ""

compress_mp3() {
    local file="$1"
    local temp="${file%.mp3}.tmp.mp3"
    
    echo "Processing: $(basename "$file")..."
    ffmpeg -i "$file" -c:a libmp3lame -b:a $MP3_BITRATE -y "$temp" 2>/dev/null
    
    if [ -f "$temp" ]; then
        original_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        new_size=$(stat -f%z "$temp" 2>/dev/null || stat -c%s "$temp" 2>/dev/null)
        
        if [ "$new_size" -lt "$original_size" ]; then
            saved=$((original_size - new_size))
            saved_mb=$(echo "scale=2; $saved / 1048576" | bc)
            echo "✓ $(basename "$file"): $saved_mb MB saved"
            mv "$temp" "$file"
        else
            echo "→ $(basename "$file"): No improvement"
            rm "$temp"
        fi
    fi
}

compress_m4a() {
    local file="$1"
    local temp="${file%.m4a}.tmp.m4a"
    
    echo "Processing: $(basename "$file")..."
    ffmpeg -i "$file" -c:a aac -b:a $AAC_BITRATE -y "$temp" 2>/dev/null
    
    if [ -f "$temp" ]; then
        original_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        new_size=$(stat -f%z "$temp" 2>/dev/null || stat -c%s "$temp" 2>/dev/null)
        
        if [ "$new_size" -lt "$original_size" ]; then
            saved=$((original_size - new_size))
            saved_mb=$(echo "scale=2; $saved / 1048576" | bc)
            echo "✓ $(basename "$file"): $saved_mb MB saved"
            mv "$temp" "$file"
        else
            echo "→ $(basename "$file"): No improvement"
            rm "$temp"
        fi
    fi
}

export -f compress_mp3
export -f compress_m4a
export MP3_BITRATE
export AAC_BITRATE

# Find and compress all audio
echo "Compressing MP3 files..."
find ./game-assets ./assets -type f -iname "*.mp3" -exec bash -c 'compress_mp3 "$0"' {} \;

echo ""
echo "Compressing M4A files..."
find ./game-assets ./assets -type f -iname "*.m4a" -exec bash -c 'compress_m4a "$0"' {} \;

echo ""
echo "✅ Audio compression complete!"
