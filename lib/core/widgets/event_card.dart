import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// An event card widget mimicking the Airbnb redesign house card.
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 300.0,
        width: 255.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.cardDark 
            : AppColors.cardLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: bannerUrl != null && bannerUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: bannerUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (_, __) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                          'Closed',
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
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.textPrimaryDark 
                        : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    clubName,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "$venue\n",
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                    ? AppColors.textSecondaryDark 
                                    : const Color.fromRGBO(64, 74, 106, 1),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.0,
                                ),
                              ),
                              TextSpan(
                                text: dateTime.split(' ').take(3).join(' '), // Just take the date part
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                    ? AppColors.textPrimaryDark 
                                    : AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (availableSlots != null && maxParticipants != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: availableSlots! <= 0 
                              ? AppColors.error.withValues(alpha: 0.1) 
                              : AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            availableSlots! <= 0 ? 'Full' : '$availableSlots left',
                            style: TextStyle(
                              color: availableSlots! <= 0 ? AppColors.error : AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
