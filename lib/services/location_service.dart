import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:weatherman/models/location.dart';

/// Location service for GPS and geocoding
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permission
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current device location
  Future<LocationModel> getCurrentLocation() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException('Location services are disabled');
    }

    // Check permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    // Get position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 15),
      ),
    );

    // Try to get place name from coordinates
    String locationName = 'Current Location';
    String? admin1;
    String? country;

    try {
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        locationName = place.locality ?? 
                       place.subAdministrativeArea ?? 
                       place.administrativeArea ?? 
                       'Current Location';
        admin1 = place.administrativeArea;
        country = place.country;
      }
    } catch (_) {
      // Geocoding failed, use default name
    }

    return LocationModel(
      name: locationName,
      latitude: position.latitude,
      longitude: position.longitude,
      admin1: admin1,
      country: country,
      isCurrentLocation: true,
    );
  }

  /// Get location name from coordinates
  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality ?? 
               place.subAdministrativeArea ?? 
               place.administrativeArea ?? 
               'Unknown';
      }
    } catch (_) {
      // Geocoding failed
    }
    return 'Unknown';
  }
}

/// Custom exception for location service errors
class LocationServiceException implements Exception {
  final String message;
  
  LocationServiceException(this.message);
  
  @override
  String toString() => message;
}
