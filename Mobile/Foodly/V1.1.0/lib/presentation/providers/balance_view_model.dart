import 'package:flutter/foundation.dart';
import '../../core/utils/energy_converter.dart';
import '../../domain/entities/daily_balance.dart';
import '../../domain/usecases/calculate_daily_balance_usecase.dart';

class BalanceViewModel extends ChangeNotifier {
  final CalculateDailyBalanceUseCase calculateDailyBalanceUseCase;

  BalanceViewModel({
    required this.calculateDailyBalanceUseCase,
  });

  DailyBalance? _dailyBalance;
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  DailyBalance? get dailyBalance => _dailyBalance;
  DateTime get date => _date;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get consumedKcal => _dailyBalance?.consumedEnergyKcal ?? 0.0;
  double get consumedKj => EnergyConverter.kcalToKj(consumedKcal);

  double get expendedKcal => _dailyBalance?.expendedEnergyKcal ?? 0.0;
  double get expendedKj => EnergyConverter.kcalToKj(expendedKcal);

  double get bmrKcal => _dailyBalance?.bmrKcal ?? 0.0;
  double get bmrKj => EnergyConverter.kcalToKj(bmrKcal);

  double get balanceKcal => _dailyBalance?.balanceKcal ?? 0.0;
  double get balanceKj => EnergyConverter.kcalToKj(balanceKcal);

  String get balanceStatus => _dailyBalance?.balanceStatusDescription ?? 'Calculando...';

  Future<void> loadBalance(DateTime date) async {
    _date = date;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dailyBalance = await calculateDailyBalanceUseCase.execute(date);
    } catch (e) {
      _errorMessage = 'Error al calcular el balance diario.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
