import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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

/// Repository for club CRUD operations.
class ClubRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _clubsRef => _db.collection('clubs');

  Future<void> createClub(Club club) async {
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
    return _clubsRef
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Club.fromFirestore(d)).toList());
  }

  Future<Club> getClub(String clubId) async {
    final doc = await _clubsRef.doc(clubId).get();
    return Club.fromFirestore(doc);
  }

  Future<String> uploadLogo(String clubId, File file) async {
    final ref = _storage.ref('club_logos/$clubId');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
