import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_providers.dart';
import '../../../core/location/location_service.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/utils/ids.dart';
import '../../../core/utils/result.dart';
import '../../discover/domain/companion_summary.dart';
import '../../discover/presentation/discover_providers.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../data/booking_repository.dart';
import '../domain/booking_models.dart';

part 'booking_providers.freezed.dart';
part 'booking_providers.g.dart';

@Riverpod(keepAlive: true)
BookingRepository bookingRepository(Ref ref) =>
    SupabaseBookingRepository(functions: ref.watch(callableClientProvider), tables: ref.watch(tablesProvider));

/// The device position, for centring the map on the person.
@riverpod
Future<DevicePosition> myPosition(Ref ref) async => (await ref.watch(locationServiceProvider).current()).valueOrThrow;

/// "Best spots to meet", optionally for one plan and reachable by one companion.
@riverpod
Future<List<Venue>> nearbyVenues(Ref ref, {PlanType? plan, String? companionUid}) async {
  await ref.watch(locationSyncProvider.future);
  return (await ref.watch(bookingRepositoryProvider).nearbyVenues(plan: plan, companionUid: companionUid)).valueOrThrow;
}

@riverpod
Future<List<VenueSlot>> venueSlots(
  Ref ref, {
  required String venueId,
  required String dayKey,
  required String companionUid,
}) async {
  await ref.watch(locationSyncProvider.future);
  return (await ref
          .watch(bookingRepositoryProvider)
          .venueSlots(venueId: venueId, dayKey: dayKey, companionUid: companionUid))
      .valueOrThrow;
}

@riverpod
Stream<List<Booking>> myBookings(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(bookingRepositoryProvider).watchMyBookings(user.uid);
}

/// yyyy-MM-dd for a local calendar day; matches the server's `dayKey`.
String dayKeyOf(DateTime local) =>
    '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';

@freezed
abstract class BookSpotState with _$BookSpotState {
  const factory BookSpotState({
    required String requestId,
    required DateTime day,
    String? venueId,
    String? slotId,
    @Default(false) bool submitting,
    @Default(false) bool sent,
    AppFailure? failure,
  }) = _BookSpotState;
}

/// Screen 6: choosing a venue, day and time, then sending the request.
@riverpod
class BookSpotController extends _$BookSpotController {
  @override
  BookSpotState build(String companionUid) {
    final now = DateTime.now();
    return BookSpotState(requestId: randomRequestId(), day: DateTime(now.year, now.month, now.day));
  }

  void selectVenue(String venueId) {
    if (venueId == state.venueId) return;
    state = state.copyWith(venueId: venueId, slotId: null, failure: null);
  }

  void selectDay(DateTime day) =>
      state = state.copyWith(day: DateTime(day.year, day.month, day.day), slotId: null, failure: null);

  void selectSlot(String slotId) => state = state.copyWith(slotId: slotId, failure: null);

  /// [venueId] is passed in because the screen may be showing a default
  /// venue (the best-ranked spot) that was never explicitly selected.
  Future<void> confirm({required String venueId, required PlanType plan, required BookingKind kind}) async {
    final slotId = state.slotId;
    if (slotId == null || state.submitting) return;
    state = state.copyWith(submitting: true, failure: null);
    final result = await ref
        .read(bookingRepositoryProvider)
        .requestBooking(
          requestId: state.requestId,
          companionUid: companionUid,
          venueId: venueId,
          slotId: slotId,
          plan: plan,
          kind: kind,
        );
    final failure = result.failureOrNull;
    if (failure == null) {
      state = state.copyWith(submitting: false, sent: true);
      return;
    }
    // A new id after a definite rejection; keep it after network errors so a
    // retry can never be charged twice.
    final keepId = failure.kind == FailureKind.network || failure.kind == FailureKind.unknown;
    state = state.copyWith(
      submitting: false,
      failure: failure,
      requestId: keepId ? state.requestId : randomRequestId(),
      slotId: failure.kind == FailureKind.slotFull || failure.kind == FailureKind.companionUnavailable
          ? null
          : state.slotId,
    );
    if (failure.kind == FailureKind.slotFull || failure.kind == FailureKind.companionUnavailable) {
      ref.invalidate(venueSlotsProvider);
    }
  }
}

/// Either person cancels before the start. Credits are not refunded.
@riverpod
class CancelBooking extends _$CancelBooking {
  @override
  FutureOr<void> build() {}

  Future<AppFailure?> cancel(String bookingId) async {
    state = const AsyncLoading();
    final result = await ref.read(bookingRepositoryProvider).cancel(bookingId);
    state = const AsyncData(null);
    return result.failureOrNull;
  }
}

/// Accept or decline, "I'm here" and "How did it go?". Each returns the
/// failure, or null when it worked; the bookings stream shows the result.
@riverpod
class MeetupActions extends _$MeetupActions {
  @override
  FutureOr<void> build() {}

  Future<AppFailure?> _run(Future<Result<void>> Function(BookingRepository repo) action) async {
    state = const AsyncLoading();
    final result = await action(ref.read(bookingRepositoryProvider));
    state = const AsyncData(null);
    return result.failureOrNull;
  }

  Future<AppFailure?> respond(String bookingId, {required bool accept}) =>
      _run((repo) => repo.respond(bookingId, accept: accept));

  Future<AppFailure?> checkIn(String bookingId) => _run((repo) => repo.checkIn(bookingId));

  Future<AppFailure?> feedback(String bookingId, {required MeetFeeling felt, String? note}) =>
      _run((repo) => repo.feedback(bookingId, felt: felt, note: note));
}
