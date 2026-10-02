/// Core constants for energy, units, and system-wide defaults.
class AppConstants {
  AppConstants._();

  // Energy Conversion
  static const double kjPerKcal = 4.184;

  // Default initial user data
  static const String defaultUserName = 'Usuario';
  static const int defaultInitialAge = 23;
  static const double defaultInitialWeightKg = 55.0;
  static const double defaultInitialHeightCm = 165.0;

  // Persistence keys
  static const String userKey = 'daily_balance_user';
  static const String foodsKey = 'daily_balance_foods';
  static const String activitiesKey = 'daily_balance_activities';
  static const String mealsKey = 'daily_balance_meals';
}
