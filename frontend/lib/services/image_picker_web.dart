// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'image_picker_model.dart';

Future<PickedLeafImage?> pickImagePlatform({ImageSource source = ImageSource.gallery}) async {
  // First try image_picker if available
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
  } catch (_) {
    // Missing plugin or web channel error - fallback gracefully to direct HTML file input
  }

  // Fallback: Direct HTML file input for web browsers
  try {
    final completer = Completer<PickedLeafImage?>();
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    if (source == ImageSource.camera) {
      uploadInput.setAttribute('capture', 'environment');
    }
    
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.onLoadEnd.listen((e) {
          if (reader.result != null) {
            final bytes = Uint8List.fromList(reader.result as List<int>);
            completer.complete(
              PickedLeafImage(
                name: file.name,
                bytes: bytes,
                sizeBytes: file.size,
              ),
            );
          } else {
            completer.complete(null);
          }
        });
        reader.onError.listen((_) => completer.complete(null));
        reader.readAsArrayBuffer(file);
      } else {
        completer.complete(null);
      }
    });

    uploadInput.click();
    return await completer.future;
  } catch (e) {
    return null;
  }
}
