import 'dart:async';
import 'dart:typed_data';

import 'package:vybe/core/backend/callable_client.dart';
import 'package:vybe/core/backend/file_storage.dart';
import 'package:vybe/core/location/location_service.dart';
import 'package:vybe/core/services/identity_verification/identity_verification_service.dart';
import 'package:vybe/core/services/image_capture/image_capture_service.dart';
import 'package:vybe/core/services/image_capture/photo_picker_service.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/core/utils/result.dart';
import 'package:vybe/features/booking/data/booking_repository.dart';
import 'package:vybe/features/booking/domain/booking_models.dart';
import 'package:vybe/features/chat/data/chat_repository.dart';
import 'package:vybe/features/chat/domain/chat_models.dart';
import 'package:vybe/features/credits/data/credits_repository.dart';
import 'package:vybe/features/credits/domain/credit_models.dart';
import 'package:vybe/features/discover/data/discover_repository.dart';
import 'package:vybe/features/discover/domain/companion_summary.dart';
import 'package:vybe/features/onboarding/data/account_repository.dart';
import 'package:vybe/features/onboarding/data/auth_repository.dart';
import 'package:vybe/features/onboarding/domain/account.dart';
import 'package:vybe/features/onboarding/domain/session_stage.dart';
import 'package:vybe/features/preferences/data/preferences_repository.dart';
import 'package:vybe/features/preferences/domain/preferences.dart';
import 'package:vybe/features/profile/data/profile_repository.dart';
import 'package:vybe/features/profile/domain/profile_details.dart';

/// A value that streams its current state to every new listener, then updates.
///
/// Each listener is registered the moment it subscribes, so no update can be
/// lost between the first value and later ones.
class LiveValue<T> {
  LiveValue(this._value);

  T _value;
  final _listeners = <StreamController<T>>{};

  T get value => _value;

  set value(T next) {
    _value = next;
    for (final listener in [..._listeners]) {
      listener.add(next);
    }
  }

  Stream<T> stream() {
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        controller.add(_value);
        _listeners.add(controller);
      },
      onCancel: () => _listeners.remove(controller),
    );
    return controller.stream;
  }
}

const testUid = 'test-user';
const testPhone = '+919876543210';
const validOtp = '1234';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthUser? signedIn}) : user = LiveValue(signedIn);

  final LiveValue<AuthUser?> user;
  AppFailure? requestOtpFailure;
  int refreshClaimsCalls = 0;
  final List<String> otpRequests = [];

  @override
  Stream<AuthUser?> watchUser() => user.stream();

  /// The Google account the picker returns.
  String googleEmail = 'test@example.com';

  /// Fails "Continue with Google" with this (e.g. signInCanceled).
  AppFailure? googleFailure;
  final List<String> testAccountSignIns = [];

  @override
  Future<Result<void>> signInWithGoogle() async {
    final failure = googleFailure;
    if (failure != null) return Err(failure);
    user.value = AuthUser(uid: testUid, email: googleEmail);
    return const Ok(null);
  }

  @override
  Future<Result<void>> signInWithTestGoogleAccount(String email) async {
    testAccountSignIns.add(email);
    user.value = AuthUser(uid: testUid, email: email);
    return const Ok(null);
  }

  @override
  Future<Result<OtpRequest>> requestOtp(String phoneE164, {int? resendToken}) async {
    otpRequests.add(phoneE164);
    final failure = requestOtpFailure;
    if (failure != null) return Err(failure);
    return const Ok(OtpCodeSent(verificationId: 'verification-1', resendToken: 7));
  }

  @override
  Future<Result<void>> confirmOtp({required String verificationId, required String code}) async {
    if (code != validOtp) return const Err(AppFailure(FailureKind.wrongCode));
    user.value = AuthUser(uid: testUid, phoneNumber: otpRequests.lastOrNull ?? testPhone);
    return const Ok(null);
  }

  @override
  Future<Result<void>> refreshClaims() async {
    refreshClaimsCalls += 1;
    return const Ok(null);
  }

  @override
  Future<Result<void>> signOut() async {
    user.value = null;
    return const Ok(null);
  }

  int deletions = 0;
  AppFailure? deleteFailure;

  @override
  Future<Result<void>> deleteAccount() async {
    final failure = deleteFailure;
    if (failure != null) return Err(failure);
    deletions += 1;
    user.value = null;
    return const Ok(null);
  }
}

