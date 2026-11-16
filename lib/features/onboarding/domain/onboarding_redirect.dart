import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import 'session_stage.dart';

/// Where the router should send the person, or null to stay put.
///
/// Pure, so every stage/location combination is unit-tested.
String? onboardingRedirect({
  required AsyncValue<SessionStage> stage,
  required bool consentGiven,
  required String location,
}) {
  if (location == AppRoutes.devComponents) return null;

  if (stage.hasError) return location == AppRoutes.start ? null : AppRoutes.start;
  if (!stage.hasValue) return null;

  String? goTo(String target) => location == target ? null : target;

  return switch (stage.requireValue) {
    SignedOut() || NeedsAccount() => consentGiven ? goTo(AppRoutes.verify) : goTo(AppRoutes.rules),
    NeedsVerification() => goTo(AppRoutes.verify),
    Suspended() => goTo(AppRoutes.suspended),
    NeedsPreferences() => goTo(AppRoutes.preferences),
    Ready() => _onboardingLocations.contains(location) ? AppRoutes.home : null,
  };
}

const _onboardingLocations = {
  AppRoutes.start,
  AppRoutes.rules,
  AppRoutes.verify,
  AppRoutes.preferences,
  AppRoutes.suspended,
};
