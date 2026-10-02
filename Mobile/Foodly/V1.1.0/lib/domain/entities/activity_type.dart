/// Activity types supported in v1.0.0
enum ActivityType {
  walking,
  sleeping,
  studying;

  String get displayName {
    switch (this) {
      case ActivityType.walking:
        return 'Caminar';
      case ActivityType.sleeping:
        return 'Dormir';
      case ActivityType.studying:
        return 'Estudiar';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.walking:
        return '🚶';
      case ActivityType.sleeping:
        return '😴';
      case ActivityType.studying:
        return '📚';
    }
  }

  static ActivityType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'caminar':
      case 'walking':
        return ActivityType.walking;
      case 'dormir':
      case 'sleeping':
        return ActivityType.sleeping;
      case 'estudiar':
      case 'studying':
        return ActivityType.studying;
      default:
        return ActivityType.walking;
    }
  }
}
