import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Compress image to approximately 30KB
  Future<Uint8List> _compressImage(File imageFile, {int targetSizeKB = 30}) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final targetSizeBytes = targetSizeKB * 1024;
    img.Image currentImage = image;
    int quality = 85;
    int scaleFactor = 1;
    
    // Try compressing with original size first
    Uint8List compressedBytes = Uint8List.fromList(img.encodeJpg(currentImage, quality: quality));
    
    // Reduce quality until we reach target size or minimum quality
    int iteration = 0;
    while (compressedBytes.length > targetSizeBytes && quality > 10) {
      quality -= 5;
      compressedBytes = Uint8List.fromList(img.encodeJpg(currentImage, quality: quality));
      // Yield control periodically to allow UI updates
      if (iteration % 3 == 0) {
        await Future.delayed(const Duration(milliseconds: 1));
      }
      iteration++;
    }

    // If still too large, resize the image progressively
    iteration = 0;
    while (compressedBytes.length > targetSizeBytes && scaleFactor < 10) {
      scaleFactor++;
      currentImage = img.copyResize(
        image,
        width: (image.width / scaleFactor).round().clamp(100, image.width),
        height: (image.height / scaleFactor).round().clamp(100, image.height),
      );
      
      // Try with moderate quality first
      quality = 60;
      compressedBytes = Uint8List.fromList(img.encodeJpg(currentImage, quality: quality));
      
      // Reduce quality further if needed
      int qualityIteration = 0;
      while (compressedBytes.length > targetSizeBytes && quality > 10) {
        quality -= 5;
        compressedBytes = Uint8List.fromList(img.encodeJpg(currentImage, quality: quality));
        // Yield control periodically
        if (qualityIteration % 3 == 0) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
        qualityIteration++;
      }
      
      // Yield control after each resize iteration
      if (iteration % 2 == 0) {
        await Future.delayed(const Duration(milliseconds: 1));
      }
      iteration++;
    }

    // Final fallback: aggressive resize to ensure we meet target
    if (compressedBytes.length > targetSizeBytes) {
      // Calculate dimensions that should result in ~30KB
      final targetWidth = (image.width * 0.3).round().clamp(100, image.width);
      final targetHeight = (image.height * 0.3).round().clamp(100, image.height);
      currentImage = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
      );
      compressedBytes = Uint8List.fromList(img.encodeJpg(currentImage, quality: 10));
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

