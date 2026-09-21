import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewModel/countdown_view_model.dart';

/// Pantalla de Preferencias y Configuración basada en el mockup diseño/settings.dart
/// con estética estrictamente monocromática (blanco, negro y escala de grises).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        final controlActive = isDark ? Colors.white : Colors.black;
        final controlCheck = isDark ? Colors.black : Colors.white;
        final accent3 = isDark ? const Color(0xFF71717A) : const Color(0xFFA1A1AA);


        return Scaffold(
          backgroundColor: primaryBackground,
          body: SafeArea(
            child: Column(
              children: [
                // Header superior exacto del mockup (Monocromático)
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                                    fontSize: 20,
                                    color: primaryText,
                                    letterSpacing: 1.0,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'PREFERENCIAS',
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
                            const SizedBox(width: 48), // Balancea el botón de retroceso para centrar el texto
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

                // Lista scrollable con todas las opciones
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SECCIÓN NOTIFICACIONES
                        _buildSectionHeader('NOTIFICACIONES', primaryText, secondaryBackground, alternate),

                        _buildSettingsTile(
                          icon: Icons.notifications_active_rounded,
                          title: 'Alertas de eventos',
                          subtitle: 'Recibir notificaciones antes y al finalizar',
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          trailing: Switch(
                            value: viewModel.notificationsEnabled,
                            activeThumbColor: controlActive,
                            onChanged: (val) {
                              viewModel.toggleAllNotifications(val);
                            },
                          ),
                        ),

                        // Sub-opciones de recordatorio de la Fase 2
                        if (viewModel.notificationsEnabled) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 16, top: 4, bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: secondaryBackground.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: alternate, width: 1),
                              ),
                              child: Column(
                                children: viewModel.reminderOptions.map((opt) {
                                  return CheckboxListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                    activeColor: controlActive,
                                    checkColor: controlCheck,
                                    title: Text(
                                      opt.label,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: opt.isEnabled ? FontWeight.w600 : FontWeight.normal,
                                        color: primaryText,
                                      ),
                                    ),
                                    value: opt.isEnabled,
                                    onChanged: (bool? val) {
                                      if (val != null) {
                                        viewModel.toggleReminderOption(opt.id, val);
                                      }
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],

                        _buildSettingsTile(
                          icon: Icons.timer_rounded,
                          title: 'Progreso del temporizador',
                          subtitle: 'Sonido personalizado reloj.mp3 activado',
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          trailing: Icon(Icons.volume_up_rounded, color: primaryText, size: 20),
                        ),

                        // SECCIÓN APARIENCIA
                        _buildSectionHeader('APARIENCIA', primaryText, secondaryBackground, alternate),

                        _buildSettingsTile(
                          icon: Icons.dark_mode_rounded,
                          title: 'Modo Oscuro',
                          subtitle: 'Tema monocromático de alto contraste',
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          trailing: Switch(
                            value: viewModel.isDarkMode,
                            activeThumbColor: controlActive,
                            onChanged: (val) {
                              viewModel.setDarkMode(val);
                            },
                          ),
                        ),

                        // SECCIÓN SISTEMA
                        _buildSectionHeader('SISTEMA', primaryText, secondaryBackground, alternate),

                        _buildSettingsTile(
                          icon: Icons.storage_rounded,
                          title: 'Borrar Datos',
                          subtitle: 'Eliminar todos los eventos y reiniciar',
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          onTap: () => _confirmClearData(context, viewModel, primaryText),
                          trailing: Icon(Icons.chevron_right_rounded, color: secondaryText),
                        ),

                        // Pie de página de versión
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TimeLeft v1.3.0',
                                style: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: accent3,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildSectionHeader(String title, Color textColor, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryText,
    required Color secondaryText,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: secondaryText, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context, CountdownViewModel viewModel, Color primaryText) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          '¿Borrar todos los datos?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Esta acción cancelará el temporizador activo, eliminará las notificaciones programadas y restablecerá la configuración.',
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
              viewModel.clearAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Datos y temporizador restablecidos exitosamente.'),
                ),
              );
            },
            child: Text(
              'Borrar',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
