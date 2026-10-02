import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/gender.dart';
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

    final weight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0.0;
    final height = double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 0.0;

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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calculated metrics card (Dynamic Age & Dynamic BMR)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Metabolismo Basal (BMR)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Edad: ${vm.calculatedAge} años',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              vm.calculatedBmr.toStringAsFixed(0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'kcal / día',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Estimación según fórmula Mifflin-St Jeor a partir de sexo, peso, altura y edad calculada.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (vm.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.energyBurnedLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.energyBurned),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.energyBurned, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              vm.errorMessage!,
                              style: const TextStyle(color: AppColors.energyBurned, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Datos Personales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Introduce tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Gender selector
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
                              icon: Icon(Icons.male),
                            ),
                            ButtonSegment(
                              value: Gender.female,
                              label: Text('Mujer'),
                              icon: Icon(Icons.female),
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
                  const SizedBox(height: 16),

                  // BirthDate picker (dynamic age calculated)
                  DateTimePickerField(
                    label: 'Fecha de nacimiento (La edad se calcula automáticamente)',
                    value: _birthDate,
                    showTime: false,
                    onChanged: (newDate) {
                      setState(() {
                        _birthDate = newDate;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Weight & Height fields
                  Row(
                    children: [
                      // Weight
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Peso',
                            suffixText: 'kg',
                            prefixIcon: Icon(Icons.monitor_weight_outlined, size: 20),
                          ),
                          validator: (val) {
                            final w = double.tryParse(val?.replaceAll(',', '.') ?? '');
                            if (w == null || w <= 0) {
                              return 'Peso inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Height
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Altura',
                            suffixText: 'cm',
                            prefixIcon: Icon(Icons.height, size: 20),
                          ),
                          validator: (val) {
                            final h = double.tryParse(val?.replaceAll(',', '.') ?? '');
                            if (h == null || h <= 0) {
                              return 'Altura inválida';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : _saveProfile,
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
