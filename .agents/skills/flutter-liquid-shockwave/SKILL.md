---
name: flutter-liquid-shockwave
description: >-
  Integrate and use the Apple NameDrop / iOS Tap-to-Share style liquid shockwave distortion
  effect in Flutter. Use when wrapping widgets with refractive shockwaves, chromatic aberration,
  and directional ripples. Details Git SSH dependency installation for internal organization repos.
---

# Flutter Liquid Shockwave (`liquid_shockwave`)

An Apple NameDrop / iOS 17 Tap-to-Share style liquid shockwave distortion effect in Flutter (Flutter 3.7+ using modern Impeller / Skia `FragmentShader` pipeline).

This package provides a reusable wrapper widget `LiquidShockwaveContainer` that can wrap **ANY** arbitrary child widget (contact cards, full screen views, buttons, video, or animated GIFs), creating a refractive liquid wave with chromatic aberration (RGB prism separation) and specular highlights originating from touch positions or directional edges.

---

## 1. How to Import (Git SSH)

Since this package is hosted in an internal private repository, **Git SSH import** is required.

### Prerequisites:
Ensure your local machine or CI/CD runner has an SSH key-pair set up and authenticated with GitHub:
```bash
ssh -T git@github.com
# Should output: Hi <username>! You've successfully authenticated...
```

### Add to `pubspec.yaml`:
Add the dependency using Git SSH URL under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  liquid_shockwave:
    git:
      url: git@github.com:ljcucc/flutter_lightwave_animation.git
      ref: main # You can also specify a tag or commit hash
```

Then fetch dependencies:
```bash
flutter pub get
# or using FVM:
fvm flutter pub get
```

> [!NOTE]
> The shader file (`shaders/liquid_shockwave.frag`) is already declared in the library's `pubspec.yaml` and compiled by Flutter into `packages/liquid_shockwave/shaders/liquid_shockwave.frag`. You do **NOT** need to re-declare the shader in your consuming application's `pubspec.yaml`.

---

## 2. Quickstart

Wrap any widget with `LiquidShockwaveContainer`:

```dart
import 'package:flutter/material.dart';
import 'package:liquid_shockwave/liquid_shockwave.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final GlobalKey<LiquidShockwaveContainerState> _shockwaveKey =
      GlobalKey<LiquidShockwaveContainerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidShockwaveContainer(
        key: _shockwaveKey,
        triggerOnTap: true, // Tap anywhere to trigger wave at finger position
        defaultSide: ShockwaveSide.bottom,
        duration: const Duration(milliseconds: 1400),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              // Programmatically trigger ripple upwards from screen bottom
              _shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.bottom);
            },
            child: const Text('Trigger Bottom Shockwave'),
          ),
        ),
      ),
    );
  }
}
```

---

## 3. Directional Trigger API

`LiquidShockwaveContainerState` exposes methods to launch the wave from any edge, alignment, or exact coordinate:

### A. From Predefined Edges / Sides:
```dart
// 1. From bottom edge (propagates upwards)
_shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.bottom);

// 2. From top edge (simulates Apple NameDrop contact)
_shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.top);

// 3. From left or right edges
_shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.left);
_shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.right);

// 4. From center (radial expansion)
_shockwaveKey.currentState?.triggerFromSide(ShockwaveSide.center);

// Other available sides:
// ShockwaveSide.topLeft, ShockwaveSide.topRight,
// ShockwaveSide.bottomLeft, ShockwaveSide.bottomRight
```

### B. From Exact Coordinate / Touch Point:
```dart
// In logical pixels relative to the container
_shockwaveKey.currentState?.trigger(const Offset(200, 450));
```

### C. From Fractional Alignment:
```dart
_shockwaveKey.currentState?.triggerFromAlignment(Alignment.bottomCenter);
```

---

## 4. Animation Customization

### Animation Speed & Duration:
You can set a global duration on the widget or override it dynamically per trigger:

```dart
// Widget default:
LiquidShockwaveContainer(
  duration: const Duration(milliseconds: 1400),
  curve: Curves.easeOutCubic,
  child: ...,
)

// Dynamic override during call:
_shockwaveKey.currentState?.triggerFromSide(
  ShockwaveSide.bottom,
  const Duration(milliseconds: 2500), // Slow-Motion 2.5s wave
);
```

### Live Sampling Mode vs Snapshot Mode:
```dart
LiquidShockwaveContainer(
  // false (default): Captures 1 static snapshot at trigger time.
  //                  Ultra-fast, zero GPU overhead, 120 FPS ProMotion.
  // true:            Continuously re-samples the child layer every frame.
  //                  Allows continuously moving animations (spinning GIFs,
  //                  media-kit video, Lottie) to keep animating WHILE being distorted.
  liveSampling: true,
  child: ...,
)
```

---

## 5. Troubleshooting

- **`Permission denied (publickey)` during `flutter pub get`:**
  - Verify your SSH key is added: `ssh-add -l`.
  - Add your key if missing: `ssh-add ~/.ssh/id_ed25519` (or `id_rsa`).
  - Test connection: `ssh -T git@github.com`.

- **Shader not loading in custom environments:**
  - `LiquidShockwaveContainer` contains automatic fallback between standalone asset path (`shaders/liquid_shockwave.frag`) and package asset path (`packages/liquid_shockwave/shaders/liquid_shockwave.frag`).

- **Running the Example App:**
  ```bash
  cd example
  fvm flutter run -d macos # or -d chrome, ios, android
  ```
