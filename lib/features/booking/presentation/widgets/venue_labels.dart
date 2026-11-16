import '../../../../core/l10n/l10n.dart';
import '../../domain/booking_models.dart';

String venueCategoryLabel(AppLocalizations l10n, String category) => switch (category) {
  'cafe' => l10n.venueCafe,
  'food_court' => l10n.venueFoodCourt,
  'open_park' => l10n.venueOpenPark,
  'cinema' => l10n.venueCinema,
  'restaurant' => l10n.venueRestaurant,
  'mall' => l10n.venueMall,
  'theatre' => l10n.venueTheatre,
  _ => l10n.venueOther,
};

String popularityText(AppLocalizations l10n, PopularityLabel label) => switch (label) {
  PopularityLabel.hot => l10n.busyHotNow,
  PopularityLabel.busy => l10n.busyBusy,
  PopularityLabel.quiet => l10n.busyQuiet,
};

/// "1.2" — one decimal place, as in the design.
String kmText(double km) => km.toStringAsFixed(1);

/// "Cafe · 1.2 km · Hot now".
String venueLine(AppLocalizations l10n, Venue venue) => l10n.venueLine(
  venueCategoryLabel(l10n, venue.category),
  kmText(venue.distanceKm),
  popularityText(l10n, venue.popularityLabel),
);
