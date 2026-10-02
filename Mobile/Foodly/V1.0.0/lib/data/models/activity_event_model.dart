import '../../domain/entities/activity_event.dart';
import '../../domain/entities/activity_intensity.dart';
import '../../domain/entities/activity_type.dart';

/// Data transfer model for ActivityEvent.
class ActivityEventModel {
  final String id;
  final String type;
  final String? intensity;
  final String startDateTimeIso;
  final String endDateTimeIso;
  final double calculatedEnergyKcal;
  final String? notes;

  const ActivityEventModel({
    required this.id,
    required this.type,
    this.intensity,
    required this.startDateTimeIso,
    required this.endDateTimeIso,
    required this.calculatedEnergyKcal,
    this.notes,
  });

  factory ActivityEventModel.fromJson(Map<String, dynamic> json) {
    return ActivityEventModel(
      id: json['id'] as String,
      type: json['type'] as String,
      intensity: json['intensity'] as String?,
      startDateTimeIso: json['startDateTimeIso'] as String,
      endDateTimeIso: json['endDateTimeIso'] as String,
      calculatedEnergyKcal: (json['calculatedEnergyKcal'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'intensity': intensity,
      'startDateTimeIso': startDateTimeIso,
      'endDateTimeIso': endDateTimeIso,
      'calculatedEnergyKcal': calculatedEnergyKcal,
      'notes': notes,
    };
  }

  factory ActivityEventModel.fromEntity(ActivityEvent entity) {
    return ActivityEventModel(
      id: entity.id,
      type: entity.type.name,
      intensity: entity.intensity?.name,
      startDateTimeIso: entity.startDateTime.toIso8601String(),
      endDateTimeIso: entity.endDateTime.toIso8601String(),
      calculatedEnergyKcal: entity.calculatedEnergyKcal,
      notes: entity.notes,
    );
  }

  ActivityEvent toEntity() {
    return ActivityEvent(
      id: id,
      type: ActivityType.fromString(type),
      intensity: ActivityIntensity.fromString(intensity),
      startDateTime: DateTime.parse(startDateTimeIso),
      endDateTime: DateTime.parse(endDateTimeIso),
      calculatedEnergyKcal: calculatedEnergyKcal,
      notes: notes,
    );
  }
}
