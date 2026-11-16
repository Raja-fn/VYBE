import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:findx/core/connectivity/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('online when any connection is present', () {
    expect(isOnlineFrom([ConnectivityResult.wifi]), isTrue);
    expect(isOnlineFrom([ConnectivityResult.none, ConnectivityResult.mobile]), isTrue);
  });

  test('offline when there is no connection', () {
    expect(isOnlineFrom([ConnectivityResult.none]), isFalse);
    expect(isOnlineFrom([]), isFalse);
  });

  test('fake service reports its state', () async {
    expect(await FakeConnectivityService(online: false).watchOnline().first, isFalse);
  });
}
