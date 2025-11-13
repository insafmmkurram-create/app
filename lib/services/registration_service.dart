import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user CNIC from Firestore
  Future<String?> getUserCNIC() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['cnic'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Save registration form data to Firestore
  Future<Map<String, dynamic>> saveRegistrationData({
    required Map<String, dynamic> applicantData,
    required List<Map<String, dynamic>> familyMembers,
    String? imageUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return {
          'success': false,
          'error': 'User not authenticated',
        };
      }

      // Prepare registration data
      final registrationData = {
        'applicant': applicantData,
        'familyMembers': familyMembers,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': userId,
      };

      // Save to Firestore in 'registrations' collection
      await _firestore
          .collection('registrations')
          .doc(userId)
          .set(registrationData, SetOptions(merge: true));

      return {
        'success': true,
        'message': 'Registration data saved successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to save registration: ${e.toString()}',
      };
    }
  }

  // Get registration data for current user
  Future<Map<String, dynamic>?> getRegistrationData() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('registrations').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

