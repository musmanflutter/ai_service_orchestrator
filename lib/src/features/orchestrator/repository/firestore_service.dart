import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

class FirestoreService {
  final FirebaseFirestore _db;
  FirestoreService(this._db);

  Future<void> createBooking(
    String bookingId,
    String providerId,
    String providerName,
    String service,
    String location,
    String time,
    String? scheduledTimestamp,
  ) async {
    await _db.collection('bookings').doc(bookingId).set({
      'id': bookingId,
      'providerId': providerId,
      'providerName': providerName,
      'service': service,
      'location': location,
      'time': time,
      'scheduledTimestamp': scheduledTimestamp,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> listenToBooking(String bookingId) {
    return _db.collection('bookings').doc(bookingId).snapshots();
  }

  Stream<QuerySnapshot> getPendingBookings() {
    return _db.collection('bookings')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<QuerySnapshot> getPendingBookingsFuture() {
    return _db.collection('bookings')
        .where('status', isEqualTo: 'pending')
        .get();
  }

  Stream<QuerySnapshot> getAllBookings() {
    return _db.collection('bookings').snapshots();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({'status': status});
  }

  Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }
}
