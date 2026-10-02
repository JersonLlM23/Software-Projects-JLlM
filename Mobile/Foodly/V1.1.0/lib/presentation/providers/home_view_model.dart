import 'package:flutter/foundation.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/daily_balance.dart';
import '../../domain/entities/timeline_event.dart';
import '../../domain/usecases/calculate_daily_balance_usecase.dart';
import '../../domain/usecases/delete_activity_event_usecase.dart';
import '../../domain/usecases/delete_meal_usecase.dart';
import '../../domain/usecases/get_daily_timeline_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final GetDailyTimelineUseCase getDailyTimelineUseCase;
  final CalculateDailyBalanceUseCase calculateDailyBalanceUseCase;
  final DeleteActivityEventUseCase deleteActivityEventUseCase;
  final DeleteMealUseCase deleteMealUseCase;

  HomeViewModel({
    required this.getDailyTimelineUseCase,
    required this.calculateDailyBalanceUseCase,
    required this.deleteActivityEventUseCase,
    required this.deleteMealUseCase,
  }) {
    _selectedDate = DateTime.now();
  }

  late DateTime _selectedDate;
  List<TimelineEvent> _timelineEvents = [];
  DailyBalance? _dailyBalance;
  bool _isLoading = false;
  String? _errorMessage;

  DateTime get selectedDate => _selectedDate;
  List<TimelineEvent> get timelineEvents => _timelineEvents;
  DailyBalance? get dailyBalance => _dailyBalance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get consumedKcal => _dailyBalance?.consumedEnergyKcal ?? 0.0;
  double get expendedKcal => _dailyBalance?.expendedEnergyKcal ?? 0.0;
  double get balanceKcal => _dailyBalance?.balanceKcal ?? 0.0;

  bool get isToday => DateTimeUtils.isSameDay(_selectedDate, DateTime.now());

  Future<void> loadCurrentDate() async {
    await loadDayData(_selectedDate);
  }

  Future<void> loadDayData(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final events = await getDailyTimelineUseCase.execute(date);
      final balance = await calculateDailyBalanceUseCase.execute(date);

      _timelineEvents = events;
      _dailyBalance = balance;
    } catch (e) {
      _errorMessage = 'Error al cargar los datos del día.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void previousDay() {
    final prev = _selectedDate.subtract(const Duration(days: 1));
    loadDayData(prev);
  }

  void nextDay() {
    final next = _selectedDate.add(const Duration(days: 1));
    loadDayData(next);
  }

  void setDate(DateTime date) {
    loadDayData(date);
  }

  void goToToday() {
    loadDayData(DateTime.now());
  }

  Future<bool> deleteEvent(TimelineEvent event) async {
    try {
      if (event.type == TimelineEventType.activity) {
        await deleteActivityEventUseCase.execute(event.id);
      } else {
        await deleteMealUseCase.execute(event.id);
      }
      await loadDayData(_selectedDate);
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar el evento.';
      notifyListeners();
      return false;
    }
  }
}
