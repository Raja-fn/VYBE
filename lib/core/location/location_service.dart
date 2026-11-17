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

/// Reads the phone's position as fast as possible. Distances are shown to
/// about 1 km, so a recent or coarse reading is good enough:
/// 1. a reading from the last [_memory] (screens share it);
/// 2. the phone's last known position, if it is recent;
/// 3. a quick network-based fix, giving up after [_fixTimeout].
class GeolocatorLocationService implements LocationService {
  GeolocatorLocationService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const _denied = AppFailure(FailureKind.locationDenied);
  static const _fixTimeout = Duration(seconds: 8);
  static const _memory = Duration(minutes: 2);
  static const _lastKnownMaxAge = Duration(minutes: 15);

  final DateTime Function() _now;
  ({DevicePosition position, DateTime at})? _latest;

  @override
  Future<Result<DevicePosition>> current() async {
    final latest = _latest;
    if (latest != null && _now().difference(latest.at) < _memory) return Ok(latest.position);

    if (!await Geolocator.isLocationServiceEnabled()) return const Err(_denied);
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return const Err(_denied);
    }
    return runGuarded(() async {
      var position = await Geolocator.getLastKnownPosition();
      if (position == null || _now().difference(position.timestamp) > _lastKnownMaxAge) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: _fixTimeout),
          );
        } on TimeoutException {
          // Keep whatever older reading the phone has, if any.
        }
      }
      if (position == null) throw const AppFailure(FailureKind.locationDenied);
      final result = DevicePosition(lat: position.latitude, lng: position.longitude, accuracyM: position.accuracy);
      _latest = (position: result, at: _now());
      return result;
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
  return GeolocatorLocationService();
}
