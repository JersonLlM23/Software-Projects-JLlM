import 'food.dart';

/// Food entry within a meal consumption event.
class FoodEntry {
  final String id;
  final Food food;
  final double quantity;
  final String unit;
  final double calculatedEnergyKcal;

  const FoodEntry({
    required this.id,
    required this.food,
    required this.quantity,
    required this.unit,
    required this.calculatedEnergyKcal,
  });

  FoodEntry copyWith({
    String? id,
    Food? food,
    double? quantity,
    String? unit,
    double? calculatedEnergyKcal,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calculatedEnergyKcal: calculatedEnergyKcal ?? this.calculatedEnergyKcal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          food == other.food &&
          quantity == other.quantity &&
          unit == other.unit &&
          calculatedEnergyKcal == other.calculatedEnergyKcal;

  @override
  int get hashCode =>
      id.hashCode ^
      food.hashCode ^
      quantity.hashCode ^
      unit.hashCode ^
      calculatedEnergyKcal.hashCode;
}
