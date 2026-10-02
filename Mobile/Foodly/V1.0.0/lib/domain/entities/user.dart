import 'gender.dart';

/// User profile entity.
/// Note: Age is NOT stored permanently; it is computed dynamically from birthDate.
class User {
  final String id;
  final String name;
  final DateTime birthDate;
  final Gender gender;
  final double weightKg;
  final double heightCm;

  const User({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
  });

  /// Height in meters for convenience.
  double get heightM => heightCm / 100.0;

  User copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    Gender? gender,
    double? weightKg,
    double? heightCm,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          birthDate == other.birthDate &&
          gender == other.gender &&
          weightKg == other.weightKg &&
          heightCm == other.heightCm;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      birthDate.hashCode ^
      gender.hashCode ^
      weightKg.hashCode ^
      heightCm.hashCode;
}
