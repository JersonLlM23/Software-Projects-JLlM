import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelo/event_model.dart';
import '../modelo/reminder_option.dart';
import 'notification_service.dart';

/// ViewModel que gestiona la lógica de cuenta regresiva, atraso, estado del evento,
/// persistencia con SharedPreferences y notificaciones locales.
class CountdownViewModel extends ChangeNotifier {
  static final CountdownViewModel instance = CountdownViewModel._internal();
  CountdownViewModel._internal();

  factory CountdownViewModel() => instance;

  final NotificationService _notificationService = NotificationService.instance;

  // Claves de SharedPreferences
  static const String _keyTitle = 'timeleft_event_title';
  static const String _keyTargetDateTime = 'timeleft_target_datetime';
  static const String _keyIsRunning = 'timeleft_is_running';
  static const String _keyIsCompleted = 'timeleft_is_completed';
  static const String _keyCompletedAt = 'timeleft_completed_at';
  static const String _keyReminderOptions = 'timeleft_reminder_options';
  static const String _keyDarkMode = 'timeleft_is_dark_mode';
  static const String _keyNotificationsEnabled = 'timeleft_notifications_enabled';

  EventModel _event = const EventModel(title: 'Ir a clases');
  List<ReminderOption> _reminderOptions = ReminderOption.defaultOptions();
  bool _isDarkMode = true; // Por defecto modo oscuro según el mockup
  bool _notificationsEnabled = true;
  String? _errorMessage;
  Timer? _ticker;
  bool _isInitialized = false;

  // Getters
  EventModel get event => _event;
  String get eventTitle => _event.title;
  DateTime? get targetDateTime => _event.targetDateTime;
  bool get isRunning => _event.isRunning;
  bool get isCompleted => _event.isCompleted;
  DateTime? get completedAt => _event.completedAt;
  bool get isOverdue => _event.isOverdue;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String? get errorMessage => _errorMessage;
  List<ReminderOption> get reminderOptions => _reminderOptions;

  /// Inicializa el ViewModel cargando los datos guardados en SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _loadFromPreferences();

    // Si estaba corriendo antes de cerrarse, reanuda el ticker y valida notificaciones
    if (_event.isRunning && _event.targetDateTime != null) {
      _startTicker();
      if (_notificationsEnabled) {
        _scheduleValidNotifications();
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Carga el estado guardado desde SharedPreferences
  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final title = prefs.getString(_keyTitle) ?? 'Ir a clases';
      final targetStr = prefs.getString(_keyTargetDateTime);
      final isRunning = prefs.getBool(_keyIsRunning) ?? false;
      final isCompleted = prefs.getBool(_keyIsCompleted) ?? false;
      final completedStr = prefs.getString(_keyCompletedAt);

      DateTime? targetDt;
      if (targetStr != null && targetStr.isNotEmpty) {
        targetDt = DateTime.tryParse(targetStr);
      }

      DateTime? completedDt;
      if (completedStr != null && completedStr.isNotEmpty) {
        completedDt = DateTime.tryParse(completedStr);
      }

      _event = EventModel(
        title: title,
        targetDateTime: targetDt,
        isRunning: isRunning,
        isCompleted: isCompleted,
        completedAt: completedDt,
      );

      _isDarkMode = prefs.getBool(_keyDarkMode) ?? true;
      _notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? true;

      final remindersJson = prefs.getStringList(_keyReminderOptions);
      if (remindersJson != null && remindersJson.isNotEmpty) {
        _reminderOptions = remindersJson.map((str) {
          return ReminderOption.fromMap(jsonDecode(str) as Map<String, dynamic>);
        }).toList();
      } else {
        _reminderOptions = ReminderOption.defaultOptions();
      }
    } catch (e) {
      debugPrint('Error al cargar preferencias: $e');
    }
  }

  /// Guarda el estado actual en SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyTitle, _event.title);
      if (_event.targetDateTime != null) {
        await prefs.setString(
            _keyTargetDateTime, _event.targetDateTime!.toIso8601String());
      } else {
        await prefs.remove(_keyTargetDateTime);
      }

      await prefs.setBool(_keyIsRunning, _event.isRunning);
      await prefs.setBool(_keyIsCompleted, _event.isCompleted);

      if (_event.completedAt != null) {
        await prefs.setString(
            _keyCompletedAt, _event.completedAt!.toIso8601String());
      } else {
        await prefs.remove(_keyCompletedAt);
      }

      await prefs.setBool(_keyDarkMode, _isDarkMode);
      await prefs.setBool(_keyNotificationsEnabled, _notificationsEnabled);

