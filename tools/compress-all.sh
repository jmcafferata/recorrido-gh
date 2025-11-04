#!/bin/bash
# Master script to compress all game assets
# Requires: ffmpeg installed

echo "╔═══════════════════════════════════════════╗"
echo "║  DELTA+ Asset Compression Tool            ║"
echo "║  Compressing images, videos, and audio    ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Check if ffmpeg is available
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ERROR: ffmpeg is not installed or not in PATH"
    echo "Please install ffmpeg:"
    echo "  - macOS: brew install ffmpeg"
    echo "  - Ubuntu/Debian: sudo apt install ffmpeg"
    echo "  - Other: https://ffmpeg.org/download.html"
    exit 1
fi

echo "✓ ffmpeg found"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run compression scripts
bash "$SCRIPT_DIR/compress-images.sh"
echo ""
echo "════════════════════════════════════════════"
echo ""

bash "$SCRIPT_DIR/compress-videos.sh"
echo ""
echo "════════════════════════════════════════════"
echo ""

bash "$SCRIPT_DIR/compress-audio.sh"
echo ""
echo "════════════════════════════════════════════"
echo ""

echo "✅ All asset compression complete!"
echo ""
echo "You can now commit the optimized files to git."
