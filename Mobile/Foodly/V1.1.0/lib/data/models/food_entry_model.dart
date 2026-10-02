import '../../domain/entities/food_entry.dart';
import 'food_model.dart';

/// Data transfer model for FoodEntry.
class FoodEntryModel {
  final String id;
  final FoodModel food;
  final double quantity;
  final String unit;
  final double calculatedEnergyKcal;

  const FoodEntryModel({
    required this.id,
    required this.food,
    required this.quantity,
    required this.unit,
    required this.calculatedEnergyKcal,
  });

  factory FoodEntryModel.fromJson(Map<String, dynamic> json) {
    return FoodEntryModel(
      id: json['id'] as String,
      food: FoodModel.fromJson(json['food'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      calculatedEnergyKcal: (json['calculatedEnergyKcal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food.toJson(),
      'quantity': quantity,
      'unit': unit,
      'calculatedEnergyKcal': calculatedEnergyKcal,
    };
  }

  factory FoodEntryModel.fromEntity(FoodEntry entity) {
    return FoodEntryModel(
      id: entity.id,
      food: FoodModel.fromEntity(entity.food),
      quantity: entity.quantity,
      unit: entity.unit,
      calculatedEnergyKcal: entity.calculatedEnergyKcal,
    );
  }

  FoodEntry toEntity() {
    return FoodEntry(
      id: id,
      food: food.toEntity(),
      quantity: quantity,
      unit: unit,
      calculatedEnergyKcal: calculatedEnergyKcal,
    );
  }
}
