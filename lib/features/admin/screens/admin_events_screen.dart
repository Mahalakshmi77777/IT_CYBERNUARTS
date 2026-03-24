import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/event_card.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/admin_providers.dart';
import '../data/event_repository.dart';

class AdminEventsScreen extends ConsumerStatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  ConsumerState<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends ConsumerState<AdminEventsScreen> {
  String _searchQuery = '';
  String _selectedTag = 'All';

  final _tags = ['All', 'Tech', 'Cultural', 'Sports', 'Workshop', 'General'];

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/admin/create-event'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // ── Filter chips ──
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _tags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final tag = _tags[i];
                final selected = tag == _selectedTag;
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedTag = tag),
                );
              },
            ),
          ),

          // ── Event list ──
          Expanded(
            child: eventsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (events) {
                var filtered = events;
                if (_selectedTag != 'All') {
                  filtered = filtered
                      .where((e) => e.tag == _selectedTag)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered
                      .where((e) =>
                          e.title.toLowerCase().contains(q) ||
                          e.clubName.toLowerCase().contains(q))
                      .toList();
                }
                if (filtered.isEmpty) {
                  return _emptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildCard(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Event event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: EventCard(
        title: event.title,
        clubName: event.clubName,
        venue: event.venue,
        dateTime: DateFormatter.full(event.startDateTime),
        bannerUrl: event.bannerUrl,
        availableSlots: event.availableSlots,
        maxParticipants: event.maxParticipants,
        tag: event.tag,
        isClosed: event.isDeadlinePassed,
        onTap: () => context.go('/admin/event/${event.id}'),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create one',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
