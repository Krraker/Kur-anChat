# App Logo Requirements & Export Guide

> **Current Logo:** `/Branding/App_Logo1x.png`  
> **Status:** ✅ Design looks good! Needs to be exported in multiple sizes

---

## 📱 iOS App Icon Requirements

### Required Sizes (All PNG, RGB, NO transparency)

Apple requires **1024x1024px** master icon + various sizes for the app bundle:

| Size | Resolution | Usage | Filename |
|------|------------|-------|----------|
| **1024x1024** | @1x | **App Store** | `AppIcon-1024.png` |
| 180x180 | @3x | iPhone | `AppIcon-60@3x.png` |
| 167x167 | @2x | iPad Pro | `AppIcon-83.5@2x.png` |
| 152x152 | @2x | iPad | `AppIcon-76@2x.png` |
| 120x120 | @3x | iPhone Spotlight | `AppIcon-40@3x.png` |
| 120x120 | @2x | iPhone | `AppIcon-60@2x.png` |
| 87x87 | @3x | iPhone Settings | `AppIcon-29@3x.png` |
| 80x80 | @2x | iPhone Spotlight | `AppIcon-40@2x.png` |
| 76x76 | @1x | iPad | `AppIcon-76.png` |
| 58x58 | @2x | iPhone Settings | `AppIcon-29@2x.png` |
| 40x40 | @1x | iPad Spotlight | `AppIcon-40.png` |
| 29x29 | @1x | iPhone Settings | `AppIcon-29.png` |

### ⚠️ iOS Icon Rules
- **NO transparency** - Must have solid background
- **NO rounded corners** - iOS adds them automatically
- **Format:** PNG, 24-bit RGB (not RGBA)
- **Profile:** sRGB or P3 color space

---

## 🤖 Android App Icon Requirements (Future)

### Adaptive Icon (Android 8.0+)

| Layer | Size | Format | Purpose |
|-------|------|--------|---------|
| Foreground | 432x432 | PNG with transparency | Logo/icon only |
| Background | 432x432 | PNG or solid color | Background layer |

### Legacy Icons

| Size | Resolution | Usage |
|------|------------|-------|
| 512x512 | xxxhdpi | Play Store listing |
| 192x192 | xxxhdpi | Launcher icon |
| 144x144 | xxhdpi | Launcher icon |
| 96x96 | xhdpi | Launcher icon |
| 72x72 | hdpi | Launcher icon |
| 48x48 | mdpi | Launcher icon |

---

## 🎨 Store Marketing Assets

### iOS App Store Screenshots

| Device | Size | Required Count |
|--------|------|----------------|
| iPhone 6.7" (Pro Max) | 1290 x 2796 | 5-10 screenshots |
| iPhone 6.5" (Plus) | 1284 x 2778 | 5-10 screenshots |
| iPad Pro 12.9" | 2048 x 2732 | Optional |

**What to capture:**
1. Onboarding flow (language selection)
2. Home screen with daily cards
3. Quran reader showing a surah
4. AI Chat interface
5. Profile with gamification stats
6. (Optional) Community screen

### Google Play Store Screenshots (Future)

| Type | Size | Required Count |
|------|------|----------------|
| Phone | 1080 x 1920 (or up to 2:1) | 2-8 screenshots |
| 7" Tablet | 1024 x 600 | Optional |
| 10" Tablet | 1920 x 1200 | Optional |

### Feature Graphic (Google Play)

| Size | Format | Purpose |
|------|--------|---------|
| 1024 x 500 | JPG or PNG | Top banner on Play Store |

---

## 🛠️ How to Export Icons

### Option 1: Online Tool (Easiest)
Use **AppIcon.co** (https://www.appicon.co)
1. Upload your 1024x1024 PNG
2. Select "iOS"
3. Download the zip
4. Replace contents in `mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Option 2: Figma/Sketch Export
If your logo is in Figma/Sketch:
1. Select the logo layer
2. Export at 1x, 2x, 3x for each size
3. Use export presets for iOS icons

### Option 3: Manual (Photoshop/GIMP)
1. Open your logo at highest resolution
2. For each size:
   - Image → Image Size → Enter dimensions
   - Save as PNG-24 (NO transparency)
   - Use bicubic interpolation

### Option 4: ImageMagick (Command Line)
```bash
# Install ImageMagick
brew install imagemagick

# Generate all iOS sizes
convert AppIcon-1024.png -resize 180x180 AppIcon-60@3x.png
convert AppIcon-1024.png -resize 167x167 AppIcon-83.5@2x.png
convert AppIcon-1024.png -resize 152x152 AppIcon-76@2x.png
# ... etc for all sizes
```

---

## ✅ Pre-Export Checklist

Before exporting your logo:

- [ ] **Remove transparency** - Add solid background color
  - Your current logo has a gradient green background ✅
  - Make sure the background extends to all edges
  
- [ ] **Remove rounded corners** - Make it perfectly square
  - iOS will round it automatically
  - Android adaptive icons handle shape
  
- [ ] **Increase contrast if needed**
  - Logo should be visible at 29x29 size
  - Test by shrinking to smallest size
  
- [ ] **Center the design**
  - Leave ~10% padding from edges
  - Prevents cropping on different devices
  
- [ ] **Use RGB color mode** (not CMYK)
  - Convert to sRGB color space

---

## 📂 Where to Place Icons

### iOS
```
mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── AppIcon-1024.png
├── AppIcon-60@2x.png
├── AppIcon-60@3x.png
├── AppIcon-76.png
├── AppIcon-76@2x.png
└── ... (all sizes)
```

Update `Contents.json` to reference your icons.

### Android (Future)
```
mobile/android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-hdpi/ic_launcher.png (72x72)
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
└── mipmap-xxxhdpi/ic_launcher.png (192x192)
```

---

## 🎯 Action Items

### Immediate (iOS Launch)
1. Export 1024x1024 master icon (PNG, RGB, no transparency)
2. Generate all iOS icon sizes (use AppIcon.co)
3. Replace in `mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
4. Take 5-8 app screenshots (1290x2796)
5. Test icon looks good on device

### Later (Android)
1. Create adaptive icon layers (foreground + background)
2. Export all Android sizes
3. Create feature graphic (1024x500)

---

## 🔗 Useful Resources

- **AppIcon.co** - https://www.appicon.co (Free iOS icon generator)
- **MakeAppIcon** - https://makeappicon.com (Paid, $5)
- **Figma Icon Template** - Search "iOS app icon template"
- **Apple HIG** - https://developer.apple.com/design/human-interface-guidelines/app-icons
- **Screenshot Frames** - https://www.screenshotone.com (Add device frames)

---

## 💡 Pro Tips

1. **Test at smallest size first** - If it looks good at 29x29, it'll look good everywhere
2. **Keep it simple** - Complex logos don't scale well
3. **High contrast** - Ensures visibility on various backgrounds
4. **Export from vector** - If possible, create logo in vector format first
5. **Use safe area** - Keep important elements in center 80% of canvas

---

**Your Current Logo:** ✅ Looks great! The green gradient and Arabic calligraphy are distinctive. Just export to required sizes and you're ready to ship!

---

*Last Updated: December 23, 2024*

