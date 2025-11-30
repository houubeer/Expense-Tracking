#!/bin/bash
# Asset Optimization Script for Expense Tracking App
# This script optimizes images and checks asset sizes

set -e

echo "🎨 Asset Optimization Script"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to project root
cd "$(dirname "$0")/.."

ASSETS_DIR="assets"
MAX_IMAGE_SIZE_KB=500
MAX_ICON_SIZE_KB=100

echo ""
echo "📊 Checking asset sizes..."
echo ""

# Function to check file size
check_file_size() {
    local file="$1"
    local max_size_kb="$2"
    local size_bytes=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
    local size_kb=$((size_bytes / 1024))
    
    if [ $size_kb -gt $max_size_kb ]; then
        echo -e "${RED}❌ Warning: $file is ${size_kb}KB (max: ${max_size_kb}KB)${NC}"
        return 1
    else
        echo -e "${GREEN}✓ $file is ${size_kb}KB (within ${max_size_kb}KB limit)${NC}"
        return 0
    fi
}

# Check image files
echo "Checking images..."
if [ -d "$ASSETS_DIR/images" ]; then
    for img in "$ASSETS_DIR/images"/*.{png,jpg,jpeg} 2>/dev/null; do
        [ -f "$img" ] && check_file_size "$img" $MAX_IMAGE_SIZE_KB
    done
fi

# Check icon files
echo ""
echo "Checking icons..."
if [ -d "$ASSETS_DIR/icons" ]; then
    for icon in "$ASSETS_DIR/icons"/*.{png,jpg,jpeg} 2>/dev/null; do
        [ -f "$icon" ] && check_file_size "$icon" $MAX_ICON_SIZE_KB
    done
fi

# Check logo files
echo ""
echo "Checking logos..."
if [ -d "$ASSETS_DIR/logos" ]; then
    for logo in "$ASSETS_DIR/logos"/*.{png,jpg,jpeg} 2>/dev/null; do
        [ -f "$logo" ] && check_file_size "$logo" $MAX_IMAGE_SIZE_KB
    done
fi

echo ""
echo "📦 Total asset directory sizes:"
echo "------------------------------"
if [ -d "$ASSETS_DIR/images" ]; then
    images_size=$(du -sh "$ASSETS_DIR/images" 2>/dev/null | cut -f1)
    echo "Images: $images_size"
fi
if [ -d "$ASSETS_DIR/icons" ]; then
    icons_size=$(du -sh "$ASSETS_DIR/icons" 2>/dev/null | cut -f1)
    echo "Icons: $icons_size"
fi
if [ -d "$ASSETS_DIR/logos" ]; then
    logos_size=$(du -sh "$ASSETS_DIR/logos" 2>/dev/null | cut -f1)
    echo "Logos: $logos_size"
fi

total_size=$(du -sh "$ASSETS_DIR" 2>/dev/null | cut -f1)
echo "------------------------------"
echo "Total: $total_size"

echo ""
echo "💡 Optimization Tips:"
echo "  • Use SVG for logos and icons when possible"
echo "  • Compress PNG images with tools like pngquant or tinypng"
echo "  • Use WebP format for better compression (Flutter supports it)"
echo "  • Consider using Flutter's asset variants for different densities"
echo ""
echo "🔧 Recommended Tools:"
echo "  • ImageMagick: convert image.png -resize 50% -quality 85 image_optimized.png"
echo "  • OptiPNG: optipng -o7 image.png"
echo "  • SVGO: svgo logo.svg"
echo ""
echo -e "${GREEN}✅ Asset check complete!${NC}"