      final remindersJson = _reminderOptions
          .map((opt) => jsonEncode(opt.toMap()))
          .toList();
      await prefs.setStringList(_keyReminderOptions, remindersJson);
    } catch (e) {
      debugPrint('Error al guardar preferencias: $e');
    }
  }

  /// Inicia el temporizador de refresco periódico de 1 segundo para la UI
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  /// Detiene el temporizador de refresco
  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Actualiza el título del evento
  void setEventTitle(String title) {
    _event = _event.copyWith(title: title);
    _saveToPreferences();
    notifyListeners();
  }

  /// Asigna una hora objetivo a partir de un TimeOfDay
  void setTargetTimeOfDay(TimeOfDay picked) {
    final now = DateTime.now();
    var target = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
      0,
    );

    // Si la hora elegida ya pasó hoy y el temporizador no está corriendo,
    // se puede seleccionar para hoy (permitiendo ver el atraso si se inicia) o para mañana si es futura
    _event = _event.copyWith(
      targetDateTime: target,
      isCompleted: false,
      clearCompletedAt: true,
    );
    _errorMessage = null;

    _saveToPreferences();
    notifyListeners();
  }

  /// Asigna un DateTime objetivo completo
  void setTargetDateTime(DateTime target) {
    _event = _event.copyWith(
      targetDateTime: target,
      isCompleted: false,
      clearCompletedAt: true,
    );
    _errorMessage = null;

    _saveToPreferences();
    notifyListeners();
  }

  /// Inicia o reanuda el temporizador
  Future<void> startTimer() async {
    if (_event.targetDateTime == null) {
      _errorMessage = 'Por favor selecciona una hora objetivo antes de iniciar.';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _event = _event.copyWith(
      isRunning: true,
      isCompleted: false,
      clearCompletedAt: true,
    );

    if (_notificationsEnabled) {
      await _notificationService.requestPermissions();
      await _notificationService.cancelAll();
      await _scheduleValidNotifications();
    }

    _startTicker();
    await _saveToPreferences();
    notifyListeners();
  }

  /// Detiene o pausa el temporizador
  Future<void> stopTimer() async {
    _stopTicker();
    await _notificationService.cancelAll();

    _event = _event.copyWith(isRunning: false);
    await _saveToPreferences();
    notifyListeners();
  }

  /// Marca el evento como completado
  Future<void> markDone() async {
    if (_event.targetDateTime == null) return;

    _stopTicker();
    await _notificationService.cancelAll();

    _event = _event.copyWith(
      isRunning: false,
      isCompleted: false,
      clearTarget: true,
      clearCompletedAt: true,
    );

    await _saveToPreferences();
    notifyListeners();
  }

  /// Alterna entre iniciar y detener el temporizador
  Future<void> toggleTimer() async {
    if (_event.isRunning) {
      await stopTimer();
    } else {
      await startTimer();
    }
  }

  /// Borra todos los datos y restablece el estado inicial
  Future<void> clearAllData() async {
    _stopTicker();
    await _notificationService.cancelAll();

    _event = const EventModel(
      title: 'Ir a clases',
      targetDateTime: null,
      isRunning: false,
      isCompleted: false,
      completedAt: null,
    );
    _errorMessage = null;
    _reminderOptions = ReminderOption.defaultOptions();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTitle);
    await prefs.remove(_keyTargetDateTime);
    await prefs.remove(_keyIsRunning);
    await prefs.remove(_keyIsCompleted);
    await prefs.remove(_keyCompletedAt);
    await prefs.remove(_keyReminderOptions);

    notifyListeners();
  }

  /// Alterna una opción individual de recordatorio
  Future<void> toggleReminderOption(int id, bool isEnabled) async {
    _reminderOptions = _reminderOptions.map((opt) {
      if (opt.id == id) {
        return opt.copyWith(isEnabled: isEnabled);
      }
      return opt;
    }).toList();

    await _saveToPreferences();

    if (_event.isRunning && _notificationsEnabled) {
      await _notificationService.cancelAll();
      await _scheduleValidNotifications();
    }

    notifyListeners();
  }

  /// Alterna la activación general de notificaciones
  Future<void> toggleAllNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveToPreferences();

    if (!_notificationsEnabled) {
      await _notificationService.cancelAll();
    } else if (_event.isRunning) {
      await _scheduleValidNotifications();
    }

    notifyListeners();
  }

  /// Alterna el modo oscuro / claro
  Future<void> toggleThemeMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveToPreferences();
    notifyListeners();
  }

  /// Establece el modo oscuro / claro explícitamente
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _saveToPreferences();
      notifyListeners();
    }
  }

  /// Programa las notificaciones que aún se encuentren en el futuro
  Future<void> _scheduleValidNotifications() async {
    if (_event.targetDateTime == null || !_notificationsEnabled) return;

    final now = DateTime.now();
    final target = _event.targetDateTime!;
    final trimmedName = _event.title.trim();
    const title = 'TimeLeft';

    for (final option in _reminderOptions) {
      if (!option.isEnabled) continue;

      final scheduledDate = target.subtract(Duration(minutes: option.minutesBefore));

      if (scheduledDate.isAfter(now)) {
        String body;
        if (option.minutesBefore == 0) {
          body = trimmedName.isNotEmpty
              ? '¡Es hora! "$trimmedName"'
              : '¡Es hora!';
        } else if (option.minutesBefore == 60) {
          body = trimmedName.isNotEmpty
              ? 'Falta 1 hora para "$trimmedName"'
              : 'Falta 1 hora';
        } else if (option.minutesBefore == 1) {
          body = trimmedName.isNotEmpty
              ? 'Falta 1 minuto para "$trimmedName"'
              : 'Falta 1 minuto';
        } else {
          body = trimmedName.isNotEmpty
              ? 'Faltan ${option.minutesBefore} minutos para "$trimmedName"'
              : 'Faltan ${option.minutesBefore} minutos';
        }

        await _notificationService.scheduleNotification(
          id: option.id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
        );
      }
    }
  }

  // --- MÉTODOS DE FORMATEO Y VISUALIZACIÓN ---

  /// Retorna la etiqueta de estado superior del display
  String get statusLabel {
    if (_event.isCompleted) {
      return 'EVENTO COMPLETADO';
    }
    if (_event.targetDateTime == null) {
      return 'TIEMPO RESTANTE';
    }
    if (_event.isOverdue) {
      return 'ATRASO';
    }
    return 'FALTAN';
  }

  /// Retorna los tres componentes de tiempo (horas, minutos, segundos) como strings de 2 dígitos
  /// para renderizar en los bloques exactos del mockup
  ({String hours, String minutes, String seconds, bool isOverdue}) get displayTimeComponents {
    Duration duration;

    if (_event.isCompleted && _event.completedAt != null && _event.targetDateTime != null) {
      final delta = _event.completionDelta!;
      duration = delta.abs();
      final isLate = delta.inSeconds > 0;
      return (
        hours: duration.inHours.toString().padLeft(2, '0'),
        minutes: (duration.inMinutes % 60).toString().padLeft(2, '0'),
        seconds: (duration.inSeconds % 60).toString().padLeft(2, '0'),
        isOverdue: isLate,
      );
    }

    if (_event.targetDateTime == null) {
      return (hours: '00', minutes: '00', seconds: '00', isOverdue: false);
    }

    if (_event.isOverdue) {
      duration = _event.overdueDuration;
      return (
        hours: duration.inHours.toString().padLeft(2, '0'),
        minutes: (duration.inMinutes % 60).toString().padLeft(2, '0'),
        seconds: (duration.inSeconds % 60).toString().padLeft(2, '0'),
        isOverdue: true,
      );
    } else {
      duration = _event.remainingDuration;
      return (
        hours: duration.inHours.toString().padLeft(2, '0'),
        minutes: (duration.inMinutes % 60).toString().padLeft(2, '0'),
        seconds: (duration.inSeconds % 60).toString().padLeft(2, '0'),
        isOverdue: false,
      );
    }
  }

  static const List<String> _monthsEs = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  /// Formatea la fecha y hora objetivo para la tarjeta informativa en español
  String formatTargetDate() {
    if (_event.targetDateTime == null) {
      return 'No configurada';
    }
    final dt = _event.targetDateTime!;
    final day = dt.day.toString().padLeft(2, '0');
    final month = _monthsEs[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  /// Formatea el resumen de completado
  String? formatCompletionSummary() {
    if (!_event.isCompleted || _event.completedAt == null || _event.targetDateTime == null) {
      return null;
    }

    final dt = _event.completedAt!;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    final completedTime = '$hour:$min:$sec';

    final delta = _event.completionDelta!;
    final absDuration = delta.abs();
    final h = absDuration.inHours.toString().padLeft(2, '0');
    final m = (absDuration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (absDuration.inSeconds % 60).toString().padLeft(2, '0');
    final timeStr = '$h:$m:$s';

    if (delta.inSeconds <= 0) {
      return 'Completado a las $completedTime (Adelanto: -$timeStr)';
    } else {
      return 'Completado a las $completedTime (Atraso: +$timeStr)';
    }
  }

  /// Formatea TimeOfDay para mostrar en el campo de texto de hora
  String formatTargetTimeField() {
    if (_event.targetDateTime == null) return '';
    final dt = _event.targetDateTime!;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$hour:$min:$sec';
  }
}
