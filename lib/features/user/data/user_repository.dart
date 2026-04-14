import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_repository.dart';

/// Repository for user profile operations.
class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch a user profile by UID.
  Future<AppUser> getUserProfile(String uid) async {
    final row = await _client
        .from('users')
        .select()
        .eq('id', uid)
        .single();

    // Get join count
    final regCount = await _client
        .from('registrations')
        .select()
        .eq('user_id', uid);
    row['join_count'] = (regCount as List).length;

    return AppUser.fromJson(row);
  }

  /// Update specific profile fields.
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    await _client.from('users').update(data).eq('id', uid);
  }
}
