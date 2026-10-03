import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio singleton responsable de gestionar las notificaciones locales con flutter_local_notifications.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String defaultChannelId = 'timeleft_notifications';
  static const String channelName = 'TimeLeft Notificaciones';
  static const String channelDescription =
      'Canal para notificaciones y recordatorios de TimeLeft';
  static const String defaultSoundResourceName = 'reloj';

  String? _customSoundPath;
  String? _customSoundName;
  bool _isInitialized = false;

  /// Retorna el nombre visible del sonido actualmente configurado
  String get activeSoundName => _customSoundName ?? 'reloj.mp3 (predeterminado)';

  /// Retorna la ruta personalizada si existe
  String? get customSoundPath => _customSoundPath;

  /// Retorna el ID de canal activo según el sonido seleccionado
  String get currentChannelId {
    if (_customSoundPath != null && _customSoundPath!.isNotEmpty) {
      return 'timeleft_notifications_custom_${_customSoundPath.hashCode.abs()}';
    }
    return defaultChannelId;
  }

  /// Inicializa la configuración de notificaciones y la base de datos de zonas horarias.
  Future<void> init({String? customPath, String? customName}) async {
    if (_isInitialized) {
      if (customPath != _customSoundPath || customName != _customSoundName) {
        await updateSoundConfiguration(customPath: customPath, customName: customName);
      }
      return;
    }

    _customSoundPath = customPath;
    _customSoundName = customName;

    try {
      // Inicializar Timezone
      tz.initializeTimeZones();
      _configureLocalTimeZone();

      // Configuración para Android
      const androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(
        android: androidInitSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notificación interactuada: ${response.payload}');
        },
      );

      // Crear canales de Android (predeterminado y si existe el personalizado)
      await _createAndroidNotificationChannels();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error en NotificationService.init: $e');
    }
  }

  /// Configura tz.local basado en el offset real del dispositivo para evitar asumir UTC.
  void _configureLocalTimeZone() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final timeZoneName = now.timeZoneName;

      // Intentar coincidir por nombre de zona
      if (tz.timeZoneDatabase.locations.containsKey(timeZoneName)) {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        return;
      }

      // Buscar una ubicación que coincida con el offset horario local
      for (final location in tz.timeZoneDatabase.locations.values) {
        if (location.currentTimeZone.offset == offset) {
          tz.setLocalLocation(location);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error al configurar zona horaria local: $e');
    }
  }

  /// Configura el sonido activo (predeterminado o archivo local personalizado)
  Future<void> updateSoundConfiguration({String? customPath, String? customName}) async {
    _customSoundPath = customPath;
    _customSoundName = customName;
    await _createAndroidNotificationChannels();
  }

  /// Crea o asegura los canales de notificación requeridos en Android.
  Future<void> _createAndroidNotificationChannels() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin == null) return;

      // 1. Canal predeterminado con sonido reloj.mp3 embebido en res/raw
      const defaultChannel = AndroidNotificationChannel(
        defaultChannelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(defaultSoundResourceName),
      );
      await androidPlugin.createNotificationChannel(defaultChannel);

      // 2. Si hay un sonido personalizado con archivo existente en disco
      if (_customSoundPath != null && _customSoundPath!.isNotEmpty) {
        final file = File(_customSoundPath!);
        if (await file.exists()) {
          try {
            final customChannel = AndroidNotificationChannel(
              currentChannelId,
              'TimeLeft ($_customSoundName)',
              description: 'Canal con sonido personalizado $_customSoundName',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
              sound: UriAndroidNotificationSound(_customSoundPath!),
            );
            await androidPlugin.createNotificationChannel(customChannel);
          } catch (channelError) {
            debugPrint('Advertencia: No se pudo registrar canal con sonido personalizado: $channelError. Se usará el predeterminado.');
          }
        } else {
          debugPrint('Advertencia: El archivo de sonido no existe en la ruta: $_customSoundPath. Revertiendo a default.');
          _customSoundPath = null;
          _customSoundName = null;
        }
      }
    } catch (e) {
      debugPrint('Error al crear canales de notificaciones Android: $e');
    }
  }

  /// Solicita los permisos necesarios en Android (POST_NOTIFICATIONS y alarmas exactas).
  Future<bool> requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final bool? notificationsGranted =
            await androidPlugin.requestNotificationsPermission();
        final bool? exactAlarmsGranted =
            await androidPlugin.requestExactAlarmsPermission();

        return (notificationsGranted ?? false) || (exactAlarmsGranted ?? false);
      }
    } catch (e) {
      debugPrint('Error al solicitar permisos: $e');
    }
    return true;
  }

  /// Determina los detalles de notificación para Android según la configuración del sonido.
  AndroidNotificationDetails _getAndroidNotificationDetails() {
    if (_customSoundPath != null && _customSoundPath!.isNotEmpty && File(_customSoundPath!).existsSync()) {
      return AndroidNotificationDetails(
        currentChannelId,
        'TimeLeft ($_customSoundName)',
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: UriAndroidNotificationSound(_customSoundPath!),
      );
    }

    // Fallback garantizado: sonido reloj.mp3 de res/raw
    return const AndroidNotificationDetails(
      defaultChannelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound(defaultSoundResourceName),
    );
  }

  /// Programa una notificación para una fecha y hora local exacta.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Convertir DateTime a TZDateTime usando la zona horaria local configurada
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      final nowTz = tz.TZDateTime.now(tz.local);

      // Evitar programar si la fecha/hora ya transcurrió
      if (tzScheduledDate.isBefore(nowTz) ||
          tzScheduledDate.isAtSameMomentAs(nowTz)) {
        return;
      }

      final androidDetails = _getAndroidNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error al programar notificación (id: $id): $e');
    }
  }

  /// Cancela una notificación individual por su ID.
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Error al cancelar notificación (id: $id): $e');
    }
  }

  /// Cancela todas las notificaciones pendientes de la aplicación.
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error al cancelar todas las notificaciones: $e');
    }
  }

  /// Obtiene la lista de notificaciones pendientes actualmente programadas.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error al obtener notificaciones pendientes: $e');
      return [];
    }
  }
}
