import 'package:image_picker/image_picker.dart';
import 'image_picker_model.dart';
import 'image_picker_io.dart'
    if (dart.library.html) 'image_picker_web.dart' as platform_picker;

export 'image_picker_model.dart';

class ImagePickerService {
  static Future<PickedLeafImage?> pickLeafImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    return await platform_picker.pickImagePlatform(source: source);
  }
}
