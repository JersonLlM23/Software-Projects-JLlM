/// Food reference entity.
/// Defines a reference consumption amount, unit, and the energy in kcal for that reference.
class Food {
  final String id;
  final String name;
  final double servingAmount;
  final String servingUnit;
  final double energyKcal;
  final String icon;

  const Food({
    required this.id,
    required this.name,
    required this.servingAmount,
    required this.servingUnit,
    required this.energyKcal,
    this.icon = '🍽️',
  });

  /// Readable serving reference string, e.g. "100 g → 130 kcal"
  String get servingDescription {
    final amountStr = servingAmount % 1 == 0
        ? servingAmount.toInt().toString()
        : servingAmount.toString();
    final kcalStr = energyKcal % 1 == 0
        ? energyKcal.toInt().toString()
        : energyKcal.toStringAsFixed(1);
    return '$amountStr $servingUnit = $kcalStr kcal';
  }

  Food copyWith({
    String? id,
    String? name,
    double? servingAmount,
    String? servingUnit,
    double? energyKcal,
    String? icon,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      servingAmount: servingAmount ?? this.servingAmount,
      servingUnit: servingUnit ?? this.servingUnit,
      energyKcal: energyKcal ?? this.energyKcal,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          servingAmount == other.servingAmount &&
          servingUnit == other.servingUnit &&
          energyKcal == other.energyKcal;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      servingAmount.hashCode ^
      servingUnit.hashCode ^
      energyKcal.hashCode;
}
