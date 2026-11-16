import 'dart:convert';

import 'package:flutter/services.dart';

import '../utils/app_failure.dart';
import '../utils/result.dart';
import 'app_config.dart';
import 'remote_config_source.dart';

/// Loads [AppConfig]: bundled defaults first, then Remote Config overrides.
///
/// A Remote Config failure never blocks the app. The bundled defaults are
/// always a complete, valid config.
class AppConfigRepository {
  AppConfigRepository({required AssetBundle bundle, RemoteConfigSource? remote}) : _bundle = bundle, _remote = remote;

  static const defaultsAssetPath = 'config/app_config_defaults.json';

  final AssetBundle _bundle;
  final RemoteConfigSource? _remote;

  Future<Result<AppConfig>> load() async {
    final Map<String, Object?> defaults;
    try {
      final raw = await _bundle.loadString(defaultsAssetPath);
      defaults = (jsonDecode(raw) as Map).cast<String, Object?>();
    } on Object catch (error) {
      return Err(AppFailure(FailureKind.unknown, debugMessage: '$error'));
    }

    final defaultsConfig = _parse(defaults);
    if (defaultsConfig == null) {
      return const Err(AppFailure(FailureKind.unknown, debugMessage: 'Bundled AppConfig defaults are invalid.'));
    }

    final remote = _remote;
    if (remote == null) return Ok(defaultsConfig);

    final overridesResult = await remote.fetchOverrides(defaults);
    return switch (overridesResult) {
      Ok(:final value) => Ok(_parse({...defaults, ...value}) ?? defaultsConfig),
      Err() => Ok(defaultsConfig),
    };
  }

  AppConfig? _parse(Map<String, Object?> json) {
    try {
      return AppConfig.fromJson(json);
    } on Object {
      return null;
    }
  }
}
