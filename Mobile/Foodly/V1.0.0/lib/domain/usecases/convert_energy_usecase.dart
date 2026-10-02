import '../../core/utils/energy_converter.dart';

/// Use case to convert energy between kcal and kJ.
/// Standard: 1 kcal = 4.184 kJ
class ConvertEnergyUseCase {
  const ConvertEnergyUseCase();

  double kcalToKj(double kcal) => EnergyConverter.kcalToKj(kcal);

  double kjToKcal(double kj) => EnergyConverter.kjToKcal(kj);

  double normalizeToKcal(double value, String unit) =>
      EnergyConverter.normalizeToKcal(value, unit);
}
