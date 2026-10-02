import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/activity_intensity.dart';
import '../../domain/entities/activity_type.dart';
import '../providers/activity_view_model.dart';
import '../widgets/date_time_picker_field.dart';

class ActivityFormView extends StatefulWidget {
  const ActivityFormView({super.key});

  @override
  State<ActivityFormView> createState() => _ActivityFormViewState();
}

class _ActivityFormViewState extends State<ActivityFormView> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: context.read<ActivityViewModel>().notes,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    final vm = context.read<ActivityViewModel>();
    vm.setNotes(_notesController.text);
    final success = await vm.saveActivity();
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityViewModel>(
      builder: (context, vm, child) {
        final isEditing = vm.isEditing;
        final durationMinutes = vm.durationInMinutes;
        final estimatedKcal = vm.estimatedCaloriesBurned;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Editar Actividad' : 'Registrar Actividad'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity Type Selector
                const Text(
                  'Tipo de Actividad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeCard(
                        type: ActivityType.walking,
                        isSelected: vm.selectedType == ActivityType.walking,
                        onTap: () => vm.setType(ActivityType.walking),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTypeCard(
                        type: ActivityType.sleeping,
                        isSelected: vm.selectedType == ActivityType.sleeping,
                        onTap: () => vm.setType(ActivityType.sleeping),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTypeCard(
                        type: ActivityType.studying,
                        isSelected: vm.selectedType == ActivityType.studying,
                        onTap: () => vm.setType(ActivityType.studying),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Intensity Selector (Only for Walking)
                if (vm.selectedType == ActivityType.walking) ...[
                  const Text(
                    'Intensidad del Paso',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ActivityIntensity>(
                      segments: const [
                        ButtonSegment(
                          value: ActivityIntensity.slow,
                          label: Text('Lento'),
                        ),
                        ButtonSegment(
                          value: ActivityIntensity.normal,
                          label: Text('Normal'),
                        ),
                        ButtonSegment(
                          value: ActivityIntensity.fast,
                          label: Text('Rápido'),
                        ),
                      ],
                      selected: {vm.selectedIntensity},
                      onSelectionChanged: (set) => vm.setIntensity(set.first),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Start and End DateTime pickers
                DateTimePickerField(
                  label: 'Inicio (Fecha y hora)',
                  value: vm.startDateTime,
                  onChanged: (newStart) => vm.setStartDateTime(newStart),
                ),
                const SizedBox(height: 14),

                DateTimePickerField(
                  label: 'Finalización (Fecha y hora)',
                  value: vm.endDateTime,
                  onChanged: (newEnd) => vm.setEndDateTime(newEnd),
                ),
                const SizedBox(height: 18),

                // Live calculation display card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.energyBurnedLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.energyBurned.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Duración',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateTimeUtils.formatDuration(durationMinutes),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: AppColors.energyBurned.withAlpha(40),
                      ),
                      Column(
                        children: [
                          const Text(
                            'Gasto estimado',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.energyBurned,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${estimatedKcal.toStringAsFixed(1)} kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.energyBurned,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Optional Notes
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notas (Opcional)',
                    hintText: 'Ej. Caminata por el parque...',
                  ),
                ),

                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: AppColors.energyBurned, fontSize: 13),
                  ),
                ],

                const SizedBox(height: 28),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _saveActivity,
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEditing ? 'Guardar Cambios' : 'Registrar Actividad',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeCard({
    required ActivityType type,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(type.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