Account testAccount({
  StepStatus selfie = StepStatus.notStarted,
  StepStatus id = StepStatus.notStarted,
  VerificationStatus status = VerificationStatus.pending,
  AccountStatus accountStatus = AccountStatus.active,
  String? reason,
}) => Account(
  uid: testUid,
  accountType: AccountType.member,
  verificationStatus: status,
  verificationSteps: VerificationSteps(phone: StepStatus.approved, selfie: selfie, id: id),
  accountStatus: accountStatus,
  verificationReason: reason,
);

final verifiedAccount = testAccount(
  selfie: StepStatus.approved,
  id: StepStatus.approved,
  status: VerificationStatus.approved,
);

class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository({Account? initial}) : account = LiveValue(initial);

  final LiveValue<Account?> account;
  AppFailure? acceptFailure;
  final List<int> acceptedVersions = [];

  @override
  Stream<Account?> watchAccount(String uid) => account.stream();

  @override
  Future<Result<void>> acceptRules({required int rulesVersion}) async {
    final failure = acceptFailure;
    if (failure != null) return Err(failure);
    acceptedVersions.add(rulesVersion);
    account.value ??= testAccount();
    return const Ok(null);
  }
}

class FakePreferencesRepository implements PreferencesRepository {
  FakePreferencesRepository({Preferences? initial}) : prefs = LiveValue(initial);

  final LiveValue<Preferences?> prefs;
  AppFailure? saveFailure;
  final List<Preferences> saved = [];

  @override
  Stream<Preferences?> watch(String uid) => prefs.stream();

  @override
  Future<Result<void>> save(String uid, Preferences preferences) async {
    final failure = saveFailure;
    if (failure != null) return Err(failure);
    saved.add(preferences);
    prefs.value = preferences;
    return const Ok(null);
  }
}

class FakeImageCapture implements ImageCaptureService {
  /// Null simulates closing the camera without a photo.
  Uint8List? next = Uint8List.fromList([1, 2, 3]);
  AppFailure? failure;
  final List<CaptureKind> captures = [];

  @override
  Future<Result<Uint8List?>> capture(CaptureKind kind) async {
    captures.add(kind);
    final error = failure;
    if (error != null) return Err(error);
    return Ok(next);
  }
}

/// Identity verification that updates the fake account the way the server
/// would, so screens and controllers see real step changes.
class ScriptedIdentityVerification implements IdentityVerificationService {
  ScriptedIdentityVerification(this.accounts);

  final FakeAccountRepository accounts;
  IdvStatus nextStatus = IdvStatus.approved;
  String? nextReason;
  AppFailure? failure;
  final List<(IdvStep, IdDocumentType?)> started = [];

  @override
  Future<Result<IdvSession>> startSession(IdvStep step, {IdDocumentType? documentType}) async {
    final error = failure;
    if (error != null) return Err(error);
    started.add((step, documentType));
    return Ok(
      IdvSession(id: 's${started.length}', step: step, expiresAt: DateTime(2100), uploadPath: 'verification/x.jpg'),
    );
  }

