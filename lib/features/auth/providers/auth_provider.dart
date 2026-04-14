import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

/// Singleton auth repository provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Fetches the current user's profile from public.users.
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  try {
    return await ref.read(authRepositoryProvider).getCurrentUserData();
  } catch (_) {
    return null;
  }
});

/// Auth state: is user logged in?
/// Uses Supabase's currentUser — no manual session checks.
final isLoggedInProvider = Provider<bool>((ref) {
  // Also check the Supabase auth state directly
  final supabaseUser = Supabase.instance.client.auth.currentUser;
  final appUser = ref.watch(currentUserProvider).value;
  return supabaseUser != null && appUser != null;
});

/// Derived provider returning the user's role ("admin" or "student").
final userRoleProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.role);
});
