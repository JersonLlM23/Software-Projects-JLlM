import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/local_data_source.dart';
import 'data/repositories/activity_repository_impl.dart';
import 'data/repositories/food_repository_impl.dart';
import 'data/repositories/meal_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/activity_repository.dart';
import 'domain/repositories/food_repository.dart';
import 'domain/repositories/meal_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/add_activity_event_usecase.dart';
import 'domain/usecases/add_meal_usecase.dart';
import 'domain/usecases/calculate_activity_calories_usecase.dart';
import 'domain/usecases/calculate_age_usecase.dart';
import 'domain/usecases/calculate_bmr_usecase.dart';
import 'domain/usecases/calculate_daily_balance_usecase.dart';
import 'domain/usecases/calculate_food_calories_usecase.dart';
import 'domain/usecases/clear_all_data_usecase.dart';
import 'domain/usecases/convert_energy_usecase.dart';
import 'domain/usecases/delete_activity_event_usecase.dart';
import 'domain/usecases/delete_meal_usecase.dart';
import 'domain/usecases/get_daily_timeline_usecase.dart';
import 'domain/usecases/get_foods_usecase.dart';
import 'domain/usecases/get_user_usecase.dart';
import 'domain/usecases/save_user_usecase.dart';
import 'domain/usecases/update_activity_event_usecase.dart';
import 'domain/usecases/update_meal_usecase.dart';
import 'presentation/providers/activity_view_model.dart';
import 'presentation/providers/balance_view_model.dart';
import 'presentation/providers/food_view_model.dart';
import 'presentation/providers/home_view_model.dart';
import 'presentation/providers/profile_view_model.dart';
import 'presentation/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Data Source & Persistent Storage Initializer
  final sharedPreferences = await SharedPreferences.getInstance();
  final localDataSource = LocalDataSourceImpl(sharedPreferences);
  await localDataSource.initSeedsIfNeeded();

  // 2. Repositories (Data Layer implementations of Domain Interfaces)
  final UserRepository userRepository = UserRepositoryImpl(localDataSource);
  final FoodRepository foodRepository = FoodRepositoryImpl(localDataSource);
  final ActivityRepository activityRepository = ActivityRepositoryImpl(localDataSource);
  final MealRepository mealRepository = MealRepositoryImpl(localDataSource);

  // 3. Domain Use Cases
  const calculateAgeUseCase = CalculateAgeUseCase();
  const calculateBMRUseCase = CalculateBMRUseCase();
  const calculateActivityCaloriesUseCase = CalculateActivityCaloriesUseCase();
  const calculateFoodCaloriesUseCase = CalculateFoodCaloriesUseCase();
  const convertEnergyUseCase = ConvertEnergyUseCase();

  final getUserUseCase = GetUserUseCase(userRepository);
  final saveUserUseCase = SaveUserUseCase(userRepository);
  final clearAllDataUseCase = ClearAllDataUseCase(userRepository);
  final getFoodsUseCase = GetFoodsUseCase(foodRepository);

  final addActivityEventUseCase = AddActivityEventUseCase(activityRepository);
  final updateActivityEventUseCase = UpdateActivityEventUseCase(activityRepository);
  final deleteActivityEventUseCase = DeleteActivityEventUseCase(activityRepository);

  final addMealUseCase = AddMealUseCase(mealRepository);
  final updateMealUseCase = UpdateMealUseCase(mealRepository);
  final deleteMealUseCase = DeleteMealUseCase(mealRepository);

  final getDailyTimelineUseCase = GetDailyTimelineUseCase(
    activityRepository,
    mealRepository,
  );

  final calculateDailyBalanceUseCase = CalculateDailyBalanceUseCase(
    userRepository: userRepository,
    activityRepository: activityRepository,
    mealRepository: mealRepository,
    calculateAgeUseCase: calculateAgeUseCase,
    calculateBMRUseCase: calculateBMRUseCase,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            getUserUseCase: getUserUseCase,
            saveUserUseCase: saveUserUseCase,
            calculateAgeUseCase: calculateAgeUseCase,
            calculateBMRUseCase: calculateBMRUseCase,
            clearAllDataUseCase: clearAllDataUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            getDailyTimelineUseCase: getDailyTimelineUseCase,
            calculateDailyBalanceUseCase: calculateDailyBalanceUseCase,
            deleteActivityEventUseCase: deleteActivityEventUseCase,
            deleteMealUseCase: deleteMealUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityViewModel(
            addActivityEventUseCase: addActivityEventUseCase,
            updateActivityEventUseCase: updateActivityEventUseCase,
            getUserUseCase: getUserUseCase,
            calculateCaloriesUseCase: calculateActivityCaloriesUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FoodViewModel(
            getFoodsUseCase: getFoodsUseCase,
            addMealUseCase: addMealUseCase,
            updateMealUseCase: updateMealUseCase,
            calculateFoodCaloriesUseCase: calculateFoodCaloriesUseCase,
            convertEnergyUseCase: convertEnergyUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BalanceViewModel(
            calculateDailyBalanceUseCase: calculateDailyBalanceUseCase,
          ),
        ),
      ],
      child: const FoodlyApp(),
    ),
  );
}

class FoodlyApp extends StatelessWidget {
  const FoodlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      home: const SplashView(),
    );
  }
}

// Backward-compatibility alias
typedef DailyBalanceApp = FoodlyApp;