  @override
  Future<Result<IdvOutcome>> submitCapture({required IdvSession session, required Uint8List imageBytes}) async {
    final current = accounts.account.value!;
    final stepStatus = switch (nextStatus) {
      IdvStatus.approved => StepStatus.approved,
      IdvStatus.inReview => StepStatus.inReview,
      IdvStatus.rejected => StepStatus.rejected,
    };
    final steps = session.step == IdvStep.selfie
        ? current.verificationSteps.copyWith(selfie: stepStatus)
        : current.verificationSteps.copyWith(id: stepStatus);
    final approved = steps.selfie == StepStatus.approved && steps.id == StepStatus.approved;
    accounts.account.value = current.copyWith(
      verificationSteps: steps,
      verificationStatus: nextReason == underageReason
          ? VerificationStatus.rejected
          : approved
          ? VerificationStatus.approved
          : VerificationStatus.pending,
      verificationReason: nextReason,
    );
    return Ok(IdvOutcome(stepStatus: nextStatus, accountApproved: approved, reason: nextReason));
  }
}

class FakeCallableClient implements CallableClient {
  final List<(String, Map<String, Object?>)> calls = [];
  final Map<String, Map<String, Object?>> responses = {};
  Object? error;

  @override
  Future<Map<String, Object?>> call(String name, [Map<String, Object?> data = const {}]) async {
    calls.add((name, data));
    final e = error;
    if (e != null) throw e;
    return responses[name] ?? const {};
  }
}

class FakeFileUploader implements FileUploader {
  final List<(String, int)> uploads = [];

  final List<String> deleted = [];

  @override
  Future<void> uploadJpeg(String path, Uint8List bytes) async {
    uploads.add((path, bytes.length));
  }

  @override
  Future<void> delete(String path) async => deleted.add(path);
}

CompanionSummary testCompanion(
  String uid, {
  String? name,
  int age = 24,
  List<String> plans = const ['coffee', 'walk'],
  int distanceKm = 2,
  int spotsNearby = 3,
  DateTime? freeNowUntil,
  DateTime? freeFrom,
  DateTime? freeUntil,
  double? ratingAvg,
}) => CompanionSummary(
  uid: uid,
  displayName: name ?? uid,
  ageYears: age,
  photoPaths: const [],
  about: 'About $uid',
  activityTags: plans,
  planTypes: plans,
  ratingCount: 0,
  meetupCount: 12,
  distanceKm: distanceKm,
  spotsNearby: spotsNearby,
  prompt: const PromptAnswer(promptId: 'ideal_sunday', answer: 'Filter coffee and a sunset walk.'),
  freeNowUntil: freeNowUntil,
  freeFrom: freeFrom,
  freeUntil: freeUntil,
  ratingAvg: ratingAvg,
);

class FakeDiscoverRepository implements DiscoverRepository {
  FakeDiscoverRepository({List<CompanionSummary>? companions}) : companions = companions ?? [];

  List<CompanionSummary> companions;
  final savedIds = LiveValue<Set<String>>(<String>{});
  AppFailure? failure;
  final List<DevicePosition> locations = [];
  final List<PlanType?> discoverCalls = [];

  Result<T> _or<T>(T value) {
    final error = failure;
    return error == null ? Ok(value) : Err(error);
  }

  @override
  Future<Result<void>> updateLocation(DevicePosition position) async {
    locations.add(position);
    return _or(null);
  }

  @override
  Future<Result<List<CompanionSummary>>> discover(PlanType? plan) async {
    discoverCalls.add(plan);
    return _or(companions.where((c) => plan == null || c.planTypes.contains(plan.name)).toList());
  }

  @override
  Future<Result<List<CompanionSummary>>> freeNow(FreeWindow window) async =>
      _or(companions.where((c) => window == FreeWindow.next2h ? c.freeNowUntil != null : c.freeUntil != null).toList());

  @override
  Future<Result<CompanionSummary>> profile(String uid) async {
    final error = failure;
    if (error != null) return Err(error);
    final match = companions.where((c) => c.uid == uid).firstOrNull;
    return match == null ? const Err(AppFailure(FailureKind.notFound)) : Ok(match);
  }

  @override
  Future<Result<List<CompanionSummary>>> saved() async =>
      _or(companions.where((c) => savedIds.value.contains(c.uid)).toList());

