import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/event_card.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/providers/admin_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final eventsAsync = ref.watch(eventsStreamProvider);
    final clubsAsync = ref.watch(clubsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome ──
              userAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (user) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name.split(' ').first ?? 'Student'} 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover upcoming events',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Upcoming Events ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upcoming Events',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () => context.go('/user/events'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: eventsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (events) {
                    final upcoming = events
                        .where(
                            (e) => e.startDateTime.isAfter(DateTime.now()))
                        .take(5)
                        .toList();
                    if (upcoming.isEmpty) {
                      return const Center(child: Text('No upcoming events'));
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: upcoming.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (_, i) {
                        final event = upcoming[i];
                        return SizedBox(
                          width: 280,
                          child: EventCard(
                            title: event.title,
                            clubName: event.clubName,
                            venue: event.venue,
                            dateTime: DateFormatter.relative(
                                event.startDateTime),
                            bannerUrl: event.bannerUrl,
                            tag: event.tag,
                            isClosed: event.isDeadlinePassed,
                            onTap: () => context
                                .go('/user/events/${event.id}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── Clubs ──
              Text('Clubs',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              clubsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (clubs) {
                  if (clubs.isEmpty) {
                    return const Text('No clubs yet');
                  }
                  return SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: clubs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, i) {
                        final club = clubs[i];
                        return GestureDetector(
                          onTap: () =>
                              context.go('/user/club/${club.id}'),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: club.logoUrl != null
                                    ? NetworkImage(club.logoUrl!)
                                    : null,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                child: club.logoUrl == null
                                    ? Text(club.name[0].toUpperCase(),
                                        style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700))
                                    : null,
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  club.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
