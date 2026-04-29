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
