import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/daily_balance.dart';

/// Card showing energy summary (Gastadas, Consumidas, Balance)
/// plus a dynamic orientation card guiding the user regarding their daily balance.
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

    Color balanceColor = AppColors.energyBalancePositive;
    if (netBalance < -10) {
      balanceColor = AppColors.energyBalanceDeficit;
    } else if (netBalance > 10) {
      balanceColor = AppColors.energyBalanceSurplus;
    }

    // Determine dynamic orientation card message and styling
    final orientationInfo = _getOrientationInfo(consumed: consumed, expended: expended);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date & optional details icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dateLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateString,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onDetailsTap != null)
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 22),
                  tooltip: 'Ver desglose energético',
                  onPressed: onDetailsTap,
                ),
            ],
          ),
          const SizedBox(height: 18),

          // 3 Metric Cards: Gastadas, Consumidas, Balance
          Row(
            children: [
              // Gastadas
              Expanded(
                child: _buildMetricItem(
                  icon: '🔥',
                  title: 'Calorías gastadas',
                  value: '${expended.toStringAsFixed(0)} kcal',
                  color: AppColors.energyBurned,
                  bgColor: AppColors.energyBurnedLight,
                ),
              ),
              const SizedBox(width: 8),

              // Consumidas
              Expanded(
                child: _buildMetricItem(
                  icon: '🍽️',
                  title: 'Calorías consumidas',
                  value: '${consumed.toStringAsFixed(0)} kcal',
                  color: AppColors.energyConsumed,
                  bgColor: AppColors.energyConsumedLight,
                ),
              ),
              const SizedBox(width: 8),

              // Balance
              Expanded(
                child: _buildMetricItem(
                  icon: '⚖️',
                  title: 'Balance del día',
                  value: '${netBalance >= 0 ? '+' : ''}${netBalance.toStringAsFixed(0)} kcal',
                  color: balanceColor,
                  bgColor: AppColors.energyBalanceLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Small Dynamic Orientation Card (Requirement 6)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: orientationInfo.bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: orientationInfo.borderColor),
            ),
            child: Row(
              children: [
                Text(
                  orientationInfo.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orientationInfo.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: orientationInfo.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        orientationInfo.message,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: orientationInfo.textColor.withAlpha(220),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Calculates dynamic orientation message based on registered consumed and expended calories.
  _OrientationInfo _getOrientationInfo({
    required double consumed,
    required double expended,
  }) {
    // If no information has been logged yet
    if (consumed == 0 && expended == 0) {
      return _OrientationInfo(
        icon: '🌱',
        title: 'Tu balance',
        message: 'Registra tus comidas y actividades para ver la orientación de hoy.',
        bgColor: AppColors.background,
        borderColor: AppColors.border,
        textColor: AppColors.textSecondary,
      );
    }

    final diff = consumed - expended;

    if (diff > 50) {
      return _OrientationInfo(
        icon: '🍽️',
        title: 'Tu consumo supera tu gasto registrado',
        message: 'Has registrado un balance energético por encima del gasto en actividades.',
        bgColor: AppColors.energyConsumedLight,
        borderColor: AppColors.energyConsumed.withAlpha(60),
        textColor: AppColors.energyBalanceSurplus,
      );
    } else if (diff < -50) {
      return _OrientationInfo(
        icon: '🏃',
        title: 'Tu gasto supera tu consumo registrado',
        message: 'Has registrado un balance energético por debajo de lo consumido.',
        bgColor: const Color(0xFFF0F9FF),
        borderColor: AppColors.energyBalanceDeficit.withAlpha(60),
        textColor: AppColors.energyBalanceDeficit,
      );
    } else {
      return _OrientationInfo(
        icon: '⚖️',
        title: 'Tu consumo y tu gasto están equilibrados',
        message: 'Tus registros de consumo y gasto calórico se mantienen nivelados.',
        bgColor: AppColors.energyBalanceLight,
        borderColor: AppColors.energyBalancePositive.withAlpha(60),
        textColor: AppColors.energyBalancePositive,
      );
    }
  }
}

class _OrientationInfo {
  final String icon;
  final String title;
  final String message;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  _OrientationInfo({
    required this.icon,
    required this.title,
    required this.message,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}
