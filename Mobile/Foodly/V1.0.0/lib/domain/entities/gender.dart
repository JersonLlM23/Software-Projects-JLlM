/// Gender definition for metabolic calculations.
enum Gender {
  male,
  female;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Hombre';
      case Gender.female:
        return 'Mujer';
    }
  }

  static Gender fromString(String value) {
    if (value.toLowerCase() == 'female' || value.toLowerCase() == 'mujer') {
      return Gender.female;
    }
    return Gender.male;
  }
}
