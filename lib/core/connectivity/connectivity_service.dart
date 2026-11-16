import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Reports whether the device has a network connection.
abstract interface class ConnectivityService {
  Stream<bool> watchOnline();
}

class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService([Connectivity? connectivity]) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<bool> watchOnline() async* {
    yield isOnlineFrom(await _connectivity.checkConnectivity());
    yield* _connectivity.onConnectivityChanged.map(isOnlineFrom);
  }
}

/// Test double whose state can be pushed by hand.
class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({this.online = true});

  bool online;

  @override
  Stream<bool> watchOnline() => Stream.value(online);
}

bool isOnlineFrom(List<ConnectivityResult> results) => results.any((result) => result != ConnectivityResult.none);

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) => ConnectivityPlusService();

@Riverpod(keepAlive: true)
Stream<bool> isOnline(Ref ref) => ref.watch(connectivityServiceProvider).watchOnline();

/// Synchronous view of [isOnline]: assumes online until told otherwise.
@riverpod
bool isOnlineValue(Ref ref) => ref.watch(isOnlineProvider).value ?? true;
