import 'package:nostr_signaling/nostr_signaling.dart';

void main() {
  // ===== Generare una nuova coppia di chiavi casuale =====
  print('=== Generare nuove chiavi ===');
  final newKeyPair = NostrKeys.generate();
  print('Private Key: ${newKeyPair.privateKey}');
  print('Public Key:  ${newKeyPair.publicKey}');
  print('Valida? ${newKeyPair.isValid()}');
  print('');

  // ===== Importare una coppia da una chiave privata =====
  print('=== Importare da chiave privata ===');
  const myPrivateKey = '0000000000000000000000000000000000000000000000000000000000000001';
  final keyPairFromPrivate = NostrKeys.fromPrivateKeyHex(myPrivateKey);
  print('Private Key: ${keyPairFromPrivate.privateKey}');
  print('Public Key:  ${keyPairFromPrivate.publicKey}');
  print('');

  // ===== Importare una coppia completa =====
  print('=== Importare entrambe le chiavi ===');
  const privateKey = '0000000000000000000000000000000000000000000000000000000000000001';
  const publicKey = '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798';

  try {
    final importedKeyPair = NostrKeys.fromHex(
      privateKeyHex: privateKey,
      publicKeyHex: publicKey,
    );
    print('Chiavi importate con successo!');
    print('Private Key: ${importedKeyPair.privateKey}');
    print('Public Key:  ${importedKeyPair.publicKey}');
  } catch (e) {
    print('Errore: $e');
  }
  print('');

  // ===== Validare il formato delle chiavi =====
  print('=== Validare il formato delle chiavi ===');
  const testKey = '0000000000000000000000000000000000000000000000000000000000000001';
  print('Formato privata valido? ${NostrKeys.isValidPrivateKeyFormat(testKey)}');
  print('Formato pubblica valido? ${NostrKeys.isValidPublicKeyFormat(publicKey)}');
  print('');

  // ===== Usare il toString per stampare in modo leggibile =====
  print('=== Stampa leggibile ===');
  final keyPair = NostrKeys.generate();
  print('KeyPair: $keyPair');
}
