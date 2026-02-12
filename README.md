# CyberWeather ⚡

> `// ATMOSPHERIC INTELLIGENCE NETWORK //`

A cyberpunk-themed weather app for Android. Neon-lit HUD interface, glitch effects, and a terminal boot sequence — all powered by real-time weather data. Built with Flutter.

<p align="center">
  <img src="assets/icon.png" alt="CyberWeather" width="200"/>
</p>

---

```
> INITIALIZING NEURAL INTERFACE...
> LOADING ATMOSPHERIC SENSORS... [OK]
> CALIBRATING WEATHER MATRIX...
> SYNCING SATELLITE UPLINK... [OK]
> CyberWeather ONLINE
```

---

## `// FEATURE_MATRIX //`

| Module | Status | Description |
|--------|--------|-------------|
| `WEATHER_CORE` | `[ONLINE]` | Real-time weather data via Open-Meteo API — no API key needed |
| `LOCATION_SVC` | `[ONLINE]` | GPS auto-detect + manual city search with geocoding |
| `HOURLY_FEED` | `[ONLINE]` | 24-hour forecast with scrollable timeline |
| `DAILY_FEED` | `[ONLINE]` | 10-day forecast with temperature range bars |
| `AQI_MODULE` | `[ONLINE]` | Air Quality Index with pollutant breakdown (PM2.5, PM10, O₃, NO₂) |
| `HUD_WARNINGS` | `[ONLINE]` | Animated neon alert banners for extreme conditions |
| `CYBER_FX` | `[ONLINE]` | Particle rain, digital snow, neon lightning, glitch effects |
| `BOOT_SEQ` | `[ONLINE]` | Terminal-style splash screen with loading bar |
| `DEBUG_CONSOLE` | `[ONLINE]` | Weather FX simulator + alert tester (Easter egg: tap cloud icon x7) |
| `ADV_VIEW` | `[ONLINE]` | Toggleable advanced metrics — atmosphere, wind, precipitation, UV |
| `RESPONSIVE` | `[ONLINE]` | Portrait + landscape with immersive fullscreen mode |

## `// VISUAL_SPEC //`

- **Neon palette**: Cyan / Magenta / Yellow / Green on dark panels
- **Glassmorphic cards** with animated borders and scan lines
- **Dynamic backgrounds** shift with weather + time of day
- **Glitch effects** on transitions & alerts
- **Monospace typography** throughout for that terminal aesthetic

## `// TECH_STACK //`

```
FRAMEWORK    : Flutter 3.38.9 (Dart 3.10.8)
STATE_MGMT   : Provider
API_SRC      : Open-Meteo (open-meteo.com)
LOCATION     : geolocator + geocoding
PERMISSIONS  : permission_handler
STORAGE      : shared_preferences
ANIMATIONS   : flutter_animate
FX_ENGINE    : CustomPainter (rain, snow, particles, scanlines)
```

## `// SETUP_PROTOCOL //`

### Prerequisites

- Flutter SDK ≥ 3.38.9
- Android SDK (minSdk 26)
- Java 17

### Deploy

```bash
git clone https://github.com/ShaptakNaskar/weatherman.git
cd weatherman
git checkout cyberpunk
flutter pub get
flutter run
```

### Build APK

```bash
# Debug
flutter build apk --debug

# Release (signed)
# First create android/key.properties with your keystore creds
flutter build apk --release
```

## `// SYS_ARCHITECTURE //`

```
lib/
├── main.dart
├── config/
│   ├── constants.dart
│   ├── cyberpunk_theme.dart        # Neon colors, glow shadows, HUD styling
│   └── theme.dart
├── models/
│   ├── location.dart
│   └── weather.dart
├── providers/
│   ├── location_provider.dart
│   ├── settings_provider.dart
│   └── weather_provider.dart
├── screens/
│   ├── debug_weather_screen.dart   # // DEBUG_CONSOLE //
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── settings_screen.dart
│   └── splash_screen.dart          # Terminal boot sequence
├── services/
│   ├── air_quality_service.dart
│   ├── location_service.dart
│   ├── storage_service.dart
│   └── weather_service.dart
├── utils/
│   ├── date_utils.dart
│   ├── unit_converter.dart
│   └── weather_utils.dart
└── widgets/
    ├── backgrounds/
    ├── common/
    ├── cyberpunk/                   # Glitch FX, HUD warnings, cyber cards
    ├── glassmorphic/
    └── weather/
```

## `// CI_CD //`

GitHub Actions auto-builds on push to `main` and `cyberpunk` branches. Both APKs are built and attached to each release — each with its own version tag pulled from its branch's `pubspec.yaml`.

## `// PERMISSIONS //`

| Permission | Purpose |
|-----------|---------|
| `INTERNET` | Fetch weather data from Open-Meteo |
| `ACCESS_FINE_LOCATION` | GPS-based weather detection |
| `ACCESS_COARSE_LOCATION` | Approximate location fallback |

## `// CREDITS //`

- **Data source**: [Open-Meteo](https://open-meteo.com/)
- **Framework**: [Flutter](https://flutter.dev)

## `// DEVELOPER //`

Coded with ❤️ by [Sappy](https://sappy-dir.vercel.app)

## `// LICENSE //`

[GNU General Public License v3.0](LICENSE)

---

```
> SESSION_END
> CyberWeather v1.0.8_CYBER
> ALL SYSTEMS NOMINAL
```
