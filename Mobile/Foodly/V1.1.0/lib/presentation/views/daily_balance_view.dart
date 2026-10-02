import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/energy_converter.dart';
import '../providers/balance_view_model.dart';

class DailyBalanceView extends StatefulWidget {
  final DateTime date;

  const DailyBalanceView({
    super.key,
    required this.date,
  });

  @override
  State<DailyBalanceView> createState() => _DailyBalanceViewState();
}

class _DailyBalanceViewState extends State<DailyBalanceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BalanceViewModel>().loadBalance(widget.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance del Día'),
      ),
      body: Consumer<BalanceViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final consumed = vm.consumedKcal;
          final expended = vm.expendedKcal;
          final balance = vm.balanceKcal;
          final bmr = vm.bmrKcal;

          Color balanceColor = AppColors.energyBalancePositive;
          if (balance < -10) {
            balanceColor = AppColors.energyBalanceDeficit;
          } else if (balance > 10) {
            balanceColor = AppColors.energyBalanceSurplus;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        DateTimeUtils.formatFullDate(widget.date),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Main Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        balanceColor.withAlpha(25),
                        balanceColor.withAlpha(10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: balanceColor.withAlpha(60)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'BALANCE DEL DÍA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: balanceColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(1)} kcal',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: balanceColor,
                        ),
                      ),
                      Text(
                        '${balance >= 0 ? '+' : ''}${EnergyConverter.formatKj(vm.balanceKj)} kJ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: balanceColor.withAlpha(190),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: balanceColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          vm.balanceStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Breakdown section
                const Text(
                  'Tu resumen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildMetricCard(
                  icon: '🍽️',
                  title: 'Calorías consumidas',
                  subtitle: 'Total de comidas y bebidas registradas',
                  kcal: consumed,
                  kj: vm.consumedKj,
                  color: AppColors.energyConsumed,
                  bgColor: AppColors.energyConsumedLight,
                ),
                const SizedBox(height: 12),

                _buildMetricCard(
                  icon: '🔥',
                  title: 'Calorías gastadas',
                  subtitle: 'Total de actividades registradas',
                  kcal: expended,
                  kj: vm.expendedKj,
                  color: AppColors.energyBurned,
                  bgColor: AppColors.energyBurnedLight,
                ),
                const SizedBox(height: 20),

                // Basal Reference Section (Clean, friendly, no math formula jargon)
                const Text(
                  'Referencia Basal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${bmr.toStringAsFixed(0)} kcal / día',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Energía aproximada que tu organismo requiere en reposo para sus funciones vitales durante el día.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String icon,
    required String title,
    required String subtitle,
    required double kcal,
    required double kj,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${kcal.toStringAsFixed(1)} kcal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${EnergyConverter.formatKj(kj)} kJ',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