  @override
  Stream<Set<String>> watchSavedIds(String myUid) => savedIds.stream();

  @override
  Future<Result<void>> setSaved({required String myUid, required String companionUid, required bool saved}) async {
    final error = failure;
    if (error != null) return Err(error);
    savedIds.value = saved ? {...savedIds.value, companionUid} : ({...savedIds.value}..remove(companionUid));
    return const Ok(null);
  }
}

class FakeCreditsRepository implements CreditsRepository {
  final balance = LiveValue<int>(20);

  @override
  Stream<int> watchBalance(String uid) => balance.stream();
}

/// Stands in for the server's verifyPurchase: packs and plans from the
/// bundled AppConfig, upgrades now, downgrades at renewal.
class FakePurchaseRepository implements PurchaseRepository {
  FakePurchaseRepository(this._credits);

  final FakeCreditsRepository _credits;
  final subscription = LiveValue<SubscriptionInfo>(SubscriptionInfo.free);
  final List<StorePurchase> verified = [];

  /// Fails every verify with this, until cleared.
  AppFailure? failure;

  /// Reports the payment as not cleared yet.
  bool pending = false;

  static const packs = {'vybe_credits_10': 10, 'vybe_credits_30': 30, 'vybe_credits_75': 75};
  static const plans = {'vybe_plus_monthly': (PlanTier.plus, 100), 'vybe_premium_monthly': (PlanTier.premium, 200)};
  static final renewsAt = DateTime(2026, 12, 12);

  @override
  Stream<SubscriptionInfo> watchSubscription(String uid) => subscription.stream();

  @override
  Future<Result<VerifyOutcome>> verify(StorePurchase purchase) async {
    final error = failure;
    if (error != null) return Err(error);
    final current = subscription.value;
    VerifyOutcome outcome(VerifyStatus status, int added) => VerifyOutcome(
      status: status,
      creditsAdded: added,
      balance: _credits.balance.value,
      tier: subscription.value.tier,
    );
    if (pending) return Ok(outcome(VerifyStatus.pending, 0));
    if (verified.any((p) => p.purchaseToken == purchase.purchaseToken)) {
      return Ok(outcome(VerifyStatus.alreadyGranted, 0));
    }
    verified.add(purchase);

    final plan = plans[purchase.productId];
    if (plan != null && plan.$1.index < current.tier.index) {
      subscription.value = SubscriptionInfo(tier: current.tier, renewsAt: current.renewsAt, pendingTier: plan.$1);
      return Ok(outcome(VerifyStatus.atRenewal, 0));
    }
    final added = plan?.$2 ?? packs[purchase.productId]!;
    _credits.balance.value += added;
    if (plan != null) subscription.value = SubscriptionInfo(tier: plan.$1, renewsAt: renewsAt);
    return Ok(outcome(VerifyStatus.granted, added));
  }
}

/// Location that is switched off or not allowed.
class DeniedLocationService implements LocationService {
  int settingsOpened = 0;

  @override
  Future<Result<DevicePosition>> current() async => const Err(AppFailure(FailureKind.locationDenied));

  @override
  Future<void> openSettings() async => settingsOpened += 1;
}

Venue testVenue(
  String id, {
  int rank = 1,
  double km = 1.2,
  PopularityLabel label = PopularityLabel.hot,
  List<String> plans = const ['coffee'],
}) => Venue(
  venueId: id,
  name: 'Venue $id',
  category: 'cafe',
  addressLine: 'Bandra West',
  lat: 19.0596 + rank * 0.004,
  lng: 72.8295 + rank * 0.003,
  distanceKm: km,
  planTypes: plans,
  popularityScore: 0.8,
  popularityLabel: label,
  rank: rank,
  perk: '10% off',
);

VenueSlot testSlot(String id, DateTime start, {SlotState state = SlotState.available}) =>
    VenueSlot(slotId: id, startAt: start, endAt: start.add(const Duration(hours: 1)), state: state);

