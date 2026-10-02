import 'activity_intensity.dart';
import 'activity_type.dart';

/// Activity event recorded in the daily timeline.
class ActivityEvent {
  final String id;
  final ActivityType type;
  final ActivityIntensity? intensity;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final double calculatedEnergyKcal;
  final String? notes;

  const ActivityEvent({
    required this.id,
    required this.type,
    this.intensity,
    required this.startDateTime,
    required this.endDateTime,
    required this.calculatedEnergyKcal,
    this.notes,
  });

  /// Duration in minutes calculated from startDateTime and endDateTime.
  int get durationInMinutes => endDateTime.difference(startDateTime).inMinutes;

  ActivityEvent copyWith({
    String? id,
    ActivityType? type,
    ActivityIntensity? intensity,
    DateTime? startDateTime,
    DateTime? endDateTime,
    double? calculatedEnergyKcal,
    String? notes,
  }) {
    return ActivityEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      calculatedEnergyKcal: calculatedEnergyKcal ?? this.calculatedEnergyKcal,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          intensity == other.intensity &&
          startDateTime == other.startDateTime &&
          endDateTime == other.endDateTime &&
          calculatedEnergyKcal == other.calculatedEnergyKcal;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      intensity.hashCode ^
      startDateTime.hashCode ^
      endDateTime.hashCode ^
      calculatedEnergyKcal.hashCode;
}
