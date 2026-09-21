import 'dart:convert';

/// Estado del evento en TimeLeft
enum EventStatus {
  idle,       // Sin temporizador activo
  running,    // Temporizador activo antes de la hora objetivo
  overdue,    // Temporizador activo después de la hora objetivo (en atraso)
  completed,  // Evento marcado como completado
}

/// Modelo que encapsula los datos y el estado persistente de un evento.
class EventModel {
  final String title;
  final DateTime? targetDateTime;
  final bool isRunning;
  final bool isCompleted;
  final DateTime? completedAt;

  const EventModel({
    this.title = 'Ir a clases',
    this.targetDateTime,
    this.isRunning = false,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Determina el estado actual del evento de acuerdo a DateTime.now()
  EventStatus get status {
    if (isCompleted) {
      return EventStatus.completed;
    }
    if (targetDateTime == null) {
      return EventStatus.idle;
    }
    if (isRunning) {
      if (DateTime.now().isAfter(targetDateTime!)) {
        return EventStatus.overdue;
      }
      return EventStatus.running;
    }
    // Si no está corriendo pero tiene hora fijada y ya pasó
    if (DateTime.now().isAfter(targetDateTime!)) {
      return EventStatus.overdue;
    }
    return EventStatus.idle;
  }

  /// Retorna si el momento actual ya superó la hora objetivo
  bool get isOverdue {
    if (targetDateTime == null) return false;
    return DateTime.now().isAfter(targetDateTime!);
  }

  /// Calcula dinámicamente la duración restante antes de la meta.
  Duration get remainingDuration {
    if (targetDateTime == null) return Duration.zero;
    final diff = targetDateTime!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Calcula dinámicamente la duración de atraso después de la meta.
  Duration get overdueDuration {
    if (targetDateTime == null) return Duration.zero;
    final diff = DateTime.now().difference(targetDateTime!);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Si se completó, calcula la diferencia respecto a la hora objetivo.
  /// Un valor negativo significa que se completó antes (adelanto).
  /// Un valor positivo significa que se completó después (atraso).
  Duration? get completionDelta {
    if (completedAt == null || targetDateTime == null) return null;
    return completedAt!.difference(targetDateTime!);
  }

  /// Retorna si se completó a tiempo o con adelanto
  bool get completedOnTimeOrEarly {
    final delta = completionDelta;
    if (delta == null) return false;
    return delta.inSeconds <= 0;
  }

  EventModel copyWith({
    String? title,
    DateTime? targetDateTime,
    bool? isRunning,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearTarget = false,
    bool clearCompletedAt = false,
  }) {
    return EventModel(
      title: title ?? this.title,
      targetDateTime: clearTarget ? null : (targetDateTime ?? this.targetDateTime),
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetDateTime': targetDateTime?.toIso8601String(),
      'isRunning': isRunning,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      title: map['title'] as String? ?? 'Ir a clases',
      targetDateTime: map['targetDateTime'] != null
          ? DateTime.tryParse(map['targetDateTime'] as String)
          : null,
      isRunning: map['isRunning'] as bool? ?? false,
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String)
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory EventModel.fromJson(String source) =>
      EventModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
