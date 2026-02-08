import 'package:flutter/material.dart';
import 'package:weatherman/models/location.dart';
import 'package:weatherman/services/location_service.dart';
import 'package:weatherman/services/storage_service.dart';

/// Location provider for managing saved cities
class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;
  final StorageService _storageService;

  List<LocationModel> _savedLocations = [];
  LocationModel? _currentDeviceLocation;
  LocationModel? _selectedLocation;
  bool _isLoadingLocation = false;
  String? _locationError;

  LocationProvider({
    required LocationService locationService,
    required StorageService storageService,
  })  : _locationService = locationService,
        _storageService = storageService;

  List<LocationModel> get savedLocations => _savedLocations;
  LocationModel? get currentDeviceLocation => _currentDeviceLocation;
  LocationModel? get selectedLocation => _selectedLocation;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;

  /// All locations including current device location
  List<LocationModel> get allLocations {
    final locations = <LocationModel>[];
    if (_currentDeviceLocation != null) {
      locations.add(_currentDeviceLocation!);
    }
    locations.addAll(_savedLocations);
    return locations;
  }

  /// Initialize provider
  Future<void> init() async {
    _savedLocations = await _storageService.getSavedLocations();
    
    // Try to get last location
    final lastLocation = await _storageService.getLastLocation();
    if (lastLocation != null) {
      _selectedLocation = lastLocation;
    }
    
    notifyListeners();
  }

  /// Fetch current device location
  Future<void> fetchCurrentLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      _currentDeviceLocation = await _locationService.getCurrentLocation();
      
      // Auto-select if no location selected
      _selectedLocation ??= _currentDeviceLocation;
      
      _isLoadingLocation = false;
      notifyListeners();
    } catch (e) {
      _locationError = e.toString();
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Select a location
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    notifyListeners();
    await _storageService.setLastLocation(location);
  }

  /// Add a new saved location
  Future<void> addLocation(LocationModel location) async {
    if (_savedLocations.any((l) => l == location)) return;
    
    _savedLocations.add(location);
    notifyListeners();
    await _storageService.saveLocations(_savedLocations);
  }

  /// Remove a saved location
  Future<void> removeLocation(LocationModel location) async {
    _savedLocations.removeWhere((l) => l == location);
    notifyListeners();
    await _storageService.saveLocations(_savedLocations);
  }

  /// Reorder saved locations
  Future<void> reorderLocations(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _savedLocations.removeAt(oldIndex);
    _savedLocations.insert(newIndex, item);
    notifyListeners();
    await _storageService.saveLocations(_savedLocations);
  }

  /// Clear location error
  void clearError() {
    _locationError = null;
    notifyListeners();
  }
}
