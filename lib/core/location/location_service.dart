import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../config/app_env.dart';
import '../utils/app_failure.dart';
import '../utils/result.dart';
import '../utils/run_guarded.dart';

part 'location_service.g.dart';

/// The device's own position. Only ever sent to our server, never to other users.
class DevicePosition {
  const DevicePosition({required this.lat, required this.lng, required this.accuracyM});

  final double lat;
  final double lng;
  final double accuracyM;
}

abstract interface class LocationService {
  /// Asks for permission if needed, then reads the current position.
  Future<Result<DevicePosition>> current();

  /// Opens the system settings so the person can allow location.
  Future<void> openSettings();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static const _denied = AppFailure(FailureKind.locationDenied);
  static const _fixTimeout = Duration(seconds: 15);

  @override
  Future<Result<DevicePosition>> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) return const Err(_denied);
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return const Err(_denied);
    }
    return runGuarded(() async {
      Position? position;
      try {
        // Distances are shown to about 1 km, so a quick, normal-accuracy fix is enough.
        // Indoors a precise fix can take very long; give up after [_fixTimeout].
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: _fixTimeout),
        );
      } on TimeoutException {
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) throw const AppFailure(FailureKind.locationDenied);
      return DevicePosition(lat: position.latitude, lng: position.longitude, accuracyM: position.accuracy);
    });
  }

  @override
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }
}

/// Always reports one fixed point (tests, and emulators without GPS).
class FixedLocationService implements LocationService {
  const FixedLocationService(this.position);

  final DevicePosition position;

  @override
  Future<Result<DevicePosition>> current() async => Ok(position);

  @override
  Future<void> openSettings() async {}
}

/// Every build uses the phone's real location. An emulator without GPS can
/// pretend to be at the launch city centre with
/// `--dart-define=FIXED_LOCATION=true` (test builds only).
const _useFixedLocation = bool.fromEnvironment('FIXED_LOCATION');

@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) {
  if (ref.watch(appEnvProvider).isDev && _useFixedLocation) {
    final city = ref.watch(appConfigProvider).launchCity;
    return FixedLocationService(DevicePosition(lat: city.lat, lng: city.lng, accuracyM: 0));
  }
  return const GeolocatorLocationService();
}
