import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class AddressFormProvider extends ChangeNotifier {
  // --- STATE ---
  String _selectedAddressType = "Home";

  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _towerBlockController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  // --- GETTERS ---
  String get selectedAddressType => _selectedAddressType;

  TextEditingController get houseNumberController => _houseNumberController;
  TextEditingController get floorController => _floorController;
  TextEditingController get towerBlockController => _towerBlockController;
  TextEditingController get landmarkController => _landmarkController;

  // --- METHODS ---
  void setSelectedAddressType(String type) {
    _selectedAddressType = type;
    notifyListeners();
  }

  @override
  void dispose() {
    _houseNumberController.dispose();
    _floorController.dispose();
    _towerBlockController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  /// Google Map Controller (Completer)
  final Completer<GoogleMapController> _mapController = Completer();

  /// Accessor for the map controller
  Completer<GoogleMapController> get mapController => _mapController;

  /// Default Camera Position (e.g. Google HQ)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );
  CameraPosition get initialCameraPosition => _initialPosition;

  bool _isLocationGranted = false;
  bool get isLocationGranted => _isLocationGranted;

  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  String _address = "Fetching address...";
  String get address => _address;

  bool _hasInit = false; // To ensure we only request permission once

  /// Call this once from the UI to initialize (e.g. in build() using Future.microtask)
  Future<void> init() async {
    if (_hasInit) return; // Prevent multiple init calls
    _hasInit = true;
    await checkPermissionStatus();
  }

  /// Check if location permission is already granted
  Future<void> checkPermissionStatus() async {
    final status = await Permission.location.status;

    // Update our internal state accordingly
    if (status.isGranted) {
      _isLocationGranted = true;
      await fetchCurrentLocation();
    } else {
      _isLocationGranted = false;
    }
    notifyListeners();
  }

  /// Request location permission
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      _isLocationGranted = true;
      await fetchCurrentLocation();
    } else {
      _isLocationGranted = false;
    }
    notifyListeners();
  }

  /// Fetch the user's current location
  Future<void> fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      // Update internal state
      _currentLocation = newLocation;
      await moveCamera(newLocation);
      await getAddressFromCoordinates(newLocation);
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
    notifyListeners();
  }

  /// Move the camera to the specified location
  Future<void> moveCamera(LatLng location) async {
    if (_mapController.isCompleted) {
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15),
      );
    }
  }

  /// Convert [LatLng] to a human-readable address
  Future<void> getAddressFromCoordinates(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _address =
            "${place.name}, ${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
    }
    notifyListeners();
  }

  /// Confirm current location (example: print or do some logic)
  void confirmLocation() {
    if (_currentLocation != null) {
      debugPrint("Confirmed location: $_address");
      // Additional logic here...
    } else {
      debugPrint("Error: No location selected");
    }
  }

  /// Setter for the Google Map controller
  void setMapController(GoogleMapController controller) {
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
  }
}