class FakeBookingRepository implements BookingRepository {
  List<Venue> venues = [];
  List<VenueSlot> slots = [];
  final bookings = LiveValue<List<Booking>>(const []);
  AppFailure? requestFailure;
  AppFailure? cancelFailure;
  final List<Map<String, Object?>> requests = [];
  final List<String> cancelled = [];
  final List<({PlanType? plan, String? companionUid})> venueQueries = [];

  @override
  Future<Result<List<Venue>>> nearbyVenues({PlanType? plan, String? companionUid}) async {
    venueQueries.add((plan: plan, companionUid: companionUid));
    return Ok(venues.where((v) => plan == null || v.planTypes.contains(plan.name)).toList());
  }

  @override
  Future<Result<List<VenueSlot>>> venueSlots({
    required String venueId,
    required String dayKey,
    required String companionUid,
  }) async => Ok(slots);

  @override
  Future<Result<int>> requestBooking({
    required String requestId,
    required String companionUid,
    required String venueId,
    required String slotId,
    required PlanType plan,
    required BookingKind kind,
  }) async {
    requests.add({
      'requestId': requestId,
      'companionUid': companionUid,
      'venueId': venueId,
      'slotId': slotId,
      'plan': plan,
      'kind': kind,
    });
    final failure = requestFailure;
    if (failure != null) return Err(failure);
    return const Ok(15);
  }

  @override
  Future<Result<void>> cancel(String bookingId) async {
    final failure = cancelFailure;
    if (failure != null) return Err(failure);
    cancelled.add(bookingId);
    bookings.value = [
      for (final b in bookings.value) b.id == bookingId ? b.copyWith(status: BookingStatus.cancelled) : b,
    ];
    return const Ok(null);
  }

  @override
  Stream<List<Booking>> watchMyBookings(String uid) => bookings.stream();
}

Booking testBooking(
  String id, {
  BookingStatus status = BookingStatus.requested,
  DateTime? startAt,
  String seekerUid = testUid,
  String companionName = 'Neha',
}) {
  final start = startAt ?? DateTime.now().add(const Duration(hours: 3));
  return Booking(
    id: id,
    seekerUid: seekerUid,
    companionUid: 'neha',
    companionName: companionName,
    seekerName: 'Aarav',
    venueName: 'Harbour Bean Cafe',
    venueCategory: 'cafe',
    planType: 'coffee',
    startAt: start,
    endAt: start.add(const Duration(hours: 1)),
    status: status,
    kind: BookingKind.scheduled,
    creditCost: 5,
  );
}

/// Chat, report and block, acting like the server would.
class FakeChatRepository implements ChatRepository, SafetyRepository {
  final chats = LiveValue<List<ChatThread>>(const []);
  final Map<String, LiveValue<List<ChatMessage>>> _messages = {};
  AppFailure? sendFailure;
  AppFailure? startFailure;
  final List<String> started = [];
  final List<(String, String)> sent = [];
  final List<String> markedRead = [];
  final List<Map<String, Object?>> reports = [];
  final List<String> blocked = [];

  LiveValue<List<ChatMessage>> messagesOf(String chatId) => _messages.putIfAbsent(chatId, () => LiveValue(const []));

  static String idFor(String companionUid) => '${testUid}_$companionUid';

