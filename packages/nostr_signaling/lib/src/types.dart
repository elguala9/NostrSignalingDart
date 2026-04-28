class NostrEvent {
  final String id;
  final String pubkey;
  final int createdAt;
  final int kind;
  final List<List<String>> tags;
  final String content;
  final String sig;

  NostrEvent({
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.kind,
    required this.tags,
    required this.content,
    required this.sig,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'pubkey': pubkey,
    'created_at': createdAt,
    'kind': kind,
    'tags': tags,
    'content': content,
    'sig': sig,
  };
}

class CompressedData {
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final List<int> data;
  final int timestamp;

  CompressedData({
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.data,
    required this.timestamp,
  });
}

typedef NostrId = String; // id di un utente sulla rete nostr
