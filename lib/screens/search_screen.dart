import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/location.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/widgets/backgrounds/dynamic_background.dart';
import 'package:weatherman/widgets/common/shimmer_loading.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  List<LocationModel> _results = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void initState() { super.initState(); _focus.requestFocus(); }

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); _debounce?.cancel(); super.dispose(); }

  void _onChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) { setState(() { _results = []; _searching = false; }); return; }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(q));
  }

  Future<void> _search(String q) async {
    try {
      final r = await context.read<WeatherProvider>().searchLocations(q);
      if (mounted) setState(() { _results = r; _searching = false; });
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _select(LocationModel loc) async {
    HapticFeedback.selectionClick();
    final locP = context.read<LocationProvider>();
    final wP = context.read<WeatherProvider>();
    await locP.addLocation(loc);
    await locP.selectLocation(loc);
    await wP.fetchWeather(loc);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, WeatherProvider>(
      builder: (context, locP, wP, _) {
        final w = locP.selectedLocation != null ? wP.getWeather(locP.selectedLocation!) : null;
        return DynamicBackground(
          weatherCode: w?.current.weatherCode ?? 0,
          isDay: w?.current.isDay ?? true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent, elevation: 0,
              title: Text('Search City', style: DesignSystem.conditionLabel),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(children: [
              Padding(
                padding: const EdgeInsets.all(DesignSystem.spacingM),
                child: PrimaryGlassCard(
                  child: TextField(
                    controller: _ctrl, focusNode: _focus,
                    onChanged: _onChanged,
                    style: DesignSystem.bodyText,
                    decoration: InputDecoration(
                      hintText: 'Search for a city...',
                      hintStyle: DesignSystem.caption,
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: DesignSystem.textSecondary),
                      suffixIcon: _ctrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, size: 20, color: DesignSystem.textSecondary),
                              onPressed: () { _ctrl.clear(); _onChanged(''); },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildResults()),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildResults() {
    if (_searching) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
        child: Column(children: List.generate(3, (_) {
          return const Padding(
            padding: EdgeInsets.only(bottom: DesignSystem.spacingS),
            child: ShimmerRow(),
          );
        })),
      );
    }
    if (_ctrl.text.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_rounded, size: 56, color: DesignSystem.textTertiary),
        const SizedBox(height: DesignSystem.spacingM),
        Text('Search for a city', style: DesignSystem.caption),
      ]));
    }
    if (_results.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.location_off_rounded, size: 56, color: DesignSystem.textTertiary),
        const SizedBox(height: DesignSystem.spacingM),
        Text('No cities found', style: DesignSystem.caption),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final loc = _results[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignSystem.spacingS),
          child: GestureDetector(
            onTap: () => _select(loc),
            child: SubtleGlassCard(child: Row(children: [
              Icon(Icons.location_city_rounded, size: 20, color: DesignSystem.textSecondary),
              const SizedBox(width: DesignSystem.spacingS),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(loc.name, style: DesignSystem.bodyText),
                Text(loc.displayName, style: DesignSystem.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Icon(Icons.add_circle_outline, size: 20, color: DesignSystem.textSecondary),
            ])),
          ),
        );
      },
    );
  }
}
