import 'package:cloud_firestore/cloud_firestore.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all news items from Firestore
  Stream<List<Map<String, dynamic>>> getNews() {
    try {
      return _firestore
          .collection('news')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final List<Map<String, dynamic>> newsList = [];
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          newsList.add({
            'id': doc.id,
            'title': data['title'] ?? '',
            'content': data['content'] ?? '',
            'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
            'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
          });
        }
        
        return newsList;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Get news items as a Future (for one-time fetch)
  Future<List<Map<String, dynamic>>> getNewsOnce() async {
    try {
      final snapshot = await _firestore
          .collection('news')
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> newsList = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        newsList.add({
          'id': doc.id,
          'title': data['title'] ?? '',
          'content': data['content'] ?? '',
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
        });
      }
      
      return newsList;
    } catch (e) {
      return [];
    }
  }
}

