import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/energy_converter.dart';
import '../../domain/entities/timeline_event.dart';
import '../providers/activity_view_model.dart';
import '../providers/food_view_model.dart';
import '../providers/home_view_model.dart';
import '../widgets/confirm_dialog.dart';
import 'activity_form_view.dart';
import 'meal_form_view.dart';

class TimelineEventDetailView extends StatelessWidget {
  final TimelineEvent event;

  const TimelineEventDetailView({
    super.key,
    required this.event,
  });

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '¿Eliminar evento?',
      content: '¿Estás seguro de que deseas eliminar este registro de la timeline? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<HomeViewModel>().deleteEvent(event);
      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleEdit(BuildContext context) {
    if (event.type == TimelineEventType.activity && event.activityEvent != null) {
      context.read<ActivityViewModel>().initForEdit(event.activityEvent!);
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => const ActivityFormView(),
            ),
          )
          .then((_) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
    } else if (event.type == TimelineEventType.meal && event.meal != null) {
      context.read<FoodViewModel>().initForEdit(event.meal!);
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => const MealFormView(),
            ),
          )
          .then((_) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActivity = event.type == TimelineEventType.activity;
    final totalKj = EnergyConverter.kcalToKj(event.energyKcal);

    return Scaffold(
      appBar: AppBar(
        title: Text(isActivity ? 'Detalle de Actividad' : 'Detalle de Comida'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => _handleEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.energyBurned),
            tooltip: 'Eliminar',
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isActivity ? AppColors.energyBurnedLight : AppColors.energyConsumedLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(event.icon, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateTimeUtils.formatFullDate(event.startDateTime),
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isActivity ? AppColors.energyBurned : AppColors.energyConsumed).withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${isActivity ? '-' : '+'}${event.energyKcal.toStringAsFixed(1)} kcal (${EnergyConverter.formatKj(totalKj)} kJ)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isActivity ? AppColors.energyBurned : AppColors.energyConsumed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Specific Details Card
            if (isActivity && event.activityEvent != null) ...[
              _buildSectionTitle('Información de la Actividad'),
              const SizedBox(height: 10),
              _buildDetailCard([
                _buildInfoRow('Tipo', event.activityEvent!.type.displayName),
                if (event.activityEvent!.intensity != null)
                  _buildInfoRow('Intensidad', event.activityEvent!.intensity!.displayName),
                _buildInfoRow(
                  'Horario',
                  DateTimeUtils.formatTimeRange(
                    event.activityEvent!.startDateTime,
                    event.activityEvent!.endDateTime,
                  ),
                ),
                _buildInfoRow(
                  'Duración',
                  DateTimeUtils.formatDuration(event.activityEvent!.durationInMinutes),
                ),
                if (event.activityEvent!.notes != null &&
                    event.activityEvent!.notes!.isNotEmpty)
                  _buildInfoRow('Notas', event.activityEvent!.notes!),
              ]),
            ],

            if (!isActivity && event.meal != null) ...[
              _buildSectionTitle('Alimentos consumidos (${event.meal!.items.length})'),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: event.meal!.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (ctx, idx) {
                  final item = event.meal!.items[idx];
                  final qStr = item.quantity % 1 == 0
                      ? item.quantity.toInt().toString()
                      : item.quantity.toString();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Text(item.food.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.food.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '$qStr ${item.unit}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.calculatedEnergyKcal.toStringAsFixed(1)} kcal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.energyConsumed,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (event.meal!.notes != null && event.meal!.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Notas'),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    event.meal!.notes!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 30),

            // Actions (Edit and Delete)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleDelete(context),
                    icon: const Icon(Icons.delete_outline, color: AppColors.energyBurned),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(color: AppColors.energyBurned, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleEdit(context),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar Evento'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
