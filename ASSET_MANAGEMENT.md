# Asset Management Guide

This document outlines the asset management strategy and optimization practices for the Expense Tracking Desktop App.

## 📁 Asset Structure

```
assets/
├── icons/          # Application icons
│   └── app_icon.png (256x256, <100KB)
├── images/         # UI images and graphics
│   └── raseedi_logo.png
└── logos/          # Brand logos and variants
    ├── .gitignore
    ├── raseedi_logo.png
    ├── app_logo.svg (vector, light theme)
    └── app_logo_dark.svg (vector, dark theme)
```

## 🎨 Asset Guidelines

### Icons

- **Format**: PNG for raster, SVG for vector
- **Size**: 256x256 for app icons
- **Max File Size**: 100KB per icon
- **Naming**: `snake_case` (e.g., `app_icon.png`)

### Images

- **Format**: PNG, JPG, or WebP
- **Max File Size**: 500KB per image
- **Optimization**: Always compress before committing
- **Naming**: Descriptive `snake_case` (e.g., `dashboard_banner.png`)

### Logos

- **Format**: SVG preferred (scalable), PNG fallback
- **Variants**: Light and dark theme versions
- **Max File Size**: 200KB for PNG, unlimited for SVG
- **Naming**: `app_logo.svg`, `app_logo_dark.svg`

## 🔧 Asset Optimization

### Automatic Optimization Script

Run the optimization checker:

```bash
bash scripts/optimize_assets.sh
```

This script:

- ✅ Checks all asset file sizes
- ✅ Reports oversized files
- ✅ Provides total directory sizes
- ✅ Suggests optimization tools

### Manual Optimization Tools

#### PNG Compression

```bash
# Using OptiPNG
optipng -o7 assets/images/*.png

# Using ImageMagick
convert input.png -quality 85 -resize 50% output.png

# Using pngquant (lossy, better compression)
pngquant --quality=65-80 input.png -o output.png
```

#### SVG Optimization

```bash
# Using SVGO (Node.js required)
npm install -g svgo
svgo assets/logos/*.svg
```

#### WebP Conversion (Recommended)

```bash
# Convert PNG/JPG to WebP
cwebp -q 80 input.png -o output.webp

# Batch conversion
for img in assets/images/*.png; do
  cwebp -q 80 "$img" -o "${img%.png}.webp"
done
```

## 📦 Asset Loading Strategy

### Fonts

- **Strategy**: Dynamic loading via `google_fonts` package
- **No local font files needed**
- **Benefits**: Smaller app size, automatic updates, wide font selection

### Images

- **Strategy**: Bundle essential assets, lazy load optional ones
- **Use asset variants** for different screen densities:
  ```
  assets/images/
    2.0x/logo.png
    3.0x/logo.png
    logo.png (1.0x)
  ```

### Icons

- **Strategy**: Use Material Icons and custom PNG/SVG icons
- **SVG preferred** for scalability and smaller file size

## 🎯 Size Constraints

| Asset Type | Maximum Size | Recommended Format |
| ---------- | ------------ | ------------------ |
| App Icon   | 100KB        | PNG (256x256)      |
| Logo       | 200KB        | SVG (preferred)    |
| UI Image   | 500KB        | WebP or PNG        |
| Background | 800KB        | WebP or JPG        |

## 🚀 Best Practices

1. **Always optimize before committing**

   - Run `bash scripts/optimize_assets.sh` before each commit
   - Use appropriate compression tools

2. **Use vector formats when possible**

   - SVG for logos and icons
   - Better quality at any scale
   - Smaller file sizes

3. **Provide theme variants**

   - Create dark and light versions of branded assets
   - Use semantic naming: `_light.svg` and `_dark.svg`

4. **Leverage Flutter's asset system**

   - Use asset variants for different densities
   - Let Flutter pick the right asset automatically

5. **Monitor asset bundle size**

   - Run `flutter build` and check `--analyze-size`
   - Keep total asset size under 5MB

6. **Use lazy loading for large assets**
   - Don't bundle rarely-used images
   - Load from network or local storage when needed

## 📊 Monitoring

### Check Asset Bundle Size

```bash
flutter build apk --analyze-size
flutter build windows --analyze-size
```

### List All Assets

```bash
find assets -type f ! -name '.gitignore' -exec ls -lh {} \;
```

### Total Asset Size

```bash
du -sh assets/*
```

## 🔄 CI/CD Integration

Add asset optimization to your CI pipeline:

```yaml
# Example GitHub Actions workflow
- name: Check Asset Sizes
  run: bash scripts/optimize_assets.sh

- name: Fail if oversized assets
  run: |
    if [ $(find assets -type f -size +500k | wc -l) -gt 0 ]; then
      echo "Error: Oversized assets found"
      exit 1
    fi
```

## 📝 Changelog

### November 30, 2025

- ✅ Removed unused `assets/fonts/` folder (using Google Fonts instead)
- ✅ Added SVG logo variants for light/dark themes
- ✅ Created asset optimization script
- ✅ Established asset size constraints
- ✅ Documented best practices

## 🔗 Resources

- [Flutter Asset Management](https://docs.flutter.dev/development/ui/assets-and-images)
- [Image Optimization Guide](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/image-optimization)
- [SVGO Documentation](https://github.com/svg/svgo)
- [WebP Documentation](https://developers.google.com/speed/webp)
