import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('listings');

  // Real-time stream of ALL listings
  Stream<List<ListingModel>> watchAllListings() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ListingModel.fromFirestore(d)).toList());
  }

  // Real-time stream of listings by current user
  Stream<List<ListingModel>> watchMyListings(String uid) {
    return _col
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ListingModel.fromFirestore(d)).toList());
  }

  Future<void> createListing(ListingModel listing) async {
    final data = listing.toFirestore();
    data.remove('updatedAt'); // don't store null
    await _col.add(data);
  }

  Future<void> updateListing(String id, ListingModel listing) async {
    final data = listing.toFirestore();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(id).update(data);
  }

  Future<void> deleteListing(String id) async {
    await _col.doc(id).delete();
  }

  Future<ListingModel?> fetchListing(String id) async {
    final doc = await _col.doc(id).get();
    if (doc.exists) return ListingModel.fromFirestore(doc);
    return null;
  }
}
