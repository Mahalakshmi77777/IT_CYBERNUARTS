import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/event_card.dart';
import '../../../core/utils/date_formatter.dart';
import '../../admin/providers/admin_providers.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SafeArea(bottom: false, child: SizedBox()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.menu,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    size: 28,
                  ),
                  GestureDetector(
                    onTap: () => context.go('/user/profile'),
                    child: CircleAvatar(
                      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                      radius: 22.0,
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Let's Find Your\nEvents",
                style: TextStyle(
                  fontSize: 26.0,
                  height: 1.5,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 59.0,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          filled: false,
                          hintText: "Search your events...",
                          hintStyle: GoogleFonts.inter(
                            color: isDark ? AppColors.textSecondaryDark : const Color.fromRGBO(153, 163, 196, 1),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 48.0,
                      width: 48.0,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            
            // Events Lists
            eventsAsync.when(
              loading: () => const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SizedBox(
                height: 300,
                child: Center(child: Text('Error: $e')),
              ),
              data: (events) {
                var filtered = events;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered
                      .where((e) =>
                          e.title.toLowerCase().contains(q) ||
                          e.clubName.toLowerCase().contains(q) ||
                          e.tag.toLowerCase().contains(q))
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: AppColors.textSecondaryLight),
                          const SizedBox(height: 16),
                          Text('No events found', style: theme.textTheme.titleMedium),
                        ],
                      ),
                    ),
                  );
                }

                // Partition events randomly or conceptually into Popular and Upcoming for demo UI
                final popularEvents = filtered.take(filtered.length ~/ 2 + 1).toList();
                final upcomingEvents = filtered.skip(filtered.length ~/ 2 + 1).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (popularEvents.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          "Popular",
                          style: TextStyle(
                            fontSize: 18.0,
                            height: 1.5,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 300.0,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: popularEvents.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16.0),
                          itemBuilder: (context, index) {
                            final event = popularEvents[index];
                            return EventCard(
                              title: event.title,
                              clubName: event.clubName,
                              venue: event.venue,
                              dateTime: DateFormatter.full(event.startDateTime),
                              bannerUrl: event.bannerUrl,
                              availableSlots: event.availableSlots,
                              maxParticipants: event.maxParticipants,
                              tag: event.tag,
                              isClosed: event.isDeadlinePassed,
                              onTap: () => context.go('/user/events/${event.id}'),
                            );
                          },
                        ),
                      ),
                    ],
                    
                    if (upcomingEvents.isNotEmpty) ...[
                      const SizedBox(height: 32.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          "Upcoming",
                          style: TextStyle(
                            fontSize: 18.0,
                            height: 1.5,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 300.0,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: upcomingEvents.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16.0),
                          itemBuilder: (context, index) {
                            final event = upcomingEvents[index];
                            return EventCard(
                              title: event.title,
                              clubName: event.clubName,
                              venue: event.venue,
                              dateTime: DateFormatter.full(event.startDateTime),
                              bannerUrl: event.bannerUrl,
                              availableSlots: event.availableSlots,
                              maxParticipants: event.maxParticipants,
                              tag: event.tag,
                              isClosed: event.isDeadlinePassed,
                              onTap: () => context.go('/user/events/${event.id}'),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 32.0),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
