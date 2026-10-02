import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/timeline_event.dart';
import 'timeline_item_card.dart';

class TimelineList extends StatelessWidget {
  final List<TimelineEvent> events;
  final ValueChanged<TimelineEvent> onEventTap;

  const TimelineList({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_note_outlined,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin registros en este día',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Presiona el botón + para registrar una actividad o comida.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return TimelineItemCard(
          event: event,
          onTap: () => onEventTap(event),
        );
      },
    );
  }
}
