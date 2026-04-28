import 'package:bip340/bip340.dart' as bip340;

void main() {
  // Derive correct public keys from private keys
  final privKey1 = '0000000000000000000000000000000000000000000000000000000000000001';
  final privKey2 = '0000000000000000000000000000000000000000000000000000000000000002';
  final privKey3 = '0000000000000000000000000000000000000000000000000000000000000003';
  final privKeyLuca = '009d7edc1c7b89f2e3d4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';

  print('Corrected test keys:');
  print('');
  print('testPrivateKey1: $privKey1');
  print('testPublicKey1:  ${bip340.getPublicKey(privKey1)}');
  print('');
  print('testPrivateKey2: $privKey2');
  print('testPublicKey2:  ${bip340.getPublicKey(privKey2)}');
  print('');
  print('testPrivateKey3: $privKey3');
  print('testPublicKey3:  ${bip340.getPublicKey(privKey3)}');
  print('');
  print('testPrivateKeyLuca: $privKeyLuca');
  print('testPublicKeyLuca:  ${bip340.getPublicKey(privKeyLuca)}');
}
