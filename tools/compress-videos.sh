#!/bin/bash
# Compress all WEBM and MP4 videos using ffmpeg
# WEBM: VP9 codec with CRF 35 (good quality/size balance)
# MP4: H.264 codec with CRF 28

CRF_VP9=35
CRF_H264=28

echo "🎬 Starting video compression..."
echo "Settings: WEBM CRF=$CRF_VP9, MP4 CRF=$CRF_H264"
echo "This may take a while..."
echo ""

compress_webm() {
    local file="$1"
    local temp="${file%.webm}.tmp.webm"
    
    echo "Processing: $(basename "$file")..."
    
    # Check if video has alpha channel
    if ffmpeg -i "$file" 2>&1 | grep -q "yuva"; then
        # Video has alpha channel - preserve it with auto-alt-ref=0
        ffmpeg -i "$file" -c:v libvpx-vp9 -crf $CRF_VP9 -b:v 0 -pix_fmt yuva420p -auto-alt-ref 0 -c:a libopus -b:a 96k -y "$temp" 2>/dev/null
    else
        # Standard video without alpha
        ffmpeg -i "$file" -c:v libvpx-vp9 -crf $CRF_VP9 -b:v 0 -c:a libopus -b:a 96k -y "$temp" 2>/dev/null
    fi
    
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

compress_mp4() {
    local file="$1"
    local temp="${file%.mp4}.tmp.mp4"
    
    echo "Processing: $(basename "$file")..."
    ffmpeg -i "$file" -c:v libx264 -crf $CRF_H264 -preset medium -c:a aac -b:a 128k -y "$temp" 2>/dev/null
    
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

export -f compress_webm
export -f compress_mp4
export CRF_VP9
export CRF_H264

# Find and compress all videos
echo "Compressing WEBM files..."
find ./game-assets ./assets -type f -iname "*.webm" -exec bash -c 'compress_webm "$0"' {} \;

echo ""
echo "Compressing MP4 files..."
find ./game-assets ./assets -type f -iname "*.mp4" -exec bash -c 'compress_mp4 "$0"' {} \;

echo ""
echo "✅ Video compression complete!"
