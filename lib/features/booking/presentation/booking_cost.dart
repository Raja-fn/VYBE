import '../../../l10n/app_localizations.dart';

/// "Free" when booking costs nothing (the default), otherwise "5 credits".
String bookingCostLabel(AppLocalizations l10n, int cost) => cost <= 0 ? l10n.costFree : l10n.creditsCount(cost);
