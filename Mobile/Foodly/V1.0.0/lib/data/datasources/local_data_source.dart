import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/activity_event_model.dart';
import '../models/food_model.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';
import 'seed_data.dart';

abstract class LocalDataSource {
  Future<UserModel?> getUser();
  Future<void> saveUser(UserModel user);

  Future<List<FoodModel>> getFoods();
  Future<FoodModel?> getFoodById(String id);
  Future<void> saveFoods(List<FoodModel> foods);
  Future<void> addFood(FoodModel food);

  Future<List<ActivityEventModel>> getActivities();
  Future<void> saveActivities(List<ActivityEventModel> activities);

  Future<List<MealModel>> getMeals();
  Future<void> saveMeals(List<MealModel> meals);
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences _prefs;

  LocalDataSourceImpl(this._prefs);

  /// Initializes seeds if not yet saved in persistent storage.
  Future<void> initSeedsIfNeeded() async {
    if (!_prefs.containsKey(AppConstants.userKey)) {
      final initialUser = SeedData.createInitialUser();
      await saveUser(initialUser);
    }

    if (!_prefs.containsKey(AppConstants.foodsKey)) {
      final initialFoods = SeedData.createInitialFoods();
      await saveFoods(initialFoods);
    }
  }

  // --- USER ---
  @override
  Future<UserModel?> getUser() async {
    final String? userJson = _prefs.getString(AppConstants.userKey);
    if (userJson == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final String jsonStr = jsonEncode(user.toJson());
    await _prefs.setString(AppConstants.userKey, jsonStr);
  }

  // --- FOODS ---
  @override
  Future<List<FoodModel>> getFoods() async {
    final String? foodsJson = _prefs.getString(AppConstants.foodsKey);
    if (foodsJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(foodsJson) as List<dynamic>;
      return list.map((item) => FoodModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<FoodModel?> getFoodById(String id) async {
    final foods = await getFoods();
    try {
      return foods.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveFoods(List<FoodModel> foods) async {
    final String jsonStr = jsonEncode(foods.map((f) => f.toJson()).toList());
    await _prefs.setString(AppConstants.foodsKey, jsonStr);
  }

  @override
  Future<void> addFood(FoodModel food) async {
    final foods = await getFoods();
    foods.add(food);
    await saveFoods(foods);
  }

  // --- ACTIVITIES ---
  @override
  Future<List<ActivityEventModel>> getActivities() async {
    final String? activitiesJson = _prefs.getString(AppConstants.activitiesKey);
    if (activitiesJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(activitiesJson) as List<dynamic>;
      return list
          .map((item) => ActivityEventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveActivities(List<ActivityEventModel> activities) async {
    final String jsonStr = jsonEncode(activities.map((a) => a.toJson()).toList());
    await _prefs.setString(AppConstants.activitiesKey, jsonStr);
  }

  // --- MEALS ---
  @override
  Future<List<MealModel>> getMeals() async {
    final String? mealsJson = _prefs.getString(AppConstants.mealsKey);
    if (mealsJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(mealsJson) as List<dynamic>;
      return list.map((item) => MealModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveMeals(List<MealModel> meals) async {
    final String jsonStr = jsonEncode(meals.map((m) => m.toJson()).toList());
    await _prefs.setString(AppConstants.mealsKey, jsonStr);
  }
}
