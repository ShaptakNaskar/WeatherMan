import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/models/location.dart';
import 'package:weatherman/widgets/themed/themed_background.dart';

/// City search screen
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<LocationModel> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final weatherProvider = context.read<WeatherProvider>();

    try {
      final results = await weatherProvider.searchLocations(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _selectLocation(LocationModel location) async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();

    await locationProvider.addLocation(location);
    await locationProvider.selectLocation(location);
    await weatherProvider.fetchWeather(location);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildSearchInput(dynamic t) {
    return Container(
      decoration: BoxDecoration(
        color: t.cardColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(t.cardBorderRadius),
        border: Border.all(
          color: t.accentColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: t.cardGlowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        style: TextStyle(color: t.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search city...',
          hintStyle: TextStyle(
            color: t.textTertiary,
            letterSpacing: 1,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: t.accentColor,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: t.accentColor,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;

    return Consumer2<LocationProvider, WeatherProvider>(
      builder: (context, locationProvider, weatherProvider, _) {
        final currentLocation = locationProvider.selectedLocation;
        final weather = currentLocation != null
            ? weatherProvider.getWeather(currentLocation)
            : null;
        final weatherCode = weather?.current.weatherCode ?? 0;
        final isDay = weather?.current.isDay ?? true;

        return ThemedBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Search',
                style: TextStyle(
                  color: t.accentColor,
                  letterSpacing: 1,
                  shadows: t.subtleGlow,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: t.accentColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.immersiveSticky,
                    overlays: [],
                  );
                  return _buildLandscapeLayout(t);
                }
                SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.edgeToEdge,
                  overlays: SystemUiOverlay.values,
                );
                return _buildPortraitLayout(t);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(dynamic t) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSearchInput(t),
        ),
        Expanded(child: _buildResults(t)),
      ],
    );
  }

  Widget _buildLandscapeLayout(dynamic t) {
    return Row(
      children: [
        // Left: search input + empty state
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchInput(t),
                const SizedBox(height: 16),
                if (_searchController.text.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 48,
                            color: t.accentColor.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Search for a city',
                            style: TextStyle(
                              fontSize: 13,
                              color: t.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
        ),
        // Divider
        Container(
          width: 1,
          color: t.textTertiary.withValues(alpha: 0.15),
        ),
        // Right: results
        Expanded(
          child: _searchController.text.isEmpty
              ? const SizedBox.shrink()
              : _buildResults(t),
        ),
      ],
    );
  }

  Widget _buildResults(dynamic t) {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(t.accentColor),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: t.accentColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a city',
              style: TextStyle(
                fontSize: 14,
                color: t.textTertiary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 64,
              color: t.accentColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 14,
                color: t.textTertiary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return _SearchResultItem(
          location: location,
          theme: t,
          onTap: () => _selectLocation(location),
        );
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final LocationModel location;
  final VoidCallback onTap;
  final dynamic theme;

  const _SearchResultItem({
    required this.location,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: t.cardColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(t.cardBorderRadius),
        border: Border.all(
          color: t.accentColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: t.cardGlowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.location_city_rounded,
          color: t.accentColor,
        ),
        title: Text(
          location.name,
          style: TextStyle(
            color: t.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          location.displayName,
          style: TextStyle(
            fontSize: 12,
            color: t.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.add_circle_outline_rounded,
          color: t.accentColor,
        ),
      ),
    );
  }
}
