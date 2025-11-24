import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user CNIC to match payments
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

  // Parse date string (format: "2025-11-12") to DateTime
  DateTime? _parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // Handle format "2025-11-12"
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get all payments for the current user (by userId)
  Stream<List<Map<String, dynamic>>> getPayments() {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Stream.value([]);
      }

      // Query payments by userId
      return _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final List<Map<String, dynamic>> allPayments = [];
        
        // Process each document
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final documentId = doc.id;
          final documentCreatedAt = (data['createdAt'] as Timestamp?)?.toDate();
          final documentUpdatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
          
          // Get the payments array
          final paymentsArray = data['payments'] as List<dynamic>?;
          
          if (paymentsArray != null && paymentsArray.isNotEmpty) {
            // Flatten the array - each payment in the array becomes a separate item
            for (var paymentData in paymentsArray) {
              if (paymentData is Map<String, dynamic>) {
                final dateStr = paymentData['date'] as String?;
                final paymentDate = _parseDateString(dateStr);
                
                // Combine document-level and payment-level data
                allPayments.add({
                  'id': '$documentId-${allPayments.length}', // Unique ID for each payment
                  'documentId': documentId,
                  'date': dateStr,
                  'paymentDate': paymentDate,
                  'paymentTotal': paymentData['paymentTotal'],
                  'paymentStatus': paymentData['paymentStatus'],
                  'applicantName': paymentData['applicantName'],
                  'nic': paymentData['nic'],
                  'accountNumber': paymentData['accountNumber'],
                  'bankName': paymentData['bankName'],
                  'createdAt': (paymentData['createdAt'] as Timestamp?)?.toDate() ?? documentCreatedAt,
                  'documentCreatedAt': documentCreatedAt,
                  'documentUpdatedAt': documentUpdatedAt,
                });
              }
            }
          } else {
            // Handle case where there's no payments array (legacy data or top-level payment)
            final dateStr = data['date'] as String?;
            final paymentDate = _parseDateString(dateStr);
            
            allPayments.add({
              'id': documentId,
              'documentId': documentId,
              'date': dateStr,
              'paymentDate': paymentDate,
              'paymentTotal': data['paymentTotal'],
              'paymentStatus': data['paymentStatus'],
              'applicantName': data['applicantName'],
              'nic': data['nic'],
              'accountNumber': data['accountNumber'],
              'bankName': data['bankName'],
              'createdAt': documentCreatedAt,
              'documentCreatedAt': documentCreatedAt,
              'documentUpdatedAt': documentUpdatedAt,
            });
          }
        }
        
        // Sort by paymentDate descending (newest first)
        allPayments.sort((a, b) {
          final dateA = a['paymentDate'] as DateTime?;
          final dateB = b['paymentDate'] as DateTime?;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA); // Descending order
        });
        
        return allPayments;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Get payments by CNIC (alternative method)
  Future<List<Map<String, dynamic>>> getPaymentsByCNIC(String cnic) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('nic', isEqualTo: cnic)
          .get();

      final List<Map<String, dynamic>> allPayments = [];
      
      // Process each document
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final documentId = doc.id;
        final documentCreatedAt = (data['createdAt'] as Timestamp?)?.toDate();
        final documentUpdatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
        
        // Get the payments array
        final paymentsArray = data['payments'] as List<dynamic>?;
        
        if (paymentsArray != null && paymentsArray.isNotEmpty) {
          // Flatten the array
          for (var paymentData in paymentsArray) {
            if (paymentData is Map<String, dynamic>) {
              final dateStr = paymentData['date'] as String?;
              final paymentDate = _parseDateString(dateStr);
              
              allPayments.add({
                'id': '$documentId-${allPayments.length}',
                'documentId': documentId,
                'date': dateStr,
                'paymentDate': paymentDate,
                'paymentTotal': paymentData['paymentTotal'],
                'paymentStatus': paymentData['paymentStatus'],
                'applicantName': paymentData['applicantName'],
                'nic': paymentData['nic'],
                'accountNumber': paymentData['accountNumber'],
                'bankName': paymentData['bankName'],
                'createdAt': (paymentData['createdAt'] as Timestamp?)?.toDate() ?? documentCreatedAt,
                'documentCreatedAt': documentCreatedAt,
                'documentUpdatedAt': documentUpdatedAt,
              });
            }
          }
        } else {
          // Handle legacy data
          final dateStr = data['date'] as String?;
          final paymentDate = _parseDateString(dateStr);
          
          allPayments.add({
            'id': documentId,
            'documentId': documentId,
            'date': dateStr,
            'paymentDate': paymentDate,
            'paymentTotal': data['paymentTotal'],
            'paymentStatus': data['paymentStatus'],
            'applicantName': data['applicantName'],
            'nic': data['nic'],
            'accountNumber': data['accountNumber'],
            'bankName': data['bankName'],
            'createdAt': documentCreatedAt,
            'documentCreatedAt': documentCreatedAt,
            'documentUpdatedAt': documentUpdatedAt,
          });
        }
      }
      
      // Sort by paymentDate descending (newest first)
      allPayments.sort((a, b) {
        final dateA = a['paymentDate'] as DateTime?;
        final dateB = b['paymentDate'] as DateTime?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
      
      return allPayments;
    } catch (e) {
      return [];
    }
  }
}

