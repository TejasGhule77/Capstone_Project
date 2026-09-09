import 'dart:typed_data';

class PickedLeafImage {
  final String name;
  final Uint8List bytes;
  final int sizeBytes;

  PickedLeafImage({
    required this.name,
    required this.bytes,
    required this.sizeBytes,
  });
}
