import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/energy_converter.dart';

class EnergyInputField extends StatefulWidget {
  final String label;
  final ValueChanged<double> onKcalChanged;
  final double initialKcal;

  const EnergyInputField({
    super.key,
    required this.label,
    required this.onKcalChanged,
    this.initialKcal = 0.0,
  });

  @override
  State<EnergyInputField> createState() => _EnergyInputFieldState();
}

class _EnergyInputFieldState extends State<EnergyInputField> {
  late TextEditingController _controller;
  String _selectedUnit = 'kcal'; // 'kcal' or 'kJ'

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialKcal > 0
          ? (_selectedUnit == 'kcal'
              ? EnergyConverter.formatKcal(widget.initialKcal)
              : EnergyConverter.formatKj(EnergyConverter.kcalToKj(widget.initialKcal)))
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onValueChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
    if (_selectedUnit == 'kJ') {
      final kcal = EnergyConverter.kjToKcal(parsed);
      widget.onKcalChanged(kcal);
    } else {
      widget.onKcalChanged(parsed);
    }
  }

  void _onUnitChanged(String newUnit) {
    if (newUnit == _selectedUnit) return;
    final currentVal = double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0.0;

    double convertedVal;
    if (newUnit == 'kJ') {
      convertedVal = EnergyConverter.kcalToKj(currentVal);
    } else {
      convertedVal = EnergyConverter.kjToKcal(currentVal);
    }

    setState(() {
      _selectedUnit = newUnit;
      _controller.text = currentVal > 0
          ? (_selectedUnit == 'kcal'
              ? EnergyConverter.formatKcal(convertedVal)
              : EnergyConverter.formatKj(convertedVal))
          : '';
    });

    _onValueChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: _onValueChanged,
                decoration: InputDecoration(
                  hintText: '0',
                  suffixIcon: Container(
                    padding: const EdgeInsets.all(4),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'kcal', label: Text('kcal', style: TextStyle(fontSize: 12))),
                        ButtonSegment(value: 'kJ', label: Text('kJ', style: TextStyle(fontSize: 12))),
                      ],
                      selected: {_selectedUnit},
                      onSelectionChanged: (set) => _onUnitChanged(set.first),
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 6)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
