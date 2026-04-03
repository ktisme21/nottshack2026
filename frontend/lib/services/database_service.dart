import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stray_cat.dart';

class DatabaseService {
  final CollectionReference straysCollection = 
      FirebaseFirestore.instance.collection('strays');
  
  final CollectionReference feedingsCollection = 
      FirebaseFirestore.instance.collection('feedings');

  // Create - Add new stray cat
  Future<void> addStray(StrayCat stray) async {
    await straysCollection.doc(stray.id).set(stray.toMap());
  }

  // Read - Get all active strays (fixed - no index needed)
  Stream<List<StrayCat>> getActiveStrays() {
    return straysCollection
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
          var list = snapshot.docs
              .map((doc) => StrayCat.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          // Sort client-side by reportedAt (newest first)
          list.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
          return list;
        });
  }

  // Read - Get single stray by ID
  Future<StrayCat?> getStrayById(String id) async {
    final doc = await straysCollection.doc(id).get();
    if (doc.exists) {
      return StrayCat.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Update - Record feeding
  Future<void> recordFeeding(String catId, String foodType, String reporterName) async {
    await feedingsCollection.add({
      'catId': catId,
      'foodType': foodType,
      'reporterName': reporterName,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    final catRef = straysCollection.doc(catId);
    final doc = await catRef.get();
    final currentFeeds = (doc.data() as Map<String, dynamic>)['feedCount'] ?? 0;
    final newFeeds = currentFeeds + 1;
    final newTrustScore = (70 + (newFeeds * 10)).clamp(0, 100);
    
    await catRef.update({
      'feedCount': newFeeds,
      'trustScore': newTrustScore,
    });
  }

  // Read - Get feeding history for a cat
  Stream<List<Map<String, dynamic>>> getFeedingHistory(String catId) {
    return feedingsCollection
        .where('catId', isEqualTo: catId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList());
  }

  // Update - Update health status
  Future<void> updateHealthStatus(String catId, List<String> newHealthStatus) async {
    await straysCollection.doc(catId).update({
      'healthStatus': newHealthStatus,
    });
  }

  // Update - Mark as adopted
  Future<void> markAsAdopted(String catId, String adopterName) async {
    await straysCollection.doc(catId).update({
      'status': 'adopted',
      'adoptedBy': adopterName,
      'adoptedAt': FieldValue.serverTimestamp(),
    });
  }

  // Read - Search strays by location (needs index - create it)
  Stream<List<StrayCat>> searchByLocation(String locationQuery) {
    return straysCollection
        .where('status', isEqualTo: 'active')
        .where('location', isGreaterThanOrEqualTo: locationQuery)
        .where('location', isLessThanOrEqualTo: locationQuery + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StrayCat.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Read - Get strays that need urgent help
  Stream<List<StrayCat>> getUrgentStrays() {
    return straysCollection
        .where('status', isEqualTo: 'active')
        .where('healthStatus', arrayContains: 'Needs food')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StrayCat.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Stats - Get total count
  Future<int> getTotalActiveStrays() async {
    final snapshot = await straysCollection.where('status', isEqualTo: 'active').get();
    return snapshot.docs.length;
  }

  // Stats - Get total feedings
  Future<int> getTotalFeedings() async {
    final snapshot = await feedingsCollection.get();
    return snapshot.docs.length;
  }
}