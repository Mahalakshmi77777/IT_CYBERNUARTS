import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/event_card.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/club_repository.dart';

import '../providers/admin_providers.dart';

class ClubDetailAdminScreen extends ConsumerWidget {
  final String clubId;
  const ClubDetailAdminScreen({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(eventsByClubProvider(clubId));

    return FutureBuilder<Club>(
      future: ref.read(clubRepositoryProvider).getClub(clubId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final club = snap.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(club.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, ref, club),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        club.logoUrl != null ? NetworkImage(club.logoUrl!) : null,
                    child: club.logoUrl == null
                        ? Text(club.name[0], style: const TextStyle(fontSize: 32))
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(club.name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Text(club.description, style: theme.textTheme.bodyMedium),
                const Divider(height: 32),
                Text('Events',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                eventsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (events) {
                    if (events.isEmpty) {
                      return const Text('No events for this club');
                    }
                    return Column(
                      children: events
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: EventCard(
                                  title: e.title,
                                  clubName: e.clubName,
                                  venue: e.venue,
                                  dateTime: DateFormatter.full(e.startDateTime),
                                  bannerUrl: e.bannerUrl,
                                  tag: e.tag,
                                  isClosed: e.isDeadlinePassed,
                                  onTap: () => context.go('/admin/event/${e.id}'),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Club club) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Club?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(clubRepositoryProvider).deleteClub(club.id);
              if (context.mounted) context.go('/admin/clubs');
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
