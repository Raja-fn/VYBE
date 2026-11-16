import 'dart:math';

const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
const _idLength = 20;

/// A random id for idempotent requests (a retry reuses the same id).
String randomRequestId([Random? random]) {
  final rng = random ?? Random.secure();
  return List.generate(_idLength, (_) => _alphabet[rng.nextInt(_alphabet.length)]).join();
}
