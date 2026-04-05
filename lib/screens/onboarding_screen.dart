import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/services/notification_service.dart';
import 'package:weatherman/services/push_service.dart';
import 'package:weatherman/services/storage_service.dart';
import 'package:android_intent_plus/android_intent.dart';

/// Onboarding screen with swipeable pages introducing app features
/// Includes theme picker and permission requests
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _notificationsEnabled = false;
  bool _batteryOptimizationDisabled = false;

  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final storage = StorageService();
    await storage.setOnboardingComplete();
    widget.onComplete();
  }

  Future<void> _requestNotifications() async {
    final result = await NotificationService.instance.requestPermission();
    await PushService.instance.init(requestPermission: true);
    if (mounted) {
      setState(() => _notificationsEnabled = result == true);
    }
  }

  Future<void> _requestBatteryOptimization() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        data: 'package:com.sappy.cyberweather',
      );
      await intent.launch();
      if (mounted) {
        setState(() => _batteryOptimizationDisabled = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    final isDark = t.themeData.brightness == Brightness.dark;
    final accent = t.primaryUiAccent;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: t.getWeatherGradient(0, true)),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button (not on last page)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < _totalPages - 1)
                      TextButton(
                        onPressed: _skipToEnd,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: t.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: [
                    _buildWelcomePage(t, isDark),
                    _buildFeaturesPage(t, isDark),
                    _buildThemePage(t, isDark),
                    _buildPermissionsPage(t, isDark),
                  ],
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalPages,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? accent
                            : t.textTertiary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: _onAccentTextColor(accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(t.cardBorderRadius),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppThemeData t, bool isDark) {
    final accent = t.secondaryUiAccent;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.28),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to SappyWeather',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: t.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your beautiful, intelligent weather companion',
            style: TextStyle(fontSize: 16, color: t.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(AppThemeData t, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Features',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          _buildFeatureItem(
            t,
            Icons.cloud_rounded,
            'Real-time Weather',
            'Accurate forecasts updated throughout the day',
          ),
          _buildFeatureItem(
            t,
            Icons.notifications_rounded,
            'Smart Notifications',
            'Morning briefings, evening outlooks, and severe alerts',
          ),
          _buildFeatureItem(
            t,
            Icons.air_rounded,
            'Air Quality',
            'Detailed AQI data with pollutant breakdown',
          ),
          _buildFeatureItem(
            t,
            Icons.checkroom_rounded,
            'What to Wear',
            'Clothing advice based on conditions',
          ),
          _buildFeatureItem(
            t,
            Icons.palette_rounded,
            'Beautiful Themes',
            '6 stunning themes to personalize your experience',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    AppThemeData t,
    IconData icon,
    String title,
    String description,
  ) {
    final accent = t.primaryUiAccent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: t.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePage(AppThemeData t, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Choose Your Style',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a theme to preview it instantly',
            style: TextStyle(fontSize: 14, color: t.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(child: _ThemePicker()),
        ],
      ),
    );
  }

  Widget _buildPermissionsPage(AppThemeData t, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Permissions',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional permissions to enhance your experience',
            style: TextStyle(fontSize: 14, color: t.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildPermissionCard(
            t,
            Icons.notifications_rounded,
            'Notifications',
            'Get morning/evening briefings and severe weather alerts',
            _notificationsEnabled,
            _requestNotifications,
          ),
          const SizedBox(height: 16),
          if (Platform.isAndroid)
            _buildPermissionCard(
              t,
              Icons.battery_saver_rounded,
              'Background Access',
              'Keep widgets and notifications up to date',
              _batteryOptimizationDisabled,
              _requestBatteryOptimization,
            ),
          const Spacer(),
          Text(
            'You can change these later in Settings',
            style: TextStyle(fontSize: 12, color: t.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(
    AppThemeData t,
    IconData icon,
    String title,
    String description,
    bool isEnabled,
    VoidCallback onRequest,
  ) {
    final accent = t.primaryUiAccent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(t.cardBorderRadius),
        border: Border.all(
          color: isEnabled
              ? t.successColor.withValues(alpha: 0.5)
              : t.cardBorderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isEnabled ? t.successColor : accent).withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEnabled ? Icons.check_circle_rounded : icon,
              color: isEnabled ? t.successColor : accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: t.textSecondary),
                ),
              ],
            ),
          ),
          if (!isEnabled)
            TextButton(
              onPressed: onRequest,
              child: Text(
                'Allow',
                style: TextStyle(color: accent, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

/// Theme picker widget with reactive theme switching
class _ThemePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentType = themeProvider.currentType;

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: AppThemeType.values.map((type) {
        return _ThemeCard(
          type: type,
          isSelected: type == currentType,
          onTap: () => themeProvider.setTheme(type),
        );
      }).toList(),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;
    final selectedIconColor = accent.computeLuminance() > 0.55
        ? Colors.black
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: _getThemePreviewGradient(type),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                _getThemeName(type),
                style: TextStyle(
                  color: _getTextColor(type),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: selectedIconColor, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getThemePreviewGradient(AppThemeType type) {
    switch (type) {
      case AppThemeType.cyberpunk:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D0D1A), Color(0xFF1A0D2E), Color(0xFF0D1A1A)],
        );
      case AppThemeType.clean:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF152F4E), Color(0xFF204D79), Color(0xFF2B5F88)],
        );
      case AppThemeType.pastel:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1525), Color(0xFF2A2040), Color(0xFF3A2D55)],
        );
      case AppThemeType.sunset:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D1F35), Color(0xFF8B4557), Color(0xFFE8A87C)],
        );
      case AppThemeType.ocean:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10283D), Color(0xFF1A4F6D), Color(0xFF22617E)],
        );
    }
  }

  String _getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.cyberpunk:
        return 'Cyberpunk';
      case AppThemeType.clean:
        return 'Clean';
      case AppThemeType.pastel:
        return 'Pastel';
      case AppThemeType.sunset:
        return 'Sunset';
      case AppThemeType.ocean:
        return 'Ocean';
    }
  }

  Color _getTextColor(AppThemeType type) {
    switch (type) {
      default:
        return Colors.white;
    }
  }
}

Color _onAccentTextColor(Color accent) {
  return accent.computeLuminance() > 0.55 ? Colors.black : Colors.white;
}
