/// Calculated daily energy balance.
/// Formula: Balance = Consumed Energy - Expended Energy
class DailyBalance {
  final DateTime date;
  final double consumedEnergyKcal;
  final double expendedEnergyKcal;
  final double bmrKcal;

  const DailyBalance({
    required this.date,
    required this.consumedEnergyKcal,
    required this.expendedEnergyKcal,
    required this.bmrKcal,
  });

  /// Net balance: Consumed - Expended
  double get balanceKcal => consumedEnergyKcal - expendedEnergyKcal;

  /// Returns true if user is in estimated caloric deficit (< -50 kcal)
  bool get isDeficit => balanceKcal < -50.0;

  /// Returns true if user is in estimated caloric surplus (> 50 kcal)
  bool get isSurplus => balanceKcal > 50.0;

  /// Returns true if approximately balanced (-50 to +50 kcal)
  bool get isEquilibrium => !isDeficit && !isSurplus;

  String get balanceStatusDescription {
    if (isDeficit) {
      return 'Déficit estimado';
    } else if (isSurplus) {
      return 'Superávit estimado';
    } else {
      return 'Equilibrio estimado';
    }
  }
}
