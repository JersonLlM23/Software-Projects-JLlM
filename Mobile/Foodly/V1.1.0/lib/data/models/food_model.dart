import '../../domain/entities/food.dart';

/// Data transfer model for Food entity.
class FoodModel {
  final String id;
  final String name;
  final double servingAmount;
  final String servingUnit;
  final double energyKcal;
  final String icon;

  const FoodModel({
    required this.id,
    required this.name,
    required this.servingAmount,
    required this.servingUnit,
    required this.energyKcal,
    required this.icon,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      servingAmount: (json['servingAmount'] as num).toDouble(),
      servingUnit: json['servingUnit'] as String,
      energyKcal: (json['energyKcal'] as num).toDouble(),
      icon: (json['icon'] as String?) ?? '🍽️',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'servingAmount': servingAmount,
      'servingUnit': servingUnit,
      'energyKcal': energyKcal,
      'icon': icon,
    };
  }

  factory FoodModel.fromEntity(Food food) {
    return FoodModel(
      id: food.id,
      name: food.name,
      servingAmount: food.servingAmount,
      servingUnit: food.servingUnit,
      energyKcal: food.energyKcal,
      icon: food.icon,
    );
  }

  Food toEntity() {
    return Food(
      id: id,
      name: name,
      servingAmount: servingAmount,
      servingUnit: servingUnit,
      energyKcal: energyKcal,
      icon: icon,
    );
  }
}
