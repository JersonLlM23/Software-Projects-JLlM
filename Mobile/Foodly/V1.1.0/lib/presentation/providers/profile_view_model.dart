import 'package:flutter/foundation.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/calculate_age_usecase.dart';
import '../../domain/usecases/calculate_bmr_usecase.dart';
import '../../domain/usecases/clear_all_data_usecase.dart';
import '../../domain/usecases/get_user_usecase.dart';
import '../../domain/usecases/save_user_usecase.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetUserUseCase getUserUseCase;
  final SaveUserUseCase saveUserUseCase;
  final CalculateAgeUseCase calculateAgeUseCase;
  final CalculateBMRUseCase calculateBMRUseCase;
  final ClearAllDataUseCase? clearAllDataUseCase;

  ProfileViewModel({
    required this.getUserUseCase,
    required this.saveUserUseCase,
    this.calculateAgeUseCase = const CalculateAgeUseCase(),
    this.calculateBMRUseCase = const CalculateBMRUseCase(),
    this.clearAllDataUseCase,
  });

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Current age calculated dynamically from birthDate.
  int get calculatedAge {
    if (_user == null) return 0;
    return calculateAgeUseCase.execute(_user!.birthDate);
  }

  /// Current BMR calculated dynamically from user metrics using Mifflin-St Jeor.
  double get calculatedBmr {
    if (_user == null) return 0.0;
    return calculateBMRUseCase.execute(
      gender: _user!.gender,
      weightKg: _user!.weightKg,
      heightCm: _user!.heightCm,
      age: calculatedAge,
    );
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await getUserUseCase.execute();
    } catch (e) {
      _errorMessage = 'Error al cargar el perfil de usuario.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required DateTime birthDate,
    required Gender gender,
    required double weightKg,
    required double heightCm,
  }) async {
    // Validations
    if (name.trim().isEmpty) {
      _errorMessage = 'El nombre no puede estar vacío.';
      notifyListeners();
      return false;
    }

    if (weightKg <= 0) {
      _errorMessage = 'El peso debe ser mayor a 0 kg.';
      notifyListeners();
      return false;
    }

    if (heightCm <= 0) {
      _errorMessage = 'La altura debe ser mayor a 0 cm.';
      notifyListeners();
      return false;
    }

    if (birthDate.isAfter(DateTime.now())) {
      _errorMessage = 'La fecha de nacimiento no puede ser futura.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedUser = (_user ??
              User(
                id: 'default_user',
                name: name,
                birthDate: birthDate,
                gender: gender,
                weightKg: weightKg,
                heightCm: heightCm,
              ))
          .copyWith(
        name: name.trim(),
        birthDate: birthDate,
        gender: gender,
        weightKg: weightKg,
        heightCm: heightCm,
      );

      await saveUserUseCase.execute(updatedUser);
      _user = updatedUser;
      _successMessage = 'Perfil actualizado correctamente.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar los datos del perfil.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearAllData() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (clearAllDataUseCase != null) {
        await clearAllDataUseCase!.execute();
      }
      _user = await getUserUseCase.execute();
      _successMessage = 'Todos los datos han sido borrados correctamente.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al borrar los datos.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