  @override
  Stream<List<ChatThread>> watchChats(String myUid) => chats.stream();

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId, {required int limit}) => messagesOf(chatId).stream();

  @override
  Future<Result<({String chatId, bool charged})>> startChat(String companionUid) async {
    final failure = startFailure;
    if (failure != null) return Err(failure);
    started.add(companionUid);
    final id = idFor(companionUid);
    chats.value = [...chats.value, testThread(companionUid)];
    messagesOf(id).value = [
      ChatMessage(
        id: 'start',
        type: MessageType.system,
        createdAt: DateTime(2026),
        systemKind: 'chat_started',
        credits: 1,
      ),
    ];
    return Ok((chatId: id, charged: true));
  }

  @override
  Future<Result<void>> sendMessage({required String chatId, required String text, required String clientId}) async {
    final failure = sendFailure;
    if (failure != null) return Err(failure);
    sent.add((chatId, text));
    messagesOf(chatId).value = [
      ChatMessage(id: clientId, type: MessageType.text, createdAt: DateTime.now(), senderUid: testUid, text: text),
      ...messagesOf(chatId).value,
    ];
    return const Ok(null);
  }

  @override
  Future<Result<void>> markRead(String chatId) async {
    markedRead.add(chatId);
    return const Ok(null);
  }

  @override
  Future<Result<void>> report({
    required String reportedUid,
    required ReportContext context,
    required ReportReason reason,
    String? refId,
    String? details,
  }) async {
    reports.add({'reportedUid': reportedUid, 'context': context, 'reason': reason, 'refId': refId, 'details': details});
    return const Ok(null);
  }

  @override
  Future<Result<void>> block(String uid) async {
    blocked.add(uid);
    chats.value = chats.value.where((c) => c.otherUid != uid).toList();
    return const Ok(null);
  }
}

ChatThread testThread(String companionUid, {String? name, int unread = 0, String lastText = ''}) => ChatThread(
  id: FakeChatRepository.idFor(companionUid),
  otherUid: companionUid,
  otherName: name ?? (companionUid == 'neha' ? 'Neha' : companionUid),
  seekerUid: testUid,
  companionUid: companionUid,
  status: ChatStatus.open,
  lastType: lastText.isEmpty ? MessageType.system : MessageType.text,
  lastText: lastText,
  lastAt: DateTime.now(),
  unread: unread,
);

/// The person's profile, acting like the database: photos land on the fake account.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(this.accounts);

  final FakeAccountRepository accounts;
  final details = LiveValue<ProfileDetails>(ProfileDetails.empty);
  final List<String> nameUpdates = [];
  final List<String> deletedPhotos = [];
  AppFailure? failure;

  void _setPhotos(List<String> photos) {
    final current = accounts.account.value;
    if (current != null) accounts.account.value = current.copyWith(photoPaths: photos);
  }

  @override
  Future<Result<void>> updateDisplayName(String uid, String name) async {
    nameUpdates.add('$uid:$name');
    final current = accounts.account.value;
    if (current != null) accounts.account.value = current.copyWith(displayName: name);
    return const Ok(null);
  }

  @override
  Stream<ProfileDetails> watchDetails(String uid) => details.stream();

  @override
  Future<Result<void>> saveDetails(String uid, ProfileDetails next) async {
    final error = failure;
    if (error != null) return Err(error);
    details.value = next;
    return const Ok(null);
  }

  @override
  Future<Result<List<String>>> addPhoto(
    String uid,
    Uint8List jpeg, {
    required List<String> current,
    required String photoId,
  }) async {
    final error = failure;
    if (error != null) return Err(error);
    final photos = [...current, 'photos/$uid/$photoId.jpg'];
    _setPhotos(photos);
    return Ok(photos);
  }

  @override
  Future<Result<void>> setPhotos(String uid, List<String> photos, {List<String> removed = const []}) async {
    _setPhotos(photos);
    deletedPhotos.addAll(removed);
    return const Ok(null);
  }
}

class FakePhotoPicker implements PhotoPickerService {
  /// Null simulates backing out of the picker.
  Uint8List? next = Uint8List.fromList([1, 2, 3]);
  final List<PhotoSource> picks = [];

  @override
  Future<Result<Uint8List?>> pick(PhotoSource source) async {
    picks.add(source);
    return Ok(next);
  }
}

/// Tests have no file storage: photos show their placeholder.
class FakeStorageUrlResolver implements StorageUrlResolver {
  final List<String> requested = [];

  @override
  Future<String> urlFor(String path) {
    requested.add(path);
    return Future.error(StateError('No storage in tests'));
  }
}
