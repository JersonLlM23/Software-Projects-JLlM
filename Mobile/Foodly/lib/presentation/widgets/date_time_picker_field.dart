import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';

class DateTimePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final bool showDate;
  final bool showTime;

  const DateTimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDate = true,
    this.showTime = true,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    DateTime selected = value;

    if (showDate) {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selected,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        locale: const Locale('es'),
      );
      if (pickedDate == null) return;
      selected = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        selected.hour,
        selected.minute,
      );
    }

    if (showTime && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selected),
      );
      if (pickedTime == null) return;
      selected = DateTime(
        selected.year,
        selected.month,
        selected.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }

    onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    String formattedText = '';
    if (showDate && showTime) {
      formattedText = '${DateTimeUtils.formatShortDate(value)}  ${DateTimeUtils.formatTime(value)}';
    } else if (showDate) {
      formattedText = DateTimeUtils.formatFullDate(value);
    } else if (showTime) {
      formattedText = DateTimeUtils.formatTime(value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _pickDateTime(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  showTime && !showDate ? Icons.access_time : Icons.calendar_today,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formattedText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
