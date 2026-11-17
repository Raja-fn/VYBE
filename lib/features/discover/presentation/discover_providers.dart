import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_providers.dart';
import '../../../core/location/location_service.dart';
import '../../credits/data/credits_repository.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../data/discover_repository.dart';
import '../domain/companion_summary.dart';

part 'discover_providers.g.dart';

@Riverpod(keepAlive: true)
DiscoverRepository discoverRepository(Ref ref) =>
    SupabaseDiscoverRepository(functions: ref.watch(callableClientProvider), tables: ref.watch(tablesProvider));

/// Reads the device position and sends it to the server. Every discovery
/// list waits for this, so results are always around the current position.
@riverpod
Future<void> locationSync(Ref ref) async {
  final position = (await ref.watch(locationServiceProvider).current()).valueOrThrow;
  (await ref.watch(discoverRepositoryProvider).updateLocation(position)).valueOrThrow;
}

@riverpod
Future<List<CompanionSummary>> discoverResults(Ref ref) async {
  await ref.watch(locationSyncProvider.future);
  return (await ref.watch(discoverRepositoryProvider).discover(null)).valueOrThrow;
}

@riverpod
Future<List<CompanionSummary>> freeNowResults(Ref ref, FreeWindow window) async {
  await ref.watch(locationSyncProvider.future);
  return (await ref.watch(discoverRepositoryProvider).freeNow(window)).valueOrThrow;
}

@riverpod
Future<CompanionSummary> companionProfile(Ref ref, String uid) async {
  await ref.watch(locationSyncProvider.future);
  return (await ref.watch(discoverRepositoryProvider).profile(uid)).valueOrThrow;
}

@riverpod
Future<List<CompanionSummary>> savedCompanions(Ref ref) async {
  await ref.watch(locationSyncProvider.future);
  return (await ref.watch(discoverRepositoryProvider).saved()).valueOrThrow;
}

@riverpod
Stream<Set<String>> savedIds(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(const <String>{});
  return ref.watch(discoverRepositoryProvider).watchSavedIds(user.uid);
}

@Riverpod(keepAlive: true)
CreditsRepository creditsRepository(Ref ref) => SupabaseCreditsRepository(ref.watch(tablesProvider));

/// The person's own credit balance (read-only; only the server changes it).
@riverpod
Stream<int> creditBalance(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(0);
  return ref.watch(creditsRepositoryProvider).watchBalance(user.uid);
}
