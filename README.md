# Flutter Liquid Shockwave (`liquid_shockwave`)

An Apple NameDrop / iOS 17 Tap-to-Share style liquid shockwave distortion effect in Flutter (Flutter 3.7+ using modern FragmentShader and Impeller / Skia pipeline).

Packages a high-performance refractive wave with chromatic aberration (RGB prism separation) and specular highlights originating from any touch point or directional edge (bottom, top, left, right, center).

---

## Installation via Git SSH

This library is hosted internally. Add the dependency to your `pubspec.yaml` via Git SSH:

```yaml
dependencies:
  flutter:
    sdk: flutter

  liquid_shockwave:
    git:
      url: git@github.com:ljcucc/flutter_lightwave_animation.git
      ref: main
```

Ensure your local machine has your SSH key added to GitHub:
```bash
ssh -T git@github.com
```

Then run:
```bash
flutter pub get
```

---

## Quick Usage

Wrap any child widget with `LiquidShockwaveContainer`:

```dart
import 'package:flutter/material.dart';
import 'package:liquid_shockwave/liquid_shockwave.dart';

final shockwaveKey = GlobalKey<LiquidShockwaveContainerState>();

LiquidShockwaveContainer(
  key: shockwaveKey,
  triggerOnTap: true, // Tap anywhere to ripple at finger position
  defaultSide: ShockwaveSide.bottom,
  duration: const Duration(milliseconds: 1400),
  child: MyWidget(),
)

// Trigger from screen bottom:
shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.bottom);

// Trigger from screen top (NameDrop contact style):
shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.top);

// Trigger from left or right:
shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.left);
shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.right);

// Trigger at exact coordinate:
shockwaveKey.currentState?.trigger(const Offset(200, 400));
```

---

## Features

- **Directional Triggers**: Bottom, Top, Left, Right, Center, Corners, or exact touch offsets.
- **Origin Bloom Glow & Selective EDR**: 300px+ radiant light orb at trigger origin expanding to ~550px+ while dissipating; features selective EDR (~2.20 peak) hot-core highlighting for Apple Liquid Retina XDR / OLED displays without flat white blowout.
- **Deep Refractive Displacement**: 2x intensified organic liquid bulge (`0.070` UV displacement) with broad wave span and isotropic aspect-ratio correction.
- **Speed & Duration Control**: Set global duration on widget or override per trigger call (`triggerFromSide(side, customDuration)`).
- **Snapshot Mode**: Single-frame capture on trigger, ultra-lightweight 120 FPS rendering.
- **Live Sampling Mode (`liveSampling: true`)**: Synchronous layer capture via `toImageSync()` allowing live animations (GIFs, media-kit video, Lottie) to keep moving while being distorted.
- **Impeller & Skia Native**: Uses GLSL 460 runtime effects with automatic package asset fallback.
- **Light & Dark Mode**: Pristine optical refraction and specular highlights across both themes.

---

## Running Example App

```bash
cd example
fvm flutter run -d macos # or -d chrome, ios, android
```
