// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookingRepository)
const bookingRepositoryProvider = BookingRepositoryProvider._();

final class BookingRepositoryProvider
    extends
        $FunctionalProvider<
          BookingRepository,
          BookingRepository,
          BookingRepository
        >
    with $Provider<BookingRepository> {
  const BookingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookingRepository create(Ref ref) {
    return bookingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingRepository>(value),
    );
  }
}

String _$bookingRepositoryHash() => r'91ae1f4b00290f9bb407b3fb39449181abd3b1cf';

/// The device position, for centring the map on the person.

@ProviderFor(myPosition)
const myPositionProvider = MyPositionProvider._();

/// The device position, for centring the map on the person.

final class MyPositionProvider
    extends
        $FunctionalProvider<
          AsyncValue<DevicePosition>,
          DevicePosition,
          FutureOr<DevicePosition>
        >
    with $FutureModifier<DevicePosition>, $FutureProvider<DevicePosition> {
  /// The device position, for centring the map on the person.
  const MyPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPositionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPositionHash();

  @$internal
  @override
  $FutureProviderElement<DevicePosition> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DevicePosition> create(Ref ref) {
    return myPosition(ref);
  }
}

String _$myPositionHash() => r'a7794aa70bd36d932eeb8c0faf87f68c28c755b2';

/// "Best spots to meet", optionally for one plan and reachable by one companion.

@ProviderFor(nearbyVenues)
const nearbyVenuesProvider = NearbyVenuesFamily._();

/// "Best spots to meet", optionally for one plan and reachable by one companion.

