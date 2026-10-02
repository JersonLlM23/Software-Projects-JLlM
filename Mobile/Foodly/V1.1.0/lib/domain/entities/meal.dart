import 'food_entry.dart';

/// Meal consumption event recorded in the daily timeline.
class Meal {
  final String id;
  final String name;
  final DateTime dateTime;
  final List<FoodEntry> items;
  final String? notes;

  const Meal({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.items,
    this.notes,
  });

  /// Total energy calculated as the sum of all food entries in kcal.
  double get totalEnergyKcal {
    return items.fold<double>(0.0, (sum, item) => sum + item.calculatedEnergyKcal);
  }

  Meal copyWith({
    String? id,
    String? name,
    DateTime? dateTime,
    List<FoodEntry>? items,
    String? notes,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          dateTime == other.dateTime &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      dateTime.hashCode ^
      notes.hashCode;
}
