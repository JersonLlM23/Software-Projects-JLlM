import 'dart:convert';

/// Clasificación oficial de llegada según la puntualidad del evento completado.
enum PunctualityCategory {
  early,       // «¡Llegaste temprano!»: 5 minutos o más antes del evento
  justInTime,  // «¡Con las justas!»: desde 2 minutos antes hasta la hora objetivo
  slightlyLate,// «Algo tarde, pero no tanto»: después de la hora objetivo y hasta 10 minutos de atraso
  veryLate,    // «Uh»: más de 10 minutos de atraso
}

/// Modelo que encapsula los datos de un evento marcado como completado para el historial.
class CompletedEvent {
  final String id;
  final String title;
  final DateTime targetDateTime;
  final DateTime completedAt;

  CompletedEvent({
    required this.id,
    required this.title,
    required this.targetDateTime,
    required this.completedAt,
  });

  /// Diferencia entre la hora real de finalización y la hora objetivo.
  /// - Valor negativo: completado antes de la meta (adelanto).
  /// - Valor positivo: completado después de la meta (atraso).
  ///
  /// IMPORTANTE: Esta es la diferencia exacta respecto a la meta (targetDateTime),
  /// no la duración desde que se inició el temporizador.
  Duration get deltaFromTarget => completedAt.difference(targetDateTime);

  /// Retorna si el evento se completó antes o exactamente en la hora objetivo.
  bool get isCompletedEarlyOrOnTime => completedAt.isBefore(targetDateTime) || completedAt.isAtSameMomentAs(targetDateTime);

  /// Retorna si el evento se completó después de la hora objetivo (atraso).
  bool get isOverdue => completedAt.isAfter(targetDateTime);

  /// Duración de adelanto si se completó antes de la meta.
  Duration get earlyDuration {
    if (isCompletedEarlyOrOnTime) {
      final diff = targetDateTime.difference(completedAt);
      return diff.isNegative ? Duration.zero : diff;
    }
    return Duration.zero;
  }

  /// Duración del atraso si se completó después de la meta.
  Duration get overdueDuration {
    if (isOverdue) {
      final diff = completedAt.difference(targetDateTime);
      return diff.isNegative ? Duration.zero : diff;
    }
    return Duration.zero;
  }

  /// Clasifica el evento de acuerdo a las reglas oficiales de TimeLeft:
  /// - «¡Llegaste temprano!»: 5 minutos o más antes del evento (o más de 2 min antes).
  /// - «¡Con las justas!»: desde 2 minutos antes hasta la hora objetivo.
  /// - «Algo tarde, pero no tanto»: después de la hora objetivo y hasta 10 minutos de atraso.
  /// - «Uh»: más de 10 minutos de atraso.
  PunctualityCategory get punctualityCategory {
    final deltaSeconds = deltaFromTarget.inSeconds;

    if (deltaSeconds <= -120) {
      // Completado más de 2 minutos antes del evento (incluye >= 5 min antes)
      return PunctualityCategory.early;
    } else if (deltaSeconds <= 0) {
      // Desde 2 minutos antes (-120 segundos) hasta la hora objetivo (0 segundos)
      return PunctualityCategory.justInTime;
    } else if (deltaSeconds <= 600) {
      // Después de la hora objetivo (1 segundo) hasta 10 minutos de atraso (600 segundos)
      return PunctualityCategory.slightlyLate;
    } else {
      // Más de 10 minutos de atraso (> 600 segundos)
      return PunctualityCategory.veryLate;
    }
  }

  /// Etiqueta textual oficial del indicador según la clasificación
  String get punctualityLabel {
    switch (punctualityCategory) {
      case PunctualityCategory.early:
        return '«¡Llegaste temprano!»';
      case PunctualityCategory.justInTime:
        return '«¡Con las justas!»';
      case PunctualityCategory.slightlyLate:
        return '«Algo tarde, pero no tanto»';
      case PunctualityCategory.veryLate:
        return '«Uh»';
    }
  }

  /// Formatea la duración legible (horas, minutos y segundos)
  static String formatDuration(Duration d) {
    final abs = d.abs();
    final hours = abs.inHours;
    final minutes = abs.inMinutes % 60;
    final seconds = abs.inSeconds % 60;

    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0 || hours > 0) parts.add('${minutes}m');
    parts.add('${seconds}s');

    return parts.join(' ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDateTime': targetDateTime.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory CompletedEvent.fromMap(Map<String, dynamic> map) {
    return CompletedEvent(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] as String? ?? 'Evento',
      targetDateTime: DateTime.parse(map['targetDateTime'] as String),
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CompletedEvent.fromJson(String source) =>
      CompletedEvent.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
