import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';

/// Data model for a club.
class Club {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final DateTime createdAt;

  Club({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Club.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Club(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      logoUrl: d['logoUrl'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

final StreamController<List<Club>> _mockClubsController = StreamController<List<Club>>.broadcast();

final List<Club> _localMockClubs = [
  Club(id: 'c1', name: 'CyberNerds', description: 'Tech Club focused on web apps and security.', createdAt: DateTime.now()),
  Club(id: 'c2', name: 'Artistry', description: 'Cultural Club for arts and dance.', createdAt: DateTime.now()),
  Club(id: 'c3', name: 'SportsHub', description: 'Sports Club promoting fitness.', createdAt: DateTime.now()),
];


/// Repository for club CRUD operations.
class ClubRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final bool useMock = true;

  CollectionReference get _clubsRef => _db.collection('clubs');

  Future<void> createClub(Club club) async {
    if (useMock) {
      _localMockClubs.add(club);
      _mockClubsController.add(_localMockClubs.toList());
      return;
    }
    await _clubsRef.doc(club.id).set(club.toMap());
  }

  Future<void> updateClub(String clubId, Map<String, dynamic> data) async {
    await _clubsRef.doc(clubId).update(data);
  }

  Future<void> deleteClub(String clubId) async {
    final doc = await _clubsRef.doc(clubId).get();
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && data['logoUrl'] != null) {
      try {
        await _storage.refFromURL(data['logoUrl']).delete();
      } catch (_) {}
    }
    await _clubsRef.doc(clubId).delete();
  }

  Stream<List<Club>> getClubs() {
    if (useMock) {
      return Stream.value(_localMockClubs.toList());
    } else {
      return _clubsRef
          .orderBy('name')
          .snapshots()
          .map((snap) => snap.docs.map((d) => Club.fromFirestore(d)).toList());
    }
  }

  Future<Club> getClub(String clubId) async {
    if (useMock) return _localMockClubs.firstWhere((c) => c.id == clubId);
    final doc = await _clubsRef.doc(clubId).get();
    return Club.fromFirestore(doc);
  }

  Future<String> uploadLogo(String clubId, File file) async {
    if (useMock) return 'https://via.placeholder.com/150';
    final ref = _storage.ref('club_logos/$clubId');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
