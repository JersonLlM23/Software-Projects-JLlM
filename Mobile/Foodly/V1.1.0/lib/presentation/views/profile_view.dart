import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/gender.dart';
import '../providers/balance_view_model.dart';
import '../providers/food_view_model.dart';
import '../providers/home_view_model.dart';
import '../providers/profile_view_model.dart';
import '../widgets/date_time_picker_field.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 23));
  Gender _gender = Gender.male;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<ProfileViewModel>();
      await vm.loadProfile();
      if (vm.user != null) {
        setState(() {
          _nameController.text = vm.user!.name;
          _weightController.text = vm.user!.weightKg.toString();
          _heightController.text = vm.user!.heightCm.toString();
          _birthDate = vm.user!.birthDate;
          _gender = vm.user!.gender;
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final weight =
        double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0.0;
    final height =
        double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 0.0;

    final success = await context.read<ProfileViewModel>().updateProfile(
          name: _nameController.text,
          birthDate: _birthDate,
          gender: _gender,
          weightKg: weight,
          heightCm: height,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil guardado exitosamente'),
          backgroundColor: AppColors.energyBalancePositive,
        ),
      );
    }
  }

  Future<void> _confirmClearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.energyBurned, size: 28),
              SizedBox(width: 10),
              Text(
                'Borrar todos los datos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: const Text(
            'Se eliminarán todos los datos guardados localmente (comidas, actividades e historial) '
            'y se restablecerá la aplicación a su estado inicial.\n\n'
            'Esta operación no se puede deshacer. ¿Deseas continuar?',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.energyBurned,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Borrar datos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final profileVm = context.read<ProfileViewModel>();
      final success = await profileVm.clearAllData();

      if (success && mounted) {
        // Reset all affected providers in memory
        final today = DateTime.now();
        final homeVm = context.read<HomeViewModel>();
        final foodVm = context.read<FoodViewModel>();
        final balanceVm = context.read<BalanceViewModel>();

        await Future.wait([
          homeVm.loadDayData(today),
          foodVm.loadFoods(),
          balanceVm.loadBalance(today),
        ]);

        if (!mounted) return;

        // Update local text fields to reflect the reset initial profile
        if (profileVm.user != null) {
          setState(() {
            _nameController.text = profileVm.user!.name;
            _weightController.text = profileVm.user!.weightKg.toString();
            _heightController.text = profileVm.user!.heightCm.toString();
            _birthDate = profileVm.user!.birthDate;
            _gender = profileVm.user!.gender;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se han borrado todos los datos correctamente'),
            backgroundColor: AppColors.energyBalancePositive,
          ),
        );
      }
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'FO';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim().substring(0, name.trim().length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final initials = _getInitials(_nameController.text);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar & Header
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text.isNotEmpty ? _nameController.text : 'Tu Perfil',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Usuario de Foodly',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Stats Row (Weight, Height, Age)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withAlpha(6),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat(
                          label: 'Peso',
                          value: '${vm.user?.weightKg.toStringAsFixed(1) ?? "--"} kg',
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppColors.border,
                        ),
                        _buildQuickStat(
                          label: 'Altura',
                          value: '${vm.user?.heightCm.toStringAsFixed(0) ?? "--"} cm',
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppColors.border,
                        ),
                        _buildQuickStat(
                          label: 'Edad',
                          value: '${vm.calculatedAge} años',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Basal Reference Card (SIMPLIFIED: No technical Mifflin-St Jeor formula!)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryContainer,
                          AppColors.primaryContainer.withAlpha(120),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withAlpha(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('🧬', style: TextStyle(fontSize: 18)),
                                SizedBox(width: 8),
                                Text(
                                  'Metabolismo basal estimado',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withAlpha(50)),
                              ),
                              child: Text(
                                '${vm.calculatedBmr.toStringAsFixed(0)} kcal / día',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Representa la energía diaria aproximada que tu organismo consume en reposo para sus funciones vitales.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Data Form Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Datos Personales',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Introduce tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Gender Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sexo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<Gender>(
                          segments: const [
                            ButtonSegment(
                              value: Gender.male,
                              label: Text('Hombre'),
                              icon: Icon(Icons.male_rounded),
                            ),
                            ButtonSegment(
                              value: Gender.female,
                              label: Text('Mujer'),
                              icon: Icon(Icons.female_rounded),
                            ),
                          ],
                          selected: {_gender},
                          onSelectionChanged: (set) {
                            setState(() {
                              _gender = set.first;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // BirthDate Picker
                  DateTimePickerField(
                    label: 'Fecha de nacimiento',
                    value: _birthDate,
                    showTime: false,
                    onChanged: (newDate) {
                      setState(() {
                        _birthDate = newDate;
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // Weight & Height
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Peso',
                            suffixText: 'kg',
                            prefixIcon: Icon(Icons.monitor_weight_outlined, size: 20),
                          ),
                          validator: (val) {
                            final w =
                                double.tryParse(val?.replaceAll(',', '.') ?? '');
                            if (w == null || w <= 0) {
                              return 'Inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Altura',
                            suffixText: 'cm',
                            prefixIcon: Icon(Icons.height_rounded, size: 20),
                          ),
                          validator: (val) {
                            final h =
                                double.tryParse(val?.replaceAll(',', '.') ?? '');
                            if (h == null || h <= 0) {
                              return 'Inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : _saveProfile,
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Guardar Cambios'),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Account / Data Management Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Gestión de Datos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.energyBurnedLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.energyBurned,
                            size: 22,
                          ),
                        ),
                        title: const Text(
                          'Borrar todos los datos',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.energyBurned,
                          ),
                        ),
                        subtitle: const Text(
                          'Elimina tus registros y restablece la app a su estado inicial',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onTap: _confirmClearAllData,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Discrete Version Footer (Requirement 7)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Foodly - Versión 1.1.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: AppColors.textMuted.withAlpha(200),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStat({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
