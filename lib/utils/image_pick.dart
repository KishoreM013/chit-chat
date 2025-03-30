import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ImageUtils {
  static Future<Uint8List?> getImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    return image != null ? await image.readAsBytes() : null;
  }

  static Future<Uint8List?> getImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    return image != null ? await image.readAsBytes() : null;
  }
}
