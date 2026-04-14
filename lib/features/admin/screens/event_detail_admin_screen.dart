import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/event_repository.dart';
import '../providers/admin_providers.dart';

class EventDetailAdminScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailAdminScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder<Event>(
      future: ref.read(eventRepositoryProvider).getEvent(eventId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final event = snapshot.data!;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── Banner ──
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: event.bannerUrl != null
                      ? CachedNetworkImage(
                          imageUrl: event.bannerUrl!,
                          fit: BoxFit.cover)
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.event,
                              size: 64, color: AppColors.primary),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        context.go('/admin/edit-event/${event.id}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, ref, event),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Title + tag ──
                    Row(
                      children: [
                        Expanded(
                          child: Text(event.title,
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(event.tag,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(event.clubName,
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const Divider(height: 32),

                    // ── Info rows ──
                    _infoTile(Icons.location_on_outlined, 'Venue',
                        event.venue, theme),
                    _infoTile(
                        Icons.calendar_today_outlined,
                        'Starts',
                        DateFormatter.full(event.startDateTime),
                        theme),
                    _infoTile(Icons.calendar_today_outlined, 'Ends',
                        DateFormatter.full(event.endDateTime), theme),
                    _infoTile(Icons.timer_outlined, 'Deadline',
                        DateFormatter.full(event.registrationDeadline), theme),
                    _infoTile(Icons.people_outline, 'Slots',
                        '${event.availableSlots} / ${event.maxParticipants} available', theme),

                    const Divider(height: 32),

                    Text('Description',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(event.description,
                        style: theme.textTheme.bodyMedium),

                    const Divider(height: 32),

                    // ── Registered users ──
                    Text(
                      'Registered Users (${event.registeredCount})',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (event.registeredCount == 0)
                      Text('No registrations yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant))
                    else
                      Text('Log in to the Web Admin DB tool to view the live list of registered users.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(
      IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  // The _registeredUserTile widget has been removed because the Neon DB schema querying
  // for lists of users via widget iteration is an anti-pattern. Admin tools should view this in a dedicated table.

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Event event) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text(
          event.registeredCount > 0
              ? '⚠️ This event has ${event.registeredCount} registered user(s). Deleting it will remove their registrations.'
              : 'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(eventRepositoryProvider)
                  .deleteEvent(event.id);
              if (context.mounted) context.go('/admin');
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
