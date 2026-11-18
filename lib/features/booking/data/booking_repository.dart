import '../../../core/backend/callable_client.dart';
import '../../../core/backend/tables.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';
import '../../discover/domain/companion_summary.dart';
import '../domain/booking_models.dart';

/// Venues, slots and bookings. Everything that changes state goes through
/// the server (credits, capacity and checks are enforced there).
abstract interface class BookingRepository {
  Future<Result<List<Venue>>> nearbyVenues({PlanType? plan, String? companionUid});

  Future<Result<List<VenueSlot>>> venueSlots({
    required String venueId,
    required String dayKey,
    required String companionUid,
  });

  /// Returns the new credit balance.
  Future<Result<int>> requestBooking({
    required String requestId,
    required String companionUid,
    required String venueId,
    required String slotId,
    required PlanType plan,
    required BookingKind kind,
  });

  Future<Result<void>> cancel(String bookingId);

  /// The invited person says yes or no.
  Future<Result<void>> respond(String bookingId, {required bool accept});

  /// "I'm here" at the venue.
  Future<Result<void>> checkIn(String bookingId);

  /// Private "How did it go?" after the meetup.
  Future<Result<void>> feedback(String bookingId, {required MeetFeeling felt, String? note});

  /// Bookings the person is part of, newest first.
  Stream<List<Booking>> watchMyBookings(String uid);
}

class SupabaseBookingRepository implements BookingRepository {
  SupabaseBookingRepository({required CallableClient functions, required Tables tables})
    : _functions = functions,
      _tables = tables;

  final CallableClient _functions;
  final Tables _tables;

  static List<Map<String, Object?>> _items(Map<String, Object?> data, String key) =>
      ((data[key] as List?) ?? const []).map((e) => (e as Map).cast<String, Object?>()).toList();

  @override
  Future<Result<List<Venue>>> nearbyVenues({PlanType? plan, String? companionUid}) => runGuarded(() async {
    final data = await _functions.call('nearbyVenues', {'planType': plan?.name, 'companionUid': companionUid});
    return _items(data, 'venues').map(Venue.fromJson).toList();
  });

  @override
  Future<Result<List<VenueSlot>>> venueSlots({
    required String venueId,
    required String dayKey,
    required String companionUid,
  }) => runGuarded(() async {
    final data = await _functions.call('venueSlots', {
      'venueId': venueId,
      'dayKey': dayKey,
      'companionUid': companionUid,
    });
    return _items(data, 'slots').map(VenueSlot.fromJson).toList();
  });

  @override
  Future<Result<int>> requestBooking({
    required String requestId,
    required String companionUid,
    required String venueId,
    required String slotId,
    required PlanType plan,
    required BookingKind kind,
  }) => runGuarded(() async {
    final data = await _functions.call('requestBooking', {
      'requestId': requestId,
      'companionUid': companionUid,
      'venueId': venueId,
      'slotId': slotId,
      'planType': plan.name,
      'kind': kind.name,
    });
    return (data['balance'] as num?)?.toInt() ?? 0;
  });

  @override
  Future<Result<void>> cancel(String bookingId) => runGuarded(() async {
    await _functions.call('cancelBooking', {'bookingId': bookingId});
  });

  @override
  Future<Result<void>> respond(String bookingId, {required bool accept}) => runGuarded(() async {
    await _functions.call('respondBooking', {'bookingId': bookingId, 'accept': accept});
  });

  @override
  Future<Result<void>> checkIn(String bookingId) => runGuarded(() async {
    await _functions.call('checkInBooking', {'bookingId': bookingId});
  });

  @override
  Future<Result<void>> feedback(String bookingId, {required MeetFeeling felt, String? note}) => runGuarded(() async {
    await _functions.call('meetFeedback', {'bookingId': bookingId, 'felt': felt.name, 'note': ?note});
  });

  /// Row-level security returns only bookings the person is part of.
  @override
  Stream<List<Booking>> watchMyBookings(String uid) => _tables
      .watch('bookings', primaryKey: const ['id'], orderBy: 'start_at', descending: true)
      .map((rows) => [for (final row in rows) bookingFromRow(row)]);
}

/// Builds a [Booking] from a `bookings` row.
Booking bookingFromRow(Map<String, Object?> row) {
  DateTime time(String key) => parseTime(row[key])!;
  return Booking(
    id: row['id']! as String,
    seekerUid: row['seeker_uid']! as String,
    companionUid: row['companion_uid']! as String,
    companionName: (row['companion_name'] as String?) ?? '',
    seekerName: (row['seeker_name'] as String?) ?? '',
    venueName: (row['venue_name'] as String?) ?? '',
    venueCategory: (row['venue_category'] as String?) ?? '',
    planType: (row['plan_type'] as String?) ?? '',
    startAt: time('start_at'),
    endAt: time('end_at'),
    status: BookingStatus.values.firstWhere(
      (s) => s.name == row['status'] || (s == BookingStatus.checkedIn && row['status'] == 'checked_in'),
      orElse: () => BookingStatus.requested,
    ),
    kind: row['kind'] == 'instant' ? BookingKind.instant : BookingKind.scheduled,
    creditCost: (row['credit_cost'] as num?)?.toInt() ?? 0,
    checkedInUids: _uids(row['checked_in_uids']),
    feedbackUids: _uids(row['feedback_uids']),
  );
}

List<String> _uids(Object? value) => [for (final v in (value as List?) ?? const []) v.toString()];
