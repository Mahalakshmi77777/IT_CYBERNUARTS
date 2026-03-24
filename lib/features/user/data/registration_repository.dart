import 'package:cloud_firestore/cloud_firestore.dart';
import '../../admin/data/event_repository.dart';

/// Repository for event registration (join / leave).
class RegistrationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Join an event — atomic batch write.
  Future<void> joinEvent(String eventId, String userId) async {
    final batch = _db.batch();
    final eventRef = _db.collection('events').doc(eventId);
    final userRef = _db.collection('users').doc(userId);
    final regRef = _db.collection('registrations').doc('${eventId}_$userId');

    // Add user to event's registeredUsers
    batch.update(eventRef, {
      'registeredUsers': FieldValue.arrayUnion([userId]),
    });

    // Add event to user's joinedEvents
    batch.update(userRef, {
      'joinedEvents': FieldValue.arrayUnion([eventId]),
    });

    // Create registration record
    batch.set(regRef, {
      'eventId': eventId,
      'userId': userId,
      'registeredAt': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();
  }

  /// Leave an event — reverse of join.
  Future<void> leaveEvent(String eventId, String userId) async {
    final batch = _db.batch();
    final eventRef = _db.collection('events').doc(eventId);
    final userRef = _db.collection('users').doc(userId);
    final regRef = _db.collection('registrations').doc('${eventId}_$userId');

    batch.update(eventRef, {
      'registeredUsers': FieldValue.arrayRemove([userId]),
    });

    batch.update(userRef, {
      'joinedEvents': FieldValue.arrayRemove([eventId]),
    });

    batch.delete(regRef);

    await batch.commit();
  }

  /// Stream of events the user has registered for.
  Stream<List<Event>> getUserRegistrations(String userId) {
    return _db
        .collection('events')
        .where('registeredUsers', arrayContains: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Event.fromFirestore(d)).toList());
  }
}
