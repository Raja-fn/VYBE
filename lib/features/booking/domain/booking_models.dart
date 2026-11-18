import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_models.freezed.dart';
part 'booking_models.g.dart';

enum PopularityLabel { hot, busy, quiet }

/// A verified public venue near the seeker. Venue locations are public, so
/// exact coordinates and distance are fine to show.
@freezed
abstract class Venue with _$Venue {
  const factory Venue({
    required String venueId,
    required String name,
    required String category,
    required String addressLine,
    required double lat,
    required double lng,
    required double distanceKm,
    required List<String> planTypes,
    required double popularityScore,
    @JsonKey(unknownEnumValue: PopularityLabel.quiet) required PopularityLabel popularityLabel,
    required int rank,
    String? perk,
  }) = _Venue;

  factory Venue.fromJson(Map<String, Object?> json) => _$VenueFromJson(json);
}

enum SlotState {
  available,
  past,
  closed,
  full,
  @JsonValue('companion_unavailable')
  companionUnavailable,
}

@freezed
abstract class VenueSlot with _$VenueSlot {
  const factory VenueSlot({
    required String slotId,
    required DateTime startAt,
    required DateTime endAt,
    @JsonKey(unknownEnumValue: SlotState.closed) required SlotState state,
  }) = _VenueSlot;

  const VenueSlot._();

  factory VenueSlot.fromJson(Map<String, Object?> json) => _$VenueSlotFromJson(json);

  bool get isBookable => state == SlotState.available;
}

enum BookingStatus {
  requested,
  accepted,
  declined,
  cancelled,
  @JsonValue('checked_in')
  checkedIn,
  completed,
  disputed,
}

enum BookingKind { scheduled, instant }

/// A booking as stored in `bookings/{id}` (names are copied in by the server).
@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String seekerUid,
    required String companionUid,
    required String companionName,
    required String seekerName,
    required String venueName,
    required String venueCategory,
    required String planType,
    required DateTime startAt,
    required DateTime endAt,
    required BookingStatus status,
    required BookingKind kind,
    required int creditCost,

    /// Who has tapped "I'm here" at the venue.
    @Default(<String>[]) List<String> checkedInUids,

    /// Who has said how the meetup went (the answers themselves stay private).
    @Default(<String>[]) List<String> feedbackUids,
  }) = _Booking;

  const Booking._();

  /// Mirrors the server rule: either person, before the start, while requested or accepted.
  bool canCancel(DateTime now) =>
      (status == BookingStatus.requested || status == BookingStatus.accepted) && startAt.isAfter(now);

  /// A request nobody answered before its time. Requests never expire, but
  /// a time that has passed cannot be met any more.
  bool timePassed(DateTime now) => status == BookingStatus.requested && !startAt.isAfter(now);

  /// The invited person can accept or decline until the start.
  bool canRespond(String? me, DateTime now) =>
      me == companionUid && status == BookingStatus.requested && startAt.isAfter(now);

  bool get isConfirmed => status == BookingStatus.accepted || status == BookingStatus.checkedIn;

  /// "I'm here" is open from [before] ahead of the start until [after] past it.
  bool canCheckIn(String? me, DateTime now, {required Duration before, required Duration after}) =>
      me != null &&
      isConfirmed &&
      !checkedInUids.contains(me) &&
      !now.isBefore(startAt.subtract(before)) &&
      !now.isAfter(startAt.add(after));

  /// "How did it go?" is open from the start for [meetFeedbackWindow] after the end.
  bool canGiveFeedback(String? me, DateTime now) =>
      me != null &&
      (isConfirmed || status == BookingStatus.completed) &&
      !feedbackUids.contains(me) &&
      !now.isBefore(startAt) &&
      !now.isAfter(endAt.add(meetFeedbackWindow));
}

/// Mirrors the server's FEEDBACK_DAYS.
const meetFeedbackWindow = Duration(days: 14);

/// The private answer to "How did it go?".
enum MeetFeeling { good, okay, unsafe }
