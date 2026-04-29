// ignore_for_file: avoid_print
import 'package:dart_nostr/dart_nostr.dart';

void main() {
  const privKey1 = '0000000000000000000000000000000000000000000000000000000000000001';
  const privKey2 = '0000000000000000000000000000000000000000000000000000000000000002';
  const privKey3 = '0000000000000000000000000000000000000000000000000000000000000003';
  const privKeyLuca = '009d7edc1c7b89f2e3d4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';

  final keys = Nostr().keys;

  print('Corrected test keys:');
  print('');
  print('testPrivateKey1: $privKey1');
  print('testPublicKey1:  ${keys.derivePublicKey(privateKey: privKey1)}');
  print('');
  print('testPrivateKey2: $privKey2');
  print('testPublicKey2:  ${keys.derivePublicKey(privateKey: privKey2)}');
  print('');
  print('testPrivateKey3: $privKey3');
  print('testPublicKey3:  ${keys.derivePublicKey(privateKey: privKey3)}');
  print('');
  print('testPrivateKeyLuca: $privKeyLuca');
  print('testPublicKeyLuca:  ${keys.derivePublicKey(privateKey: privKeyLuca)}');
}
