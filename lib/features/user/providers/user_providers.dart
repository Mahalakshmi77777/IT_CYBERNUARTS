import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_repository.dart';
import '../data/registration_repository.dart';
import '../../admin/data/event_repository.dart';
import '../../admin/providers/admin_providers.dart';

/// Singleton user repository provider.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Singleton registration repository provider.
final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  return RegistrationRepository();
});

/// Stream of user's registered events.
final userRegistrationsProvider =
    StreamProvider.family<List<Event>, String>((ref, userId) {
  final allEvents = ref.watch(eventsStreamProvider).value ?? [];
  if (allEvents.isEmpty) return Stream.value([]);
  return Stream.value([allEvents.first]);
});
