import '../../domain/entities/gender.dart';
import '../../domain/entities/user.dart';

/// Data transfer model for User entity with JSON serialization.
class UserModel {
  final String id;
  final String name;
  final String birthDateIso;
  final String gender;
  final double weightKg;
  final double heightCm;

  const UserModel({
    required this.id,
    required this.name,
    required this.birthDateIso,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDateIso: json['birthDateIso'] as String,
      gender: json['gender'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDateIso': birthDateIso,
      'gender': gender,
      'weightKg': weightKg,
      'heightCm': heightCm,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      birthDateIso: user.birthDate.toIso8601String(),
      gender: user.gender.name,
      weightKg: user.weightKg,
      heightCm: user.heightCm,
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      birthDate: DateTime.parse(birthDateIso),
      gender: Gender.fromString(gender),
      weightKg: weightKg,
      heightCm: heightCm,
    );
  }
}
