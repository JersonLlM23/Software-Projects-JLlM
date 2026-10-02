import '../../domain/entities/food.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/food_model.dart';

class FoodRepositoryImpl implements FoodRepository {
  final LocalDataSource _localDataSource;

  FoodRepositoryImpl(this._localDataSource);

  @override
  Future<List<Food>> getFoods() async {
    final models = await _localDataSource.getFoods();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Food?> getFoodById(String id) async {
    final model = await _localDataSource.getFoodById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveFoods(List<Food> foods) async {
    final models = foods.map((f) => FoodModel.fromEntity(f)).toList();
    await _localDataSource.saveFoods(models);
  }

  @override
  Future<void> addFood(Food food) async {
    final model = FoodModel.fromEntity(food);
    await _localDataSource.addFood(model);
  }
}
