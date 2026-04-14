import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/event_repository.dart';
import '../data/club_repository.dart';

/// Singleton event repository provider.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

/// Future of all events. (Replaces StreamProvider)
final eventsStreamProvider = FutureProvider<List<Event>>((ref) async {
  return ref.watch(eventRepositoryProvider).getEvents();
});

/// Future of events for a specific club.
final eventsByClubProvider =
    FutureProvider.family<List<Event>, String>((ref, clubId) async {
  return ref.watch(eventRepositoryProvider).getEventsByClub(clubId);
});

/// Singleton club repository provider.
final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepository();
});

/// Future of all clubs.
final clubsStreamProvider = FutureProvider<List<Club>>((ref) async {
  return ref.watch(clubRepositoryProvider).getClubs();
});