final class NearbyVenuesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Venue>>,
          List<Venue>,
          FutureOr<List<Venue>>
        >
    with $FutureModifier<List<Venue>>, $FutureProvider<List<Venue>> {
  /// "Best spots to meet", optionally for one plan and reachable by one companion.
  const NearbyVenuesProvider._({
    required NearbyVenuesFamily super.from,
    required ({PlanType? plan, String? companionUid}) super.argument,
  }) : super(
         retry: null,
         name: r'nearbyVenuesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyVenuesHash();

  @override
  String toString() {
    return r'nearbyVenuesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Venue>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Venue>> create(Ref ref) {
    final argument = this.argument as ({PlanType? plan, String? companionUid});
    return nearbyVenues(
      ref,
      plan: argument.plan,
      companionUid: argument.companionUid,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyVenuesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyVenuesHash() => r'e56b4eebf2630fbf79a1550af5a4b78ef0a729c2';

/// "Best spots to meet", optionally for one plan and reachable by one companion.

final class NearbyVenuesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Venue>>,
          ({PlanType? plan, String? companionUid})
        > {
  const NearbyVenuesFamily._()
    : super(
        retry: null,
        name: r'nearbyVenuesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// "Best spots to meet", optionally for one plan and reachable by one companion.

  NearbyVenuesProvider call({PlanType? plan, String? companionUid}) =>
      NearbyVenuesProvider._(
        argument: (plan: plan, companionUid: companionUid),
        from: this,
      );

  @override
  String toString() => r'nearbyVenuesProvider';
}

@ProviderFor(venueSlots)
const venueSlotsProvider = VenueSlotsFamily._();

final class VenueSlotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VenueSlot>>,
          List<VenueSlot>,
          FutureOr<List<VenueSlot>>
        >
    with $FutureModifier<List<VenueSlot>>, $FutureProvider<List<VenueSlot>> {
  const VenueSlotsProvider._({
    required VenueSlotsFamily super.from,
    required ({String venueId, String dayKey, String companionUid})
    super.argument,
  }) : super(
         retry: null,
         name: r'venueSlotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$venueSlotsHash();

  @override
  String toString() {
    return r'venueSlotsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<VenueSlot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VenueSlot>> create(Ref ref) {
    final argument =
        this.argument as ({String venueId, String dayKey, String companionUid});
    return venueSlots(
      ref,
      venueId: argument.venueId,
      dayKey: argument.dayKey,
      companionUid: argument.companionUid,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VenueSlotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$venueSlotsHash() => r'49a4c098156ee409d46a0fcdeea00fe923f15cce';

final class VenueSlotsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<VenueSlot>>,
          ({String venueId, String dayKey, String companionUid})
        > {
  const VenueSlotsFamily._()
    : super(
        retry: null,
        name: r'venueSlotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VenueSlotsProvider call({
    required String venueId,
    required String dayKey,
    required String companionUid,
  }) => VenueSlotsProvider._(
    argument: (venueId: venueId, dayKey: dayKey, companionUid: companionUid),
    from: this,
  );

  @override
  String toString() => r'venueSlotsProvider';
}

@ProviderFor(myBookings)
const myBookingsProvider = MyBookingsProvider._();

final class MyBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Booking>>,
          List<Booking>,
          Stream<List<Booking>>
        >
    with $FutureModifier<List<Booking>>, $StreamProvider<List<Booking>> {
  const MyBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBookingsHash();

  @$internal
  @override
  $StreamProviderElement<List<Booking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Booking>> create(Ref ref) {
    return myBookings(ref);
  }
}

String _$myBookingsHash() => r'6befa8fe003d5a8f8eea1621afcd6e9ecedf5c14';

/// Screen 6: choosing a venue, day and time, then sending the request.

@ProviderFor(BookSpotController)
const bookSpotControllerProvider = BookSpotControllerFamily._();

/// Screen 6: choosing a venue, day and time, then sending the request.
final class BookSpotControllerProvider
    extends $NotifierProvider<BookSpotController, BookSpotState> {
  /// Screen 6: choosing a venue, day and time, then sending the request.
  const BookSpotControllerProvider._({
    required BookSpotControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookSpotControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookSpotControllerHash();

  @override
  String toString() {
    return r'bookSpotControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BookSpotController create() => BookSpotController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookSpotState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookSpotState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookSpotControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookSpotControllerHash() =>
    r'cd8b5d2bbaadc57bb536ee9a4c5d203e2da2b259';

/// Screen 6: choosing a venue, day and time, then sending the request.

final class BookSpotControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          BookSpotController,
          BookSpotState,
          BookSpotState,
          BookSpotState,
          String
        > {
  const BookSpotControllerFamily._()
    : super(
        retry: null,
        name: r'bookSpotControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Screen 6: choosing a venue, day and time, then sending the request.

  BookSpotControllerProvider call(String companionUid) =>
      BookSpotControllerProvider._(argument: companionUid, from: this);

  @override
  String toString() => r'bookSpotControllerProvider';
}

/// Screen 6: choosing a venue, day and time, then sending the request.

abstract class _$BookSpotController extends $Notifier<BookSpotState> {
  late final _$args = ref.$arg as String;
  String get companionUid => _$args;

  BookSpotState build(String companionUid);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<BookSpotState, BookSpotState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BookSpotState, BookSpotState>,
              BookSpotState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Either person cancels before the start. Credits are not refunded.

@ProviderFor(CancelBooking)
const cancelBookingProvider = CancelBookingProvider._();

/// Either person cancels before the start. Credits are not refunded.
final class CancelBookingProvider
    extends $AsyncNotifierProvider<CancelBooking, void> {
  /// Either person cancels before the start. Credits are not refunded.
  const CancelBookingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelBookingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelBookingHash();

  @$internal
  @override
  CancelBooking create() => CancelBooking();
}

String _$cancelBookingHash() => r'c2578f172af73823da5cbf33ed0514cac860a685';

/// Either person cancels before the start. Credits are not refunded.

abstract class _$CancelBooking extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

/// Accept or decline, "I'm here" and "How did it go?". Each returns the
/// failure, or null when it worked; the bookings stream shows the result.

@ProviderFor(MeetupActions)
const meetupActionsProvider = MeetupActionsProvider._();

/// Accept or decline, "I'm here" and "How did it go?". Each returns the
/// failure, or null when it worked; the bookings stream shows the result.
final class MeetupActionsProvider
    extends $AsyncNotifierProvider<MeetupActions, void> {
  /// Accept or decline, "I'm here" and "How did it go?". Each returns the
  /// failure, or null when it worked; the bookings stream shows the result.
  const MeetupActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'meetupActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$meetupActionsHash();

  @$internal
  @override
  MeetupActions create() => MeetupActions();
}

String _$meetupActionsHash() => r'2a58db3de8ebc7e1d03832992c77b9527358a587';

/// Accept or decline, "I'm here" and "How did it go?". Each returns the
/// failure, or null when it worked; the bookings stream shows the result.

abstract class _$MeetupActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
