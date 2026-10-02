import 'activity_event.dart';
import 'meal.dart';

enum TimelineEventType {
  activity,
  meal;
}

/// Unified presentation item for the daily timeline.
class TimelineEvent implements Comparable<TimelineEvent> {
  final String id;
  final TimelineEventType type;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String title;
  final String subtitle;
  final double energyKcal;
  final String icon;
  final ActivityEvent? activityEvent;
  final Meal? meal;

  const TimelineEvent({
    required this.id,
    required this.type,
    required this.startDateTime,
    this.endDateTime,
    required this.title,
    required this.subtitle,
    required this.energyKcal,
    required this.icon,
    this.activityEvent,
    this.meal,
  });

  factory TimelineEvent.fromActivity(ActivityEvent activity) {
    final intensityStr = activity.intensity != null ? ' (${activity.intensity!.displayName})' : '';
    final durationStr = '${activity.durationInMinutes} min';
    return TimelineEvent(
      id: activity.id,
      type: TimelineEventType.activity,
      startDateTime: activity.startDateTime,
      endDateTime: activity.endDateTime,
      title: '${activity.type.displayName}$intensityStr',
      subtitle: '$durationStr • ${activity.calculatedEnergyKcal.toStringAsFixed(1)} kcal',
      energyKcal: activity.calculatedEnergyKcal,
      icon: activity.type.icon,
      activityEvent: activity,
    );
  }

  factory TimelineEvent.fromMeal(Meal meal) {
    final itemsCount = '${meal.items.length} ${meal.items.length == 1 ? 'alimento' : 'alimentos'}';
    return TimelineEvent(
      id: meal.id,
      type: TimelineEventType.meal,
      startDateTime: meal.dateTime,
      endDateTime: null,
      title: meal.name,
      subtitle: '$itemsCount • ${meal.totalEnergyKcal.toStringAsFixed(1)} kcal',
      energyKcal: meal.totalEnergyKcal,
      icon: '🍽️',
      meal: meal,
    );
  }

  @override
  int compareTo(TimelineEvent other) {
    return startDateTime.compareTo(other.startDateTime);
  }
}
