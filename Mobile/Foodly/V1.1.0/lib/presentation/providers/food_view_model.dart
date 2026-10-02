import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/food_entry.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/add_meal_usecase.dart';
import '../../domain/usecases/calculate_food_calories_usecase.dart';
import '../../domain/usecases/convert_energy_usecase.dart';
import '../../domain/usecases/get_foods_usecase.dart';
import '../../domain/usecases/update_meal_usecase.dart';

class FoodViewModel extends ChangeNotifier {
  final GetFoodsUseCase getFoodsUseCase;
  final AddMealUseCase addMealUseCase;
  final UpdateMealUseCase updateMealUseCase;
  final CalculateFoodCaloriesUseCase calculateFoodCaloriesUseCase;
  final ConvertEnergyUseCase convertEnergyUseCase;

  FoodViewModel({
    required this.getFoodsUseCase,
    required this.addMealUseCase,
    required this.updateMealUseCase,
    this.calculateFoodCaloriesUseCase = const CalculateFoodCaloriesUseCase(),
    this.convertEnergyUseCase = const ConvertEnergyUseCase(),
  });

  Meal? _editingMeal;
  String _mealName = 'Almuerzo';
  DateTime _dateTime = DateTime.now();
  List<FoodEntry> _items = [];
  String _notes = '';

  List<Food> _availableFoods = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditing => _editingMeal != null;
  String get mealName => _mealName;
  DateTime get dateTime => _dateTime;
  List<FoodEntry> get items => List.unmodifiable(_items);
  String get notes => _notes;
  List<Food> get availableFoods => _availableFoods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalMealEnergyKcal =>
      _items.fold<double>(0.0, (sum, item) => sum + item.calculatedEnergyKcal);

  Future<void> loadFoods() async {
    try {
      _availableFoods = await getFoodsUseCase.execute();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> initForNew({DateTime? baseDate}) async {
    _editingMeal = null;
    _mealName = _getDefaultMealName();
    _notes = '';
    _items = [];
    _errorMessage = null;

    final now = DateTime.now();
    if (baseDate != null) {
      _dateTime = DateTime(baseDate.year, baseDate.month, baseDate.day, now.hour, now.minute);
    } else {
      _dateTime = now;
    }

    await loadFoods();
    notifyListeners();
  }

  Future<void> initForEdit(Meal meal) async {
    _editingMeal = meal;
    _mealName = meal.name;
    _dateTime = meal.dateTime;
    _items = List.from(meal.items);
    _notes = meal.notes ?? '';
    _errorMessage = null;

    await loadFoods();
    notifyListeners();
  }

  String _getDefaultMealName() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return 'Desayuno';
    if (hour >= 11 && hour < 16) return 'Almuerzo';
    if (hour >= 16 && hour < 19) return 'Merienda';
    if (hour >= 19 && hour < 23) return 'Cena';
    return 'Snack';
  }

  void setMealName(String name) {
    _mealName = name;
    notifyListeners();
  }

  void setDateTime(DateTime dt) {
    _dateTime = dt;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  /// Adds a food entry with quantity based on food reference
  void addFoodEntry({
    required Food food,
    required double quantity,
    required String unit,
  }) {
    if (quantity <= 0) return;

    final double calories = calculateFoodCaloriesUseCase.execute(
      food: food,
      quantity: quantity,
    );

    final entry = FoodEntry(
      id: const Uuid().v4(),
      food: food,
      quantity: quantity,
      unit: unit,
      calculatedEnergyKcal: calories,
    );

    _items.add(entry);
    notifyListeners();
  }

  /// Adds a food entry with manual energy input in either kcal or kJ.
  /// Converts kJ to kcal automatically if unit is kJ.
  void addFoodEntryWithEnergy({
    required Food food,
    required double quantity,
    required String unit,
    required double energyValue,
    required String energyUnit, // 'kcal' or 'kJ'
  }) {
    if (quantity <= 0 || energyValue < 0) return;

    final double normalizedKcal =
        convertEnergyUseCase.normalizeToKcal(energyValue, energyUnit);

    final entry = FoodEntry(
      id: const Uuid().v4(),
      food: food,
      quantity: quantity,
      unit: unit,
      calculatedEnergyKcal: normalizedKcal,
    );

    _items.add(entry);
    notifyListeners();
  }

  void removeFoodEntry(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> saveMeal() async {
    if (_mealName.trim().isEmpty) {
      _errorMessage = 'El nombre de la comida no puede estar vacío.';
      notifyListeners();
      return false;
    }

    if (_items.isEmpty) {
      _errorMessage = 'Debes agregar al menos un alimento o bebida a la comida.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final meal = Meal(
        id: _editingMeal?.id ?? const Uuid().v4(),
        name: _mealName.trim(),
        dateTime: _dateTime,
        items: _items,
        notes: _notes.trim().isEmpty ? null : _notes.trim(),
      );

      if (isEditing) {
        await updateMealUseCase.execute(meal);
      } else {
        await addMealUseCase.execute(meal);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar la comida.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
