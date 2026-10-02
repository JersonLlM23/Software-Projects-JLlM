import '../../domain/entities/meal.dart';
import 'food_entry_model.dart';

/// Data transfer model for Meal.
class MealModel {
  final String id;
  final String name;
  final String dateTimeIso;
  final List<FoodEntryModel> items;
  final String? notes;

  const MealModel({
    required this.id,
    required this.name,
    required this.dateTimeIso,
    required this.items,
    this.notes,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>)
        .map((item) => FoodEntryModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dateTimeIso: json['dateTimeIso'] as String,
      items: itemsList,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateTimeIso': dateTimeIso,
      'items': items.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  factory MealModel.fromEntity(Meal entity) {
    return MealModel(
      id: entity.id,
      name: entity.name,
      dateTimeIso: entity.dateTime.toIso8601String(),
      items: entity.items.map((e) => FoodEntryModel.fromEntity(e)).toList(),
      notes: entity.notes,
    );
  }

  Meal toEntity() {
    return Meal(
      id: id,
      name: name,
      dateTime: DateTime.parse(dateTimeIso),
      items: items.map((e) => e.toEntity()).toList(),
      notes: notes,
    );
  }
}
