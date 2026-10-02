import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/food_constants.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/user.dart';
import '../models/food_model.dart';
import '../models/user_model.dart';

/// Provides initial seed data for new app installations.
class SeedData {
  SeedData._();

  /// Creates initial default user (23 years old, 55kg, 165cm, Male).
  static UserModel createInitialUser() {
    final now = DateTime.now();
    // Birthdate set to exactly 23 years ago
    final birthDate = DateTime(now.year - AppConstants.defaultInitialAge, now.month, now.day);

    final user = User(
      id: const Uuid().v4(),
      name: AppConstants.defaultUserName,
      birthDate: birthDate,
      gender: Gender.male,
      weightKg: AppConstants.defaultInitialWeightKg,
      heightCm: AppConstants.defaultInitialHeightCm,
    );

    return UserModel.fromEntity(user);
  }

  /// Initial list of predefined foods.
  static List<FoodModel> createInitialFoods() {
    return FoodConstants.initialFoodsData.map((data) => FoodModel.fromJson(data)).toList();
  }
}
