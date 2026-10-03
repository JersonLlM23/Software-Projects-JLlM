import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modelo/completed_event.dart';
import '../viewModel/countdown_view_model.dart';

/// Pantalla de Historial de Eventos Completados de TimeLeft.
/// Presenta los eventos finalizados con su puntualidad e indicadores oficiales
/// manteniendo la estética monocromática estricta.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const List<String> _monthsEs = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  static String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = _monthsEs[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute:$second';
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = CountdownViewModel.instance;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final isDark = viewModel.isDarkMode;
        final primaryBackground = isDark ? const Color(0xFF09090B) : const Color(0xFFF4F4F5);
        final secondaryBackground = isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF);
        final alternate = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
        final primaryText = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF09090B);
        final secondaryText = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

        final events = viewModel.completedEvents;

        return Scaffold(
          backgroundColor: primaryBackground,
          body: SafeArea(
            child: Column(
              children: [
                // Header superior monocromático
                Container(
                  decoration: BoxDecoration(
                    color: secondaryBackground,
                    shape: BoxShape.rectangle,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: primaryText,
                                size: 24,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Volver',
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'TIMELEFT',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: primaryText,
                                    letterSpacing: 1.0,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'HISTORIAL DE EVENTOS',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: secondaryText,
                                    letterSpacing: 1.5,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            if (events.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.delete_sweep_rounded,
                                  color: secondaryText,
                                  size: 24,
                                ),
                                onPressed: () => _confirmClearHistory(context, viewModel, primaryText),
                                tooltip: 'Vaciar historial',
                              )
                            else
                              const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          color: alternate,
                          shape: BoxShape.rectangle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de eventos o estado vacío
                Expanded(
                  child: events.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 56,
                                  color: secondaryText.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Sin eventos en el historial',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Los eventos que marques como completados se registrarán aquí automáticamente.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: secondaryText,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: events.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = events[index];
                            return _buildEventCard(
                              context: context,
                              event: item,
                              viewModel: viewModel,
                              isDark: isDark,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              secondaryBackground: secondaryBackground,
                              alternate: alternate,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required CompletedEvent event,
    required CountdownViewModel viewModel,
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
    required Color secondaryBackground,
    required Color alternate,
  }) {
    final isLate = event.isOverdue;
    final diffDuration = event.deltaFromTarget.abs();
    final diffFormatted = CompletedEvent.formatDuration(diffDuration);

    // Configuración del badge del indicador
    final badgeBg = isDark
        ? (isLate ? const Color(0xFF27272A) : const Color(0xFF3F3F46))
        : (isLate ? const Color(0xFFE4E4E7) : const Color(0xFFD4D4D8));

    return Container(
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: alternate, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: Título e indicador oficial de llegada
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close_rounded, size: 18, color: secondaryText),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => viewModel.deleteCompletedEvent(event.id),
                tooltip: 'Eliminar registro',
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Badge con el indicador oficial
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: alternate, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLate ? Icons.timer_off_outlined : Icons.check_circle_rounded,
                  size: 14,
                  color: primaryText,
                ),
                const SizedBox(width: 6),
                Text(
                  event.punctualityLabel,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Detalle de tiempos
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141416) : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: alternate, width: 0.5),
            ),
            child: Column(
              children: [
                _buildTimeRow(
                  label: 'Hora objetivo:',
                  value: _formatDateTime(event.targetDateTime),
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                ),
                const SizedBox(height: 6),
                _buildTimeRow(
                  label: 'Hora finalización:',
                  value: _formatDateTime(event.completedAt),
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                ),
                const SizedBox(height: 8),
                Divider(color: alternate, height: 1),
                const SizedBox(height: 8),
                _buildTimeRow(
                  label: isLate ? 'Atraso registrado:' : 'Tiempo antes de meta:',
                  value: isLate ? '+$diffFormatted de atraso' : '-$diffFormatted antes',
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isHighlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow({
    required String label,
    required String value,
    required Color primaryText,
    required Color secondaryText,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            color: secondaryText,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: primaryText,
          ),
        ),
      ],
    );
  }

  void _confirmClearHistory(BuildContext context, CountdownViewModel viewModel, Color primaryText) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          '¿Vaciar el historial?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Se eliminarán todos los registros de eventos completados. Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              viewModel.clearHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Historial vaciado correctamente.'),
                ),
              );
            },
            child: Text(
              'Vaciar',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
