import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/daily_balance.dart';

class BalanceSummaryCard extends StatelessWidget {
  final DateTime date;
  final DailyBalance? balance;
  final VoidCallback? onDetailsTap;

  const BalanceSummaryCard({
    super.key,
    required this.date,
    this.balance,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isToday = DateTimeUtils.isSameDay(date, DateTime.now());
    final dateLabel = isToday ? 'Hoy' : 'Día';
    final dateString = DateTimeUtils.formatFullDate(date);

    final consumed = balance?.consumedEnergyKcal ?? 0.0;
    final expended = balance?.expendedEnergyKcal ?? 0.0;
    final netBalance = balance?.balanceKcal ?? 0.0;
    final balanceStatus = balance?.balanceStatusDescription ?? 'Estimado';

    Color balanceColor = AppColors.energyBalancePositive;
    if (netBalance < -50) {
      balanceColor = AppColors.energyBalanceDeficit;
    } else if (netBalance > 50) {
      balanceColor = AppColors.energyConsumed;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateString,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (onDetailsTap != null)
                IconButton(
                  icon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                  tooltip: 'Ver detalles de balance y BMR',
                  onPressed: onDetailsTap,
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Metrics row (Gastadas, Consumidas, Balance)
          Row(
            children: [
              // Gastadas
              Expanded(
                child: _buildMetricItem(
                  icon: '🔥',
                  title: 'Gastadas',
                  value: '${expended.toStringAsFixed(0)} kcal',
                  color: AppColors.energyBurned,
                  bgColor: AppColors.energyBurnedLight,
                ),
              ),
              const SizedBox(width: 10),

              // Consumidas
              Expanded(
                child: _buildMetricItem(
                  icon: '🍽️',
                  title: 'Consumidas',
                  value: '${consumed.toStringAsFixed(0)} kcal',
                  color: AppColors.energyConsumed,
                  bgColor: AppColors.energyConsumedLight,
                ),
              ),
              const SizedBox(width: 10),

              // Balance
              Expanded(
                child: _buildMetricItem(
                  icon: '⚖️',
                  title: 'Balance',
                  value: '${netBalance >= 0 ? '+' : ''}${netBalance.toStringAsFixed(0)} kcal',
                  subtitle: balanceStatus,
                  color: balanceColor,
                  bgColor: AppColors.energyBalanceLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Disclaimer note
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Balance energético estimado (Consumo - Gasto)',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted.withAlpha(220),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: color.withAlpha(200),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
