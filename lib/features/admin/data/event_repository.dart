import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';

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
  final String tag;
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

final StreamController<List<Event>> _mockEventsController = StreamController<List<Event>>.broadcast();

final List<Event> _localMockEvents = [
  Event(
    id: 'e1',
    title: 'Hackathon 2026',
    description: 'Annual college hackathon bringing minds together.',
    clubId: 'c1',
    clubName: 'CyberNerds',
    venue: 'Main Auditorium',
    startDateTime: DateTime.now().add(const Duration(days: 2)),
    endDateTime: DateTime.now().add(const Duration(days: 3)),
    registrationDeadline: DateTime.now().add(const Duration(days: 1)),
    maxParticipants: 100,
    tag: 'Tech',
  ),
  Event(
    id: 'e2',
    title: 'Dance Off',
    description: 'Show your moves in the ultimate dance battle.',
    clubId: 'c2',
    clubName: 'Artistry',
    venue: 'Open Air Theatre',
    startDateTime: DateTime.now().add(const Duration(days: 5)),
    endDateTime: DateTime.now().add(const Duration(days: 5, hours: 4)),
    registrationDeadline: DateTime.now().add(const Duration(days: 4)),
    maxParticipants: 50,
    tag: 'Cultural',
  ),
  Event(
    id: 'e3',
    title: 'Inter-College Football',
    description: 'The big autumn football tournament.',
    clubId: 'c3',
    clubName: 'SportsHub',
    venue: 'College Ground',
    startDateTime: DateTime.now().add(const Duration(days: 10)),
    endDateTime: DateTime.now().add(const Duration(days: 12)),
    registrationDeadline: DateTime.now().add(const Duration(days: 8)),
    maxParticipants: 200,
    tag: 'Sports',
  ),
  Event(
    id: 'e4',
    title: 'Blockchain Workshop',
    description: 'Learn the fundamentals of blockchain tech.',
    clubId: 'c1',
    clubName: 'CyberNerds',
    venue: 'Lab 3',
    startDateTime: DateTime.now().add(const Duration(days: 14)),
    endDateTime: DateTime.now().add(const Duration(days: 14, hours: 3)),
    registrationDeadline: DateTime.now().add(const Duration(days: 10)),
    maxParticipants: 60,
    tag: 'Workshop',
  ),
  Event(
    id: 'e5',
    title: 'Comedy Night',
    description: 'An evening of laughs and fun.',
    clubId: 'c2',
    clubName: 'Artistry',
    venue: 'Mini Auditorium',
    startDateTime: DateTime.now().add(const Duration(days: 20)),
    endDateTime: DateTime.now().add(const Duration(days: 20, hours: 2)),
    registrationDeadline: DateTime.now().add(const Duration(days: 18)),
    maxParticipants: 150,
    tag: 'General',
  ),
];

/// Repository for event CRUD operations.
class EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final bool useMock = true;

  CollectionReference get _eventsRef => _db.collection('events');

  Future<void> createEvent(Event event) async {
    if (useMock) {
      _localMockEvents.add(event);
      _mockEventsController.add(_localMockEvents.toList());
      return;
    }
    await _eventsRef.doc(event.id).set(event.toMap());
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _eventsRef.doc(eventId).update(data);
  }

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

  Stream<List<Event>> getEvents() {
    if (useMock) {
      return Stream.value(_localMockEvents.toList());
    } else {
      return _eventsRef
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .map((snap) => snap.docs.map((d) => Event.fromFirestore(d)).toList());
    }
  }

  Stream<List<Event>> getEventsByClub(String clubId) {
    if (useMock) {
      return Stream.value(_localMockEvents.where((e) => e.clubId == clubId).toList());
    } else {
      return _eventsRef
          .where('clubId', isEqualTo: clubId)
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .map((snap) => snap.docs.map((d) => Event.fromFirestore(d)).toList());
    }
  }

  Future<Event> getEvent(String eventId) async {
    if (useMock) return _localMockEvents.firstWhere((e) => e.id == eventId);
    final doc = await _eventsRef.doc(eventId).get();
    return Event.fromFirestore(doc);
  }

  Future<String> uploadBanner(String eventId, File file) async {
    if (useMock) return 'https://via.placeholder.com/600x300';
    final ref = _storage.ref('event_banners/$eventId');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
