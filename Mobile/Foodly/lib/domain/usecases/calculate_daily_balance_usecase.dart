import '../entities/daily_balance.dart';
import '../repositories/activity_repository.dart';
import '../repositories/meal_repository.dart';
import '../repositories/user_repository.dart';
import 'calculate_age_usecase.dart';
import 'calculate_bmr_usecase.dart';

/// Calculates the overall estimated daily balance for a specified date.
/// Formula: Balance = Consumed Energy - Expended Energy
class CalculateDailyBalanceUseCase {
  final UserRepository userRepository;
  final ActivityRepository activityRepository;
  final MealRepository mealRepository;
  final CalculateAgeUseCase calculateAgeUseCase;
  final CalculateBMRUseCase calculateBMRUseCase;

  const CalculateDailyBalanceUseCase({
    required this.userRepository,
    required this.activityRepository,
    required this.mealRepository,
    this.calculateAgeUseCase = const CalculateAgeUseCase(),
    this.calculateBMRUseCase = const CalculateBMRUseCase(),
  });

  Future<DailyBalance> execute(DateTime date) async {
    // 1. Calculate Intake
    final meals = await mealRepository.getMealsByDate(date);
    final double consumed = meals.fold<double>(
      0.0,
      (sum, meal) => sum + meal.totalEnergyKcal,
    );

    // 2. Calculate Expenditure
    final activities = await activityRepository.getActivitiesByDate(date);
    final double expended = activities.fold<double>(
      0.0,
      (sum, activity) => sum + activity.calculatedEnergyKcal,
    );

    // 3. Calculate BMR reference
    final user = await userRepository.getUser();
    double bmr = 0.0;
    if (user != null) {
      final age = calculateAgeUseCase.execute(user.birthDate, currentDate: date);
      bmr = calculateBMRUseCase.execute(
        gender: user.gender,
        weightKg: user.weightKg,
        heightCm: user.heightCm,
        age: age,
      );
    }

    return DailyBalance(
      date: date,
      consumedEnergyKcal: consumed,
      expendedEnergyKcal: expended,
      bmrKcal: bmr,
    );
  }
}
