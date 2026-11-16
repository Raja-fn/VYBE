import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/companion_summary.dart';

String planLabel(AppLocalizations l10n, PlanType plan) => switch (plan) {
  PlanType.coffee => l10n.planCoffee,
  PlanType.movie => l10n.planMovie,
  PlanType.event => l10n.planEvent,
  PlanType.walk => l10n.planWalk,
  PlanType.dinner => l10n.planDinner,
};

/// Plan types arrive from the server as names ("coffee"). Unknown ones are skipped.
String? planLabelFromWire(AppLocalizations l10n, String wire) {
  final plan = PlanType.values.where((p) => p.name == wire).firstOrNull;
  return plan == null ? null : planLabel(l10n, plan);
}

/// Activity tags on a profile ("Coffee meetup", "Event plus-one").
String? activityTagLabel(AppLocalizations l10n, String id) => switch (id) {
  'coffee' => l10n.tagCoffee,
  'movie' => l10n.tagMovie,
  'event' => l10n.tagEvent,
  'walk' => l10n.tagWalk,
  'dinner' => l10n.tagDinner,
  _ => null,
};

String? promptLabel(AppLocalizations l10n, String promptId) => switch (promptId) {
  'ideal_sunday' => l10n.promptIdealSunday,
  _ => null,
};

String freeWindowLabel(AppLocalizations l10n, FreeWindow window) => switch (window) {
  FreeWindow.next2h => l10n.freeNowNext2h,
  FreeWindow.tonight => l10n.freeNowTonight,
  FreeWindow.tomorrow => l10n.freeNowTomorrow,
};

/// "6 PM", "6:30 PM" in the device's time zone and locale.
String clockTime(BuildContext context, DateTime time) {
  final local = time.toLocal();
  final locale = Localizations.localeOf(context).toLanguageTag();
  return local.minute == 0 ? DateFormat.j(locale).format(local) : DateFormat.jm(locale).format(local);
}

/// "0:15" for a voice intro length.
String voiceDurationLabel(AppLocalizations l10n, int seconds) =>
    l10n.voiceDuration(seconds ~/ 60, (seconds % 60).toString().padLeft(2, '0'));
