/// Modelo que representa una regla de recordatorio / notificación previa.
class ReminderOption {
  final int id;
  final int minutesBefore;
  final String label;
  bool isEnabled;
  final bool isCustom;

  ReminderOption({
    required this.id,
    required this.minutesBefore,
    required this.label,
    this.isEnabled = true,
    this.isCustom = false,
  });

  /// Crea una copia del objeto con valores actualizados si es necesario.
  ReminderOption copyWith({
    int? id,
    int? minutesBefore,
    String? label,
    bool? isEnabled,
    bool? isCustom,
  }) {
    return ReminderOption(
      id: id ?? this.id,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'minutesBefore': minutesBefore,
      'label': label,
      'isEnabled': isEnabled,
      'isCustom': isCustom,
    };
  }

  factory ReminderOption.fromMap(Map<String, dynamic> map) {
    return ReminderOption(
      id: map['id'] as int,
      minutesBefore: map['minutesBefore'] as int,
      label: map['label'] as String,
      isEnabled: map['isEnabled'] as bool? ?? true,
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }

  /// Genera una etiqueta legible para un recordatorio personalizado según los minutos.
  static String formatCustomLabel(int minutes) {
    if (minutes == 0) {
      return 'Al finalizar (hora objetivo)';
    } else if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return hours == 1 ? '1 hora antes' : '$hours horas antes';
    } else if (minutes < 60) {
      return minutes == 1 ? '1 minuto antes' : '$minutes minutos antes';
    } else {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      return '$hours h $remainingMins min antes';
    }
  }

  /// Lista predeterminada de avisos para TimeLeft.
  static List<ReminderOption> defaultOptions() {
    return [
      ReminderOption(id: 1001, minutesBefore: 60, label: '1 hora antes', isCustom: false),
      ReminderOption(id: 1002, minutesBefore: 30, label: '30 minutos antes', isCustom: false),
      ReminderOption(id: 1003, minutesBefore: 15, label: '15 minutos antes', isCustom: false),
      ReminderOption(id: 1004, minutesBefore: 5, label: '5 minutos antes', isCustom: false),
      ReminderOption(id: 1005, minutesBefore: 1, label: '1 minuto antes', isCustom: false),
      ReminderOption(id: 1006, minutesBefore: 0, label: 'Al finalizar (hora objetivo)', isCustom: false),
    ];
  }
}

