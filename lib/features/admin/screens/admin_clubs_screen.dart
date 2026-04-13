import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_providers.dart';

class AdminClubsScreen extends ConsumerWidget {
  const AdminClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(clubsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clubs')),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.go('/admin/clubs/create'),
        child: const Icon(Icons.add),
      ),
      body: clubsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (clubs) {
          if (clubs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No clubs yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Tap + to create one',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clubs.length,
            itemBuilder: (_, i) {
              final club = clubs[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: club.logoUrl != null
                        ? NetworkImage(club.logoUrl!)
                        : null,
                    child: club.logoUrl == null
                        ? Text(club.name[0].toUpperCase())
                        : null,
                  ),
                  title: Text(club.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(club.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/admin/clubs/${club.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
