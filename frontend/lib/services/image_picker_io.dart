import 'package:image_picker/image_picker.dart';
import 'image_picker_model.dart';

Future<PickedLeafImage?> pickImagePlatform({ImageSource source = ImageSource.gallery}) async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      return PickedLeafImage(
        name: picked.name,
        bytes: bytes,
        sizeBytes: bytes.length,
      );
    }
  } catch (e) {
    // Missing plugin or permission error caught
  }
  return null;
}
