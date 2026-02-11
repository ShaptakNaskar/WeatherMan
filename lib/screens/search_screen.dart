import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/models/location.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/widgets/cyberpunk/cyber_background.dart';

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

    // Add to saved locations
    await locationProvider.addLocation(location);
    
    // Select this location
    await locationProvider.selectLocation(location);
    
    // Fetch weather
    await weatherProvider.fetchWeather(location);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, WeatherProvider>(
      builder: (context, locationProvider, weatherProvider, _) {
        // Get current weather to mimic the background
        final currentLocation = locationProvider.selectedLocation;
        final weather = currentLocation != null
            ? weatherProvider.getWeather(currentLocation)
            : null;
        final weatherCode = weather?.current.weatherCode ?? 0;
        final isDay = weather?.current.isDay ?? true;

        return CyberpunkBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                '// SEARCH_NODE //',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  color: CyberpunkTheme.neonCyan,
                  letterSpacing: 2,
                  shadows: CyberpunkTheme.subtleCyanGlow,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: CyberpunkTheme.neonCyan),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                // Search input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CyberpunkTheme.bgPanel.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: CyberpunkTheme.neonCyan.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CyberpunkTheme.neonCyan.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: CyberpunkTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ENTER_NODE_NAME...',
                        hintStyle: TextStyle(
                          fontFamily: 'monospace',
                          color: CyberpunkTheme.textTertiary,
                          letterSpacing: 1,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: CyberpunkTheme.neonCyan,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: CyberpunkTheme.neonCyan,
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
                  ),
                ),

                // Results
                Expanded(
                  child: _buildResults(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            CyberpunkTheme.neonCyan,
          ),
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
              color: CyberpunkTheme.neonCyan.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '// AWAITING_INPUT //',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: CyberpunkTheme.textTertiary,
                letterSpacing: 2,
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
              color: CyberpunkTheme.neonMagenta.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '// NODE_NOT_FOUND //',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: CyberpunkTheme.textTertiary,
                letterSpacing: 2,
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
          onTap: () => _selectLocation(location),
        );
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final LocationModel location;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CyberpunkTheme.bgPanel.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: CyberpunkTheme.neonCyan.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: CyberpunkTheme.neonCyan.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.location_city_rounded,
          color: CyberpunkTheme.neonCyan,
        ),
        title: Text(
          location.name.toUpperCase(),
          style: TextStyle(
            fontFamily: 'monospace',
            color: CyberpunkTheme.textPrimary,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
        subtitle: Text(
          location.displayName,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: CyberpunkTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.add_circle_outline_rounded,
          color: CyberpunkTheme.neonCyan,
        ),
      ),
    );
  }
}
