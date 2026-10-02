import '../constants/app_constants.dart';

/// Utility class for energy conversion between kcal and kJ.
/// Conversion standard: 1 kcal = 4.184 kJ
class EnergyConverter {
  EnergyConverter._();

  /// Converts kilocalories (kcal) to kilojoules (kJ).
  static double kcalToKj(double kcal) {
    return kcal * AppConstants.kjPerKcal;
  }

  /// Converts kilojoules (kJ) to kilocalories (kcal).
  static double kjToKcal(double kj) {
    return kj / AppConstants.kjPerKcal;
  }

  /// Normalizes an energy value to kcal given the unit ('kcal' or 'kJ').
  static double normalizeToKcal(double value, String unit) {
    if (unit.toLowerCase() == 'kj') {
      return kjToKcal(value);
    }
    return value;
  }

  /// Formats a kcal value as a readable string with one decimal place if needed.
  static String formatKcal(double kcal) {
    if (kcal % 1 == 0) {
      return kcal.toInt().toString();
    }
    return kcal.toStringAsFixed(1);
  }

  /// Formats a kJ value with one decimal place.
  static String formatKj(double kj) {
    return kj.toStringAsFixed(1);
  }
}
