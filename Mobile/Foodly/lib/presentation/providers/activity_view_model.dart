import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/activity_event.dart';
import '../../domain/entities/activity_intensity.dart';
import '../../domain/entities/activity_type.dart';
import '../../domain/usecases/add_activity_event_usecase.dart';
import '../../domain/usecases/calculate_activity_calories_usecase.dart';
import '../../domain/usecases/get_user_usecase.dart';
import '../../domain/usecases/update_activity_event_usecase.dart';

class ActivityViewModel extends ChangeNotifier {
  final AddActivityEventUseCase addActivityEventUseCase;
  final UpdateActivityEventUseCase updateActivityEventUseCase;
  final GetUserUseCase getUserUseCase;
  final CalculateActivityCaloriesUseCase calculateCaloriesUseCase;

  ActivityViewModel({
    required this.addActivityEventUseCase,
    required this.updateActivityEventUseCase,
    required this.getUserUseCase,
    this.calculateCaloriesUseCase = const CalculateActivityCaloriesUseCase(),
  });

  ActivityEvent? _editingActivity;
  ActivityType _selectedType = ActivityType.walking;
  ActivityIntensity _selectedIntensity = ActivityIntensity.normal;
  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now().add(const Duration(minutes: 30));
  String _notes = '';
  double _userWeightKg = AppConstants.defaultInitialWeightKg;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditing => _editingActivity != null;
  ActivityType get selectedType => _selectedType;
  ActivityIntensity get selectedIntensity => _selectedIntensity;
  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  String get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get durationInMinutes => _endDateTime.difference(_startDateTime).inMinutes;

  /// Dynamic estimated calories burned
  double get estimatedCaloriesBurned {
    return calculateCaloriesUseCase.execute(
      type: _selectedType,
      intensity: _selectedType == ActivityType.walking ? _selectedIntensity : null,
      startDateTime: _startDateTime,
      endDateTime: _endDateTime,
      weightKg: _userWeightKg,
    );
  }

  Future<void> initForNew({DateTime? baseDate}) async {
    _editingActivity = null;
    _selectedType = ActivityType.walking;
    _selectedIntensity = ActivityIntensity.normal;
    _notes = '';
    _errorMessage = null;

    final now = DateTime.now();
    if (baseDate != null) {
      _startDateTime = DateTime(baseDate.year, baseDate.month, baseDate.day, now.hour, now.minute);
    } else {
      _startDateTime = now;
    }
    _endDateTime = _startDateTime.add(const Duration(minutes: 30));

    await _loadUserWeight();
    notifyListeners();
  }

  Future<void> initForEdit(ActivityEvent activity) async {
    _editingActivity = activity;
    _selectedType = activity.type;
    _selectedIntensity = activity.intensity ?? ActivityIntensity.normal;
    _startDateTime = activity.startDateTime;
    _endDateTime = activity.endDateTime;
    _notes = activity.notes ?? '';
    _errorMessage = null;

    await _loadUserWeight();
    notifyListeners();
  }

  Future<void> _loadUserWeight() async {
    final user = await getUserUseCase.execute();
    if (user != null) {
      _userWeightKg = user.weightKg;
    }
  }

  void setType(ActivityType type) {
    _selectedType = type;
    notifyListeners();
  }

  void setIntensity(ActivityIntensity intensity) {
    _selectedIntensity = intensity;
    notifyListeners();
  }

  void setStartDateTime(DateTime start) {
    _startDateTime = start;
    // If end is before start, push end forward
    if (_endDateTime.isBefore(_startDateTime)) {
      _endDateTime = _startDateTime.add(const Duration(minutes: 30));
    }
    notifyListeners();
  }

  void setEndDateTime(DateTime end) {
    _endDateTime = end;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  Future<bool> saveActivity() async {
    if (_endDateTime.isBefore(_startDateTime) ||
        _endDateTime.isAtSameMomentAs(_startDateTime)) {
      _errorMessage = 'La fecha/hora de finalización debe ser posterior a la de inicio.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final burnedKcal = estimatedCaloriesBurned;

      final activity = ActivityEvent(
        id: _editingActivity?.id ?? const Uuid().v4(),
        type: _selectedType,
        intensity: _selectedType == ActivityType.walking ? _selectedIntensity : null,
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        calculatedEnergyKcal: burnedKcal,
        notes: _notes.trim().isEmpty ? null : _notes.trim(),
      );

      if (isEditing) {
        await updateActivityEventUseCase.execute(activity);
      } else {
        await addActivityEventUseCase.execute(activity);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar la actividad.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
