import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/timeline_event.dart';
import '../providers/activity_view_model.dart';
import '../providers/food_view_model.dart';
import '../providers/home_view_model.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/timeline_list.dart';
import 'activity_form_view.dart';
import 'daily_balance_view.dart';
import 'meal_form_view.dart';
import 'profile_view.dart';
import 'timeline_event_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeViewModel>().loadCurrentDate();
    });
  }

  void _showAddEventSheet() {
    final homeVm = context.read<HomeViewModel>();
    final selectedDate = homeVm.selectedDate;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '¿Qué deseas registrar?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Elige la opción que deseas añadir a tu día.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),

                // Option: Registrar Actividad
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  tileColor: AppColors.energyBurnedLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: AppColors.energyBurned.withAlpha(40),
                    ),
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🏃', style: TextStyle(fontSize: 22)),
                  ),
                  title: const Text(
                    'Tu actividad',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    'Caminar, dormir o estudiar con cálculo de calorías',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textSecondary),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    if (!mounted) return;
                    context
                        .read<ActivityViewModel>()
                        .initForNew(baseDate: selectedDate);
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ActivityFormView(),
                      ),
                    );
                    if (!mounted) return;
                    context.read<HomeViewModel>().loadCurrentDate();
                  },
                ),
                const SizedBox(height: 12),

                // Option: Registrar Comida
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  tileColor: AppColors.energyConsumedLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: AppColors.energyConsumed.withAlpha(40),
                    ),
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🍽️', style: TextStyle(fontSize: 22)),
                  ),
                  title: const Text(
                    'Tus comidas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    'Alimentos, bebidas y cálculo de calorías consumidas',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textSecondary),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    if (!mounted) return;
                    context
                        .read<FoodViewModel>()
                        .initForNew(baseDate: selectedDate);
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MealFormView(),
                      ),
                    );
                    if (!mounted) return;
                    context.read<HomeViewModel>().loadCurrentDate();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es'),
    );
    if (picked != null) {
      if (!mounted) return;
      context.read<HomeViewModel>().setDate(picked);
    }
  }

  Future<void> _onEventSelected(TimelineEvent event) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimelineEventDetailView(event: event),
      ),
    );
    if (!mounted) return;
    context.read<HomeViewModel>().loadCurrentDate();
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileView(),
      ),
    );
    if (!mounted) return;
    context.read<HomeViewModel>().loadCurrentDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🥗', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            const Text(
              'Foodly',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            tooltip: 'Perfil',
            onPressed: _openProfile,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.dailyBalance == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => vm.loadCurrentDate(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selector bar
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: vm.previousDay,
                          tooltip: 'Día anterior',
                        ),
                        InkWell(
                          onTap: () => _pickDate(vm.selectedDate),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateTimeUtils.formatShortDate(vm.selectedDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (!vm.isToday)
                              TextButton(
                                onPressed: vm.goToToday,
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  backgroundColor: AppColors.primaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Hoy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded),
                              onPressed: vm.nextDay,
                              tooltip: 'Día siguiente',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Summary Card with 3 Metrics and Dynamic Orientation Card
                  BalanceSummaryCard(
                    date: vm.selectedDate,
                    balance: vm.dailyBalance,
                    onDetailsTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DailyBalanceView(date: vm.selectedDate),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // Progress & Timeline Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tu progreso',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${vm.timelineEvents.length} ${vm.timelineEvents.length == 1 ? 'evento' : 'eventos'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Timeline list
                  TimelineList(
                    events: vm.timelineEvents,
                    onEventTap: _onEventSelected,
                  ),
                  const SizedBox(height: 80), // space for FAB
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Registrar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
