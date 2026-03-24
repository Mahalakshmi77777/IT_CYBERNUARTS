import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data model for the authenticated user's Firestore profile.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String college;
  final String department;
  final String role; // "admin" or "student"
  final DateTime createdAt;
  final List<String> joinedEvents;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.college,
    required this.department,
    required this.role,
    required this.createdAt,
    this.joinedEvents = const [],
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      college: data['college'] ?? '',
      department: data['department'] ?? '',
      role: data['role'] ?? 'student',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      joinedEvents: List<String>.from(data['joinedEvents'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'college': college,
        'department': department,
        'role': role,
        'createdAt': Timestamp.fromDate(createdAt),
        'joinedEvents': joinedEvents,
      };

  bool get isAdmin => role == 'admin';
}

/// Repository handling Firebase Auth + Firestore user operations.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user (nullable).
  User? get currentUser => _auth.currentUser;

  /// Sign up with email/password and create Firestore user doc.
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required String college,
    required String department,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = AppUser(
      uid: cred.user!.uid,
      name: name.trim(),
      email: email.trim(),
      college: college.trim(),
      department: department.trim(),
      role: 'student',
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  /// Sign in with email/password.
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return getCurrentUserData();
  }

  /// Sign out.
  Future<void> signOut() => _auth.signOut();

  /// Fetch current user's Firestore doc.
  Future<AppUser> getCurrentUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User profile not found');
    return AppUser.fromFirestore(doc);
  }
}
