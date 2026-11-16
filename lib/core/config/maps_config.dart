/// Google Maps is switched on per build with `--dart-define=MAPS_ENABLED=true`
/// once a key is configured (android/local.properties `MAPS_API_KEY`,
/// ios/Flutter/Secrets.xcconfig `MAPS_API_KEY`). Without it the app draws its
/// own simple map, so everything works with no key.
abstract final class MapsConfig {
  static const enabled = bool.fromEnvironment('MAPS_ENABLED');
}
