/// Use case to compute a user's exact current age from their birthDate.
class CalculateAgeUseCase {
  const CalculateAgeUseCase();

  /// Calculates age given a birthDate and an optional target date (defaults to now).
  int execute(DateTime birthDate, {DateTime? currentDate}) {
    final now = currentDate ?? DateTime.now();
    int age = now.year - birthDate.year;

    // Check if the birthday has occurred yet this year
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age < 0 ? 0 : age;
  }
}
