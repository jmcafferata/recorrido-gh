#!/bin/bash
# Compress all JPG and PNG images in game-assets and assets folders
# Requires: ffmpeg or imagemagick installed

QUALITY=75  # JPG quality (0-100, lower = smaller file)
PNG_QUALITY=90  # PNG compression level

echo "🖼️  Starting image compression..."
echo "Quality: JPG=$QUALITY, PNG=$PNG_QUALITY"
echo ""

# Function to compress a single image
compress_image() {
    local file="$1"
    local ext="${file##*.}"
    local temp_file="${file}.tmp.${ext}"
    
    if [[ "$ext" == "jpg" || "$ext" == "jpeg" ]]; then
        # Compress JPG with ffmpeg
        ffmpeg -i "$file" -q:v $QUALITY -y "$temp_file" 2>/dev/null
        
        # Check if new file is smaller
        if [ -f "$temp_file" ]; then
            original_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            new_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null)
            
            if [ "$new_size" -lt "$original_size" ]; then
                saved=$((original_size - new_size))
                saved_mb=$(echo "scale=2; $saved / 1048576" | bc)
                echo "✓ $(basename "$file"): $saved_mb MB saved"
                mv "$temp_file" "$file"
            else
                rm "$temp_file"
            fi
        fi
        
    elif [[ "$ext" == "png" ]]; then
        # Compress PNG with ffmpeg
        ffmpeg -i "$file" -compression_level 9 -y "$temp_file" 2>/dev/null
        
        if [ -f "$temp_file" ]; then
            original_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            new_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null)
            
            if [ "$new_size" -lt "$original_size" ]; then
                saved=$((original_size - new_size))
                saved_mb=$(echo "scale=2; $saved / 1048576" | bc)
                echo "✓ $(basename "$file"): $saved_mb MB saved"
                mv "$temp_file" "$file"
            else
                rm "$temp_file"
            fi
        fi
    fi
}

# Export function for use with find
export -f compress_image
export QUALITY
export PNG_QUALITY

# Find and compress all images
echo "Compressing JPG files..."
find ./game-assets ./assets -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -exec bash -c 'compress_image "$0"' {} \;

echo ""
echo "Compressing PNG files..."
find ./game-assets ./assets -type f -iname "*.png" -exec bash -c 'compress_image "$0"' {} \;

echo ""
echo "✅ Image compression complete!"
