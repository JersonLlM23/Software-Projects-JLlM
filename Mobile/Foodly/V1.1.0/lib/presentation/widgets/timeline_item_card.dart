import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/timeline_event.dart';

class TimelineItemCard extends StatelessWidget {
  final TimelineEvent event;
  final VoidCallback onTap;

  const TimelineItemCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActivity = event.type == TimelineEventType.activity;
    final String timeStr = event.endDateTime != null
        ? DateTimeUtils.formatTimeRange(event.startDateTime, event.endDateTime!)
        : DateTimeUtils.formatTime(event.startDateTime);

    final Color accentColor = isActivity ? AppColors.energyBurned : AppColors.energyConsumed;
    final Color iconBgColor = isActivity ? AppColors.energyBurnedLight : AppColors.energyConsumedLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                event.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (event.endDateTime != null &&
                          !DateTimeUtils.isSameDay(
                              event.startDateTime, event.endDateTime!))
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.activitySleep.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '+1d',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.activitySleep,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Energy Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${isActivity ? '-' : '+'}${event.energyKcal.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
