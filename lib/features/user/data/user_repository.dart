import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/data/auth_repository.dart';

/// Repository for user profile operations.
class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch a user profile by UID.
  Future<AppUser> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    return AppUser.fromFirestore(doc);
  }

  /// Update specific profile fields.
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }
}
