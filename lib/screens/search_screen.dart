import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/theme.dart';
import 'package:weatherman/models/location.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/widgets/backgrounds/dynamic_background.dart';

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

  // Text shadows for legibility on light backgrounds
  static const List<Shadow> _textShadows = [
    Shadow(
      color: Color(0x80000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

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

        return DynamicBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Search City',
                style: TextStyle(shadows: _textShadows),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
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
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
                        color: Colors.white,
                        shadows: _textShadows,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search for a city...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          shadows: _textShadows,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                          shadows: _textShadows,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  shadows: _textShadows,
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
            Colors.white.withValues(alpha: 0.7),
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
              color: Colors.white.withValues(alpha: 0.4),
              shadows: _textShadows,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a city',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                shadows: _textShadows,
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
              color: Colors.white.withValues(alpha: 0.4),
              shadows: _textShadows,
            ),
            const SizedBox(height: 16),
            Text(
              'No cities found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                shadows: _textShadows,
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

  // Text shadows for legibility
  static const List<Shadow> _textShadows = [
    Shadow(
      color: Color(0x80000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  const _SearchResultItem({
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.location_city_rounded,
          color: Colors.white.withValues(alpha: 0.8),
          shadows: _textShadows,
        ),
        title: Text(
          location.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            shadows: _textShadows,
          ),
        ),
        subtitle: Text(
          location.displayName,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            shadows: _textShadows,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.add_circle_outline_rounded,
          color: Colors.white.withValues(alpha: 0.8),
          shadows: _textShadows,
        ),
      ),
    );
  }
}
