import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/energy_converter.dart';
import '../../domain/entities/food.dart';
import '../providers/food_view_model.dart';
import '../widgets/date_time_picker_field.dart';
import '../widgets/energy_input_field.dart';

class MealFormView extends StatefulWidget {
  const MealFormView({super.key});

  @override
  State<MealFormView> createState() => _MealFormViewState();
}

class _MealFormViewState extends State<MealFormView> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<FoodViewModel>();
    _nameController = TextEditingController(text: vm.mealName);
    _notesController = TextEditingController(text: vm.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddFoodDialog(BuildContext context) {
    final vm = context.read<FoodViewModel>();
    if (vm.availableFoods.isEmpty) return;

    Food selectedFood = vm.availableFoods.first;
    double quantity = selectedFood.servingAmount;
    final quantityController = TextEditingController(
      text: selectedFood.servingAmount % 1 == 0
          ? selectedFood.servingAmount.toInt().toString()
          : selectedFood.servingAmount.toString(),
    );
    bool customEnergyMode = false;
    double customKcal = selectedFood.energyKcal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double calculatedKcal = 0.0;
            if (customEnergyMode) {
              calculatedKcal = customKcal;
            } else {
              calculatedKcal = selectedFood.servingAmount > 0
                  ? (quantity / selectedFood.servingAmount) * selectedFood.energyKcal
                  : 0.0;
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agregar Alimento / Bebida',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Food dropdown selector
                    const Text(
                      'Alimento',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Food>(
                          isExpanded: true,
                          value: selectedFood,
                          items: vm.availableFoods.map((f) {
                            return DropdownMenuItem<Food>(
                              value: f,
                              child: Row(
                                children: [
                                  Text(f.icon, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      f.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    f.servingDescription,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newFood) {
                            if (newFood == null) return;
                            setModalState(() {
                              selectedFood = newFood;
                              quantity = newFood.servingAmount;
                              quantityController.text = newFood.servingAmount % 1 == 0
                                  ? newFood.servingAmount.toInt().toString()
                                  : newFood.servingAmount.toString();
                              customKcal = newFood.energyKcal;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quantity input with unit label
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cantidad (${selectedFood.servingUnit})',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: quantityController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  suffixText: selectedFood.servingUnit,
                                ),
                                onChanged: (val) {
                                  final q = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                                  setModalState(() {
                                    quantity = q;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Custom energy switch (kcal / kJ input)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Personalizar valor energético',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Switch(
                          value: customEnergyMode,
                          onChanged: (val) {
                            setModalState(() {
                              customEnergyMode = val;
                            });
                          },
                        ),
                      ],
                    ),

                    if (customEnergyMode) ...[
                      const SizedBox(height: 8),
                      EnergyInputField(
                        label: 'Energía personalizada (kcal / kJ)',
                        initialKcal: calculatedKcal,
                        onKcalChanged: (newKcal) {
                          setModalState(() {
                            customKcal = newKcal;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Calculated energy summary in dialog
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.energyConsumedLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.energyConsumed.withAlpha(50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Energía calculada:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${calculatedKcal.toStringAsFixed(1)} kcal  (${EnergyConverter.formatKj(EnergyConverter.kcalToKj(calculatedKcal))} kJ)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.energyConsumed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.energyConsumed,
                        ),
                        onPressed: quantity <= 0
                            ? null
                            : () {
                                if (customEnergyMode) {
                                  vm.addFoodEntryWithEnergy(
                                    food: selectedFood,
                                    quantity: quantity,
                                    unit: selectedFood.servingUnit,
                                    energyValue: customKcal,
                                    energyUnit: 'kcal',
                                  );
                                } else {
                                  vm.addFoodEntry(
                                    food: selectedFood,
                                    quantity: quantity,
                                    unit: selectedFood.servingUnit,
                                  );
                                }
                                Navigator.of(ctx).pop();
                              },
                        child: const Text('Agregar a la Comida'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveMeal() async {
    final vm = context.read<FoodViewModel>();
    vm.setMealName(_nameController.text);
    vm.setNotes(_notesController.text);
    final success = await vm.saveMeal();
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodViewModel>(
      builder: (context, vm, child) {
        final isEditing = vm.isEditing;
        final totalKcal = vm.totalMealEnergyKcal;
        final totalKj = EnergyConverter.kcalToKj(totalKcal);

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Editar Comida' : 'Registrar Comida'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick meal name chips
                const Text(
                  'Nombre de la Comida',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Desayuno', 'Almuerzo', 'Merienda', 'Cena', 'Snack'].map((name) {
                    final isSelected = _nameController.text == name;
                    return ChoiceChip(
                      label: Text(name),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _nameController.text = name;
                            vm.setMealName(name);
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                // Name custom textfield
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Ej. Almuerzo, Cena...',
                    prefixIcon: Icon(Icons.restaurant, size: 20),
                  ),
                  onChanged: (val) => vm.setMealName(val),
                ),
                const SizedBox(height: 16),

                // DateTime picker
                DateTimePickerField(
                  label: 'Fecha y Hora del Consumo',
                  value: vm.dateTime,
                  onChanged: (newDt) => vm.setDateTime(newDt),
                ),
                const SizedBox(height: 22),

                // Food items section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alimentos y Bebidas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddFoodDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar alimento'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.energyConsumed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Food entries list
                if (vm.items.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.lunch_dining_outlined, size: 36, color: AppColors.textMuted),
                        const SizedBox(height: 8),
                        const Text(
                          'No has agregado ningún alimento aún.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddFoodDialog(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Seleccionar Alimento'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.energyConsumed,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (ctx, index) {
                      final entry = vm.items[index];
                      final qStr = entry.quantity % 1 == 0
                          ? entry.quantity.toInt().toString()
                          : entry.quantity.toString();

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Text(entry.food.icon, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.food.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '$qStr ${entry.unit}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${entry.calculatedEnergyKcal.toStringAsFixed(1)} kcal',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.energyConsumed,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textMuted),
                              onPressed: () => vm.removeFoodEntry(index),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 18),

                // Total summary card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.energyConsumedLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.energyConsumed.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total de la Comida:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${totalKcal.toStringAsFixed(1)} kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.energyConsumed,
                            ),
                          ),
                          Text(
                            '${EnergyConverter.formatKj(totalKj)} kJ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Optional Notes
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notas (Opcional)',
                    hintText: 'Ej. Almuerzo familiar...',
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: vm.isLoading ? null : _saveMeal,
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            isEditing ? 'Guardar Cambios' : 'Registrar Comida',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
