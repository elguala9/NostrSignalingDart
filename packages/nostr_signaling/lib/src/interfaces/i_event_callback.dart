import 'package:nostr_signaling/nostr_signaling.dart';

/// Definizione astratta per un gestore di eventi Nostr con deduplicazione.
abstract class IEventCallback {
  /// Esegue il callback se l'evento non è mai stato processato in precedenza.
  /// 
  /// [id] è la chiave pubblica del mittente.
  /// [data] è il payload dell'evento.
  /// [hash] è l'identificatore univoco opzionale per la deduplicazione.
  void call(NostrUserId id, List<int> data, {String? hash});

}