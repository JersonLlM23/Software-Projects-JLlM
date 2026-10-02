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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Qué deseas registrar?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Selecciona el tipo de evento. Se usará la hora actual del dispositivo.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Option: Registrar Actividad
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  tileColor: AppColors.energyBurnedLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.energyBurned.withAlpha(50)),
                  ),
                  leading: const Text('🏃', style: TextStyle(fontSize: 28)),
                  title: const Text(
                    'Registrar Actividad',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Caminar, Dormir o Estudiar',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    if (!mounted) return;
                    context.read<ActivityViewModel>().initForNew(baseDate: selectedDate);
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  tileColor: AppColors.energyConsumedLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.energyConsumed.withAlpha(50)),
                  ),
                  leading: const Text('🍽️', style: TextStyle(fontSize: 28)),
                  title: const Text(
                    'Registrar Comida / Bebida',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Alimentos, bebidas o agua con cálculo de kcal',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    if (!mounted) return;
                    context.read<FoodViewModel>().initForNew(baseDate: selectedDate);
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
        title: const Text(
          'DailyBalance',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: _openProfile,
          ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: vm.previousDay,
                          tooltip: 'Día anterior',
                        ),
                        InkWell(
                          onTap: () => _pickDate(vm.selectedDate),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 18, color: AppColors.accent),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: const Text(
                                  'Hoy',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: vm.nextDay,
                              tooltip: 'Día siguiente',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Summary Card
                  BalanceSummaryCard(
                    date: vm.selectedDate,
                    balance: vm.dailyBalance,
                    onDetailsTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DailyBalanceView(date: vm.selectedDate),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // Timeline Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Timeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${vm.timelineEvents.length} ${vm.timelineEvents.length == 1 ? 'evento' : 'eventos'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Registrar evento',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
