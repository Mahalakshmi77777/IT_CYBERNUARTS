import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

/// A premium event card widget used across admin and user panels.
class EventCard extends StatelessWidget {
  final String title;
  final String clubName;
  final String venue;
  final String dateTime;
  final String? bannerUrl;
  final int? availableSlots;
  final int? maxParticipants;
  final String? tag;
  final bool isClosed;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.title,
    required this.clubName,
    required this.venue,
    required this.dateTime,
    this.bannerUrl,
    this.availableSlots,
    this.maxParticipants,
    this.tag,
    this.isClosed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ──
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: bannerUrl != null && bannerUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: bannerUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                            highlightColor: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.event,
                                size: 48, color: AppColors.primary),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Center(
                            child: Icon(Icons.event,
                                size: 48, color: AppColors.primary),
                          ),
                        ),
                ),
                // Tag chip
                if (tag != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Closed badge
                if (isClosed)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Registration Closed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Details ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(icon: Icons.groups_outlined, text: clubName),
                  const SizedBox(height: 4),
                  _InfoRow(icon: Icons.calendar_today_outlined, text: dateTime),
                  const SizedBox(height: 4),
                  _InfoRow(icon: Icons.location_on_outlined, text: venue),
                  if (availableSlots != null && maxParticipants != null) ...[
                    const SizedBox(height: 8),
                    _SlotsBadge(
                      available: availableSlots!,
                      max: maxParticipants!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SlotsBadge extends StatelessWidget {
  final int available;
  final int max;

  const _SlotsBadge({required this.available, required this.max});

  @override
  Widget build(BuildContext context) {
    final isFull = available <= 0;
    final color = isFull ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isFull ? 'Event Full' : '$available / $max slots available',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
