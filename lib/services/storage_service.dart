import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Compress image to approximately 120KB
  Future<Uint8List> _compressImage(File imageFile, {int targetSizeKB = 120}) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    int quality = 85;
    Uint8List compressedBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
    
    // Reduce quality until we reach target size or minimum quality
    while (compressedBytes.length > targetSizeKB * 1024 && quality > 20) {
      quality -= 5;
      compressedBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
    }

    // If still too large, resize the image
    if (compressedBytes.length > targetSizeKB * 1024) {
      int scaleFactor = 1;
      while (compressedBytes.length > targetSizeKB * 1024 && scaleFactor < 4) {
        scaleFactor++;
        img.Image resized = img.copyResize(
          image,
          width: (image.width / scaleFactor).round(),
          height: (image.height / scaleFactor).round(),
        );
        compressedBytes = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
      }
    }

    return compressedBytes;
  }

  // Upload compressed image to Firebase Storage
  Future<String> uploadImage(File imageFile, String userId, String fileName) async {
    try {
      // Compress image
      Uint8List compressedBytes = await _compressImage(imageFile);
      
      // Create temporary file for compressed image
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(compressedBytes);

      // Upload to Firebase Storage
      final ref = _storage.ref().child('users/$userId/$fileName');
      final uploadTask = ref.putFile(tempFile);
      
      await uploadTask;
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      
      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting
    }
  }
}

