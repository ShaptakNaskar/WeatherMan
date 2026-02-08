# WeatherMan ☁️

A beautiful, glassmorphic weather application for Android inspired by iOS Weather. Built with Flutter as a learning project to explore modern UI design patterns and API integration.

<p align="center">
  <img src="assets/icon.png" alt="WeatherMan Logo" width="200"/>
</p>

## ✨ Features

- **🎨 Glassmorphic Design**: iOS-inspired frosted glass UI with dynamic blur effects and transparency
- **🌤️ Real-time Weather**: Accurate weather data powered by Open-Meteo API (no API key required!)
- **📍 Location-based**: Automatic location detection or manual city search with geocoding
- **📊 Comprehensive Forecasts**: 
  - Current conditions with detailed metrics (feels like, humidity, wind, pressure, visibility)
  - 24-hour hourly forecast
  - 10-day daily forecast with temperature bars
- **🌅 Dynamic Backgrounds**: Beautiful gradient backgrounds that change based on weather and time of day
- **🎭 Weather Animations**: 
  - Falling rain drops for rainy conditions
  - Gentle snowfall for snowy weather
  - Twinkling stars on clear nights
  - Ambient lightning glow for thunderstorms
  - Drifting fog layers
  - Floating clouds
- **⚙️ Settings**: Toggle between Celsius and Fahrenheit
- **🔒 Permission Handling**: Graceful location permission management
- **✨ Smooth Animations**: Entrance animations with staggered fade and slide effects

## 🛠️ Tech Stack

- **Framework**: Flutter 3.38.9 (Dart SDK 3.10.8)
- **State Management**: Provider
- **API**: [Open-Meteo](https://open-meteo.com/) - Free weather API
- **Key Dependencies**:
  - `geolocator` & `geocoding` - Location services
  - `permission_handler` - Runtime permissions
  - `shared_preferences` - Local storage
  - `flutter_animate` - Smooth UI animations
  - `shimmer` - Loading effects
  - `url_launcher` - External links

## 📋 Prerequisites

- Flutter SDK 3.38.9 or higher
- Dart SDK 3.10.8 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK (minSdk 26)
- Java 17 (for building signed APKs)

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ShaptakNaskar/weatherman.git
   cd weatherman
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Android

#### Debug Build
```bash
flutter build apk --debug
```

#### Release Build (Unsigned)
```bash
flutter build apk --release
```

#### Release Build (Signed)
1. Create `android/key.properties` with your keystore credentials:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=your_key_alias
   storeFile=../../keystore/your-keystore.jks
   ```

2. Build the signed APK:
   ```bash
   flutter build apk --release
   ```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Permissions

The app requires the following permissions:
- **Location**: For automatic weather detection based on your current location
- **Internet**: To fetch weather data from Open-Meteo API

All permissions are requested at runtime with proper explanations.

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/
│   ├── constants.dart       # App-wide constants
│   └── theme.dart           # Theme colors, gradients, shadows
├── models/
│   ├── location.dart        # Location data model
│   └── weather.dart         # Weather data models
├── providers/
│   ├── location_provider.dart    # Location state management
│   ├── settings_provider.dart    # App settings state
│   └── weather_provider.dart     # Weather data state
├── screens/
│   ├── home_screen.dart          # Main weather display
│   ├── search_screen.dart        # City search
│   └── settings_screen.dart      # Settings & About
├── services/
│   ├── location_service.dart     # GPS & geocoding logic
│   ├── storage_service.dart      # SharedPreferences wrapper
│   └── weather_service.dart      # Open-Meteo API integration
├── utils/
│   ├── date_utils.dart          # Date formatting helpers
│   ├── unit_converter.dart      # Temperature unit conversion
│   └── weather_utils.dart       # WMO weather code mappings
└── widgets/
    ├── backgrounds/             # Dynamic weather backgrounds
    ├── common/                  # Reusable UI components
    ├── glassmorphic/           # Glass card components
    └── weather/                # Weather-specific widgets
```

## 🔄 CI/CD

This project uses GitHub Actions for automated builds:
- Automatically builds release APK on every push to `main`/`master`
- Creates GitHub Release with version tag
- Attaches signed APK to release
- Uses commit message as release description

## 🎓 Learning Highlights

As my first Flutter project, I learned:
- **State Management**: Implementing Provider pattern for reactive UI
- **API Integration**: Making HTTP requests and parsing JSON responses
- **Geolocation**: Working with device GPS and geocoding services
- **Custom Animations**: Creating weather effects with CustomPainter
- **Responsive Design**: Building adaptive layouts with MediaQuery
- **Platform Integration**: Handling Android permissions and app signing
- **Performance Optimization**: Reducing overdraw with LightGlassCard components
- **CI/CD**: Setting up GitHub Actions for automated releases

## 🙏 Credits

- **Weather Data**: [Open-Meteo](https://open-meteo.com/) - Free weather API with generous limits
- **Design Inspiration**: iOS Weather App
- **Icons**: Material Design Icons

## 👨‍💻 Developer

Made with ❤️ by [Sappy](https://sappy-dir.vercel.app)

## 📄 License

This project is open source and available under the [GNU General Public License v3.0](LICENSE).

---

*This is a learning project created to explore Flutter development. Feel free to fork and experiment!*
