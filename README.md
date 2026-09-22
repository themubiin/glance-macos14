<h1 align="center">
  <br>
  <a href="https://github.com/themubiin/glance-macos14">
    <img src="glance/Assets.xcassets/GlanceIcon.imageset/appicon.png" alt="Glance" width="120">
  </a>
  <br>
  Glance — macOS 14+
  <br>
</h1>

<h3 align="center">Face unlock for your Mac · Unofficial macOS Sonoma build</h3>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-black.svg" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/macOS-14%2B-black.svg" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-6.0-black.svg" alt="Swift 6">
  <img src="https://img.shields.io/badge/arch-arm64%20%7C%20x86__64-black.svg" alt="Universal">
  <a href="https://github.com/themubiin/glance-macos14/actions/workflows/build.yml">
    <img src="https://github.com/themubiin/glance-macos14/actions/workflows/build.yml/badge.svg" alt="Build Status">
  </a>
</p>

> **This is an unofficial fork** of [jonnyoo/glance](https://github.com/jonnyoo/glance) with patches to support **macOS 14 Sonoma** (the official release requires macOS 15 Sequoia).  
> Built as a Universal Binary (Apple Silicon + Intel). No Xcode required to install.

---

https://github.com/user-attachments/assets/77438826-80a9-4ab2-9fc3-42407a2d0adb

---

> [!WARNING]
> ### Glance is not as secure as Apple's FaceID or TouchID
>
> MacBooks don't have the depth sensors that make iPhone FaceID trustworthy. A MacBook webcam sees a flat 2D image, not a 3D face map. That means:
>
> - Glance can defeat a printed photo or a photo on a phone screen (with heavy liveness detection on)
> - Glance does **not** reliably defeat a video of you
> - macOS has no API for third-party login, so Glance unlocks by typing your stored password on the lock screen
>
> **Glance is a convenience feature, not a security upgrade. Only continue if you accept the tradeoff.**

---

## Download

> [!IMPORTANT]
> **macOS 14.0 Sonoma or later is required.** For macOS 15 Sequoia, use the [official release](https://github.com/jonnyoo/glance/releases/latest).

Download the latest **Universal DMG** from GitHub Actions:

**[→ Go to Actions → latest successful build → download `Glance-macOS14-Universal-DMG`](https://github.com/themubiin/glance-macos14/actions/workflows/build.yml)**

Then install:

```
1. Open the .dmg file
2. Drag Glance to /Applications
3. Open Glance from /Applications (right-click → Open if Gatekeeper blocks it)
```

---

## Permissions

| Permission | Why |
|---|---|
| **Camera** | To see your face. Frames are processed in memory and never written to disk. |
| **Accessibility** | To type your password into the lock screen. |
| **Touch ID / Keychain** | Gates the key that encrypts your face data and password. |

---

## How it works

1. **Enroll your face** — Glance guides you through capturing your face in nine directions. Each frame becomes a 512-number *embedding* (a mathematical fingerprint) — the original image is thrown away.
2. **Store your password** — Entered once, encrypted behind Touch ID / Keychain.
3. **Auto-unlock** — When your Mac locks or wakes from sleep, the notch animation appears and scans for your face.
4. **Match + liveness** — If it's you *and* liveness checks confirm you're a real person, Glance types your password and you're in.

---

## Features

| Feature | Description |
|---|---|
| **Face unlock** | Triggers on wake, on lock, or on pressing space at the lock screen. |
| **Multiple identities** | Enroll several people, or several versions of yourself. Toggle any off without deleting. |
| **Liveness detection** | Watches for motion and reflections that separate a real face from a photo. *Light* or *Heavy* strictness, or off. |
| **Notch UI** | Pill that expands into a scan animation with success and failure states. Hover to retry. |
| **Camera selection** | Choose which camera to use, including different cameras for built-in vs. external displays. |
| **Auto-locking sessions** | Touch ID session re-locks after an idle period you choose. |
| **Trackpad haptics** | Hovering over the notch triggers haptic feedback. |
| **Notchless Mac support** | Replaced with a dynamic island-style pill on Macs without a notch. |
| **Your data, your call** | Edit or delete your enrollment or stored password at any time. |

---

## Privacy & Security

### Face data
Glance **never stores camera images**. During enrollment, each captured face is converted to a **512-dimensional embedding** using an ArcFace Core ML model. The original frame is discarded immediately.

Embeddings are stored locally and encrypted with **AES-GCM**.

### Credentials
Your Mac password is stored as encrypted data and is never written to disk in plaintext. The encryption key is a **256-bit AES key in the macOS Keychain**, protected by `userPresence` (Touch ID or device password).

The key is only held in memory while an authorized Glance session is active.

### Unlock pipeline
Glance won't type your password just because a face matches. All of the following must be true:

1. A valid Glance session is authorized
2. The Mac is actually at the lock screen
3. An enabled identity matches above the configured threshold
4. Liveness checks accept the detected face
5. Accessibility permission is available

### Local by design
Face recognition, enrollment, and liveness detection run entirely **on-device** using Vision and Core ML. No face data, camera frames, or credentials are sent to any server.

### Liveness detection

Five independent cues over a rolling ~2s window, in two roles:

- **Deny cues** — evidence of a spoof (screen glare, device-shaped rectangle around the face). Either one fails the scan immediately.
- **Confirm cues** — evidence of a real face (flat-vs-3D geometry, nose parallax, blinks). Any one is enough; their absence is never a failure.

*Light* detection = deny cues only. *Heavy* = both deny and confirm cues.

### Face Lab (debug console)
**Settings → About → click the app icon 5 times.** Opens real-time face recognition and liveness detection values.

---

## Fork patches (vs. upstream)

| Change | Reason |
|---|---|
| `MACOSX_DEPLOYMENT_TARGET = 14.0` | Sonoma support |
| `Settings { }` scene replacing `Window("Glance Settings")` | macOS 15-only API |
| `@Environment(\.openSettings)` instead of `openWindow` | macOS 14 compat |
| Version-gated `.symbolEffect(.replace.magic)` | macOS 15-only SF Symbol effect |
| `chevron.up.2` → `chevron.up` | SF Symbol not available on macOS 14 |
| `arrow.trianglehead.clockwise.rotate.90` → `arrow.clockwise` | SF Symbol not available on macOS 14 |
| Keychain `errSecMissingEntitlement` fallback | Ad-hoc signed builds (no Developer cert) |
| Removed `keychain-access-groups` entitlement | Requires real Apple Developer team cert |
| `SWIFT_APPROACHABLE_CONCURRENCY = NO` | Swift 6 concurrency actor isolation fix |
| GitHub Actions CI (Universal DMG) | No Xcode required for end users |

---

## Building from source

### Prerequisites

- macOS 14.0+
- Xcode 16+

Or skip Xcode entirely — push to `main` and download the artifact from [Actions](https://github.com/themubiin/glance-macos14/actions).

### Steps

```bash
git clone https://github.com/themubiin/glance-macos14.git
cd glance-macos14
open glance.xcodeproj
```

Then click **Run** (`Cmd + R`) in Xcode.

---

## Acknowledgements

- **[jonnyoo/glance](https://github.com/jonnyoo/glance)** — the original project and all core work
- **[The Boring Notch](https://github.com/TheBoredTeam/boring.notch)** — notch window physics
- **[InsightFace](https://github.com/deepinsight/insightface)** — ArcFace model for face recognition
- **[Alcove](https://tryalcove.com)** — design inspiration

---

## License

[MIT](LICENSE) © Jonathan Zhou  
Fork maintained by [themubiin](https://github.com/themubiin)
