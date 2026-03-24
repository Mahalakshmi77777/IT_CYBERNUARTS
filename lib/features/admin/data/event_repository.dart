import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Data model for an event.
class Event {
  final String id;
  final String title;
  final String description;
  final String clubId;
  final String clubName;
  final String venue;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final DateTime registrationDeadline;
  final int maxParticipants;
  final List<String> registeredUsers;
  final String? bannerUrl;
  final String tag; // Tech, Cultural, Sports, Workshop
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.clubId,
    required this.clubName,
    required this.venue,
    required this.startDateTime,
    required this.endDateTime,
    required this.registrationDeadline,
    required this.maxParticipants,
    this.registeredUsers = const [],
    this.bannerUrl,
    this.tag = 'General',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get availableSlots => maxParticipants - registeredUsers.length;
  bool get isFull => availableSlots <= 0;
  bool get isDeadlinePassed => DateTime.now().isAfter(registrationDeadline);

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      clubId: d['clubId'] ?? '',
      clubName: d['clubName'] ?? '',
      venue: d['venue'] ?? '',
      startDateTime: (d['startDateTime'] as Timestamp).toDate(),
      endDateTime: (d['endDateTime'] as Timestamp).toDate(),
      registrationDeadline: (d['registrationDeadline'] as Timestamp).toDate(),
      maxParticipants: d['maxParticipants'] ?? 0,
      registeredUsers: List<String>.from(d['registeredUsers'] ?? []),
      bannerUrl: d['bannerUrl'],
      tag: d['tag'] ?? 'General',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'clubId': clubId,
        'clubName': clubName,
        'venue': venue,
        'startDateTime': Timestamp.fromDate(startDateTime),
        'endDateTime': Timestamp.fromDate(endDateTime),
        'registrationDeadline': Timestamp.fromDate(registrationDeadline),
        'maxParticipants': maxParticipants,
        'registeredUsers': registeredUsers,
        'bannerUrl': bannerUrl,
        'tag': tag,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}

/// Repository for event CRUD operations.
class EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _eventsRef => _db.collection('events');

  /// Create a new event.
  Future<void> createEvent(Event event) async {
    await _eventsRef.doc(event.id).set(event.toMap());
  }

  /// Update an existing event.
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _eventsRef.doc(eventId).update(data);
  }

  /// Delete an event and its banner from Storage.
  Future<void> deleteEvent(String eventId) async {
    final doc = await _eventsRef.doc(eventId).get();
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && data['bannerUrl'] != null) {
      try {
        await _storage.refFromURL(data['bannerUrl']).delete();
      } catch (_) {}
    }
    await _eventsRef.doc(eventId).delete();
  }

  /// Stream of all events ordered by start date.
  Stream<List<Event>> getEvents() {
    return _eventsRef
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Event.fromFirestore(d)).toList());
  }

  /// Stream of events filtered by club.
  Stream<List<Event>> getEventsByClub(String clubId) {
    return _eventsRef
        .where('clubId', isEqualTo: clubId)
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Event.fromFirestore(d)).toList());
  }

  /// Single event future.
  Future<Event> getEvent(String eventId) async {
    final doc = await _eventsRef.doc(eventId).get();
    return Event.fromFirestore(doc);
  }

  /// Upload a banner image and return the download URL.
  Future<String> uploadBanner(String eventId, File file) async {
    final ref = _storage.ref('event_banners/$eventId');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
