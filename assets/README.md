# Assets Management

This directory contains all static assets for the fiwe application including images, icons, and SVGs.

## Directory Structure

```
assets/
├── images/          # PNG, JPG, WebP images
├── icons/           # Small icon images (PNG, WebP)
└── svgs/            # Scalable Vector Graphics
```

## Asset Organization Guidelines

### Images (`assets/images/`)
- **App branding**: Logo, splash backgrounds
- **Authentication**: Login/signup backgrounds, illustrations
- **User interface**: Profile placeholders, hero images
- **Onboarding**: Tutorial and welcome images
- **Empty states**: No data, error illustrations

### Icons (`assets/icons/`)
- **Navigation**: Bottom navigation icons
- **Actions**: Add, edit, delete, search icons
- **Authentication**: Social login icons (Google, Facebook, Apple)
- **Status**: Success, error, warning indicators
- **Media**: Camera, gallery, play/pause icons

### SVGs (`assets/svgs/`)
- **Illustrations**: Complex graphics that need to scale
- **Brand elements**: Logo variations, symbols
- **Feature graphics**: Onboarding, feature explanations
- **Social icons**: Platform icons that need perfect scaling

## Usage

### Using the Assets Utility Class

The `Assets` class provides type-safe access to all application assets:

```dart
import 'package:fiwe/src/utils/assets.dart';

// Using images
Image.asset(Assets.images.logo)
Image.asset(Assets.images.loginBackground)
Image.asset(Assets.images.defaultAvatar)

// Using PNG icons
Image.asset(Assets.icons.google)
Image.asset(Assets.icons.camera)

// Using SVG assets
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(Assets.svgs.logoSvg)
SvgPicture.asset(Assets.svgs.loginIllustration)
```

### Asset Naming Conventions

- Use **snake_case** for file names
- Be descriptive but concise
- Group related assets with prefixes:
  - `onboarding_1.png`, `onboarding_2.png`
  - `feature_analytics.svg`, `feature_security.svg`
  - `icon_home.png`, `icon_home_selected.png`

### Image Resolution Guidelines

#### Raster Images (PNG/JPG)
- Provide @2x and @3x variants for different screen densities
- Example: `logo.png`, `logo@2x.png`, `logo@3x.png`
- Use WebP format when possible for better compression

#### Vector Graphics (SVG)
- Single file scales to all screen sizes
- Optimize SVGs to remove unnecessary metadata
- Keep file sizes small (< 50KB for icons, < 200KB for illustrations)

## File Size Optimization

- **Icons**: Keep under 20KB each
- **Images**: Compress appropriately (use tools like TinyPNG)
- **SVGs**: Optimize with SVGO or similar tools
- **Total assets**: Monitor app size impact

## Adding New Assets

1. **Place files** in appropriate subdirectory
2. **Update Assets class** in `lib/src/utils/assets.dart`
3. **Add to pubspec.yaml** if creating new asset types
4. **Test** asset loading in your widgets

### Example: Adding a New Icon

1. Add `new_feature.png` to `assets/icons/`
2. Update Assets class:
```dart
class Icons {
  // ... existing icons
  static const String newFeature = '${Assets._iconsPath}/new_feature.png';
}
```
3. Use in code:
```dart
Image.asset(Assets.icons.newFeature)
```

## Best Practices

1. **Lazy Loading**: Assets are loaded when first accessed
2. **Caching**: Flutter automatically caches loaded assets
3. **Error Handling**: Provide fallback assets for missing files
4. **Performance**: Use appropriate formats (SVG for scalable, PNG for photos)
5. **Accessibility**: Include semantic descriptions for screen readers

## Asset Variants

Flutter supports automatic asset variant selection:

```
assets/images/
├── logo.png          # 1x density
├── 2.0x/
│   └── logo.png      # 2x density  
└── 3.0x/
    └── logo.png      # 3x density
```

Declare in pubspec.yaml:
```yaml
flutter:
  assets:
    - assets/images/logo.png
```

Flutter automatically selects the appropriate variant based on device pixel ratio.

## Troubleshooting

### Asset Not Found Error
- Verify file exists in correct directory
- Check pubspec.yaml includes the asset path
- Ensure file name matches exactly (case-sensitive)
- Run `flutter clean` and `flutter pub get`

### Large App Size
- Audit asset sizes with `flutter build apk --analyze-size`
- Compress images and optimize SVGs
- Remove unused assets
- Consider asset bundling strategies for large apps