import 'dart:typed_data';

class HomeUtils {
  /// Converts a list of integers (representing image data) to a Uint8List.
  static Uint8List imageListToUint8List(List<int> imageData) {
    return Uint8List.fromList(imageData);
  }

  /// Computes a unique chatId based on the current user's UID and a contact's UID.
  static String getChatId(String currentUid, String contactUid) {
    return currentUid.compareTo(contactUid) < 0
        ? '$currentUid\_$contactUid'
        : '$contactUid\_$currentUid';
  }
}
