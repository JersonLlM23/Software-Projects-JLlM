import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewModel/countdown_view_model.dart';
import 'history_screen.dart';

/// Pantalla de Preferencias y Configuración basada en el mockup de TimeLeft
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
                            const SizedBox(width: 48), // Balancea el botón de retroceso
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

                        // Sub-opciones de recordatorio
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
                                children: [
                                  // Lista de recordatorios (predeterminados y personalizados)
                                  ...viewModel.reminderOptions.map((opt) {
                                    return CheckboxListTile(
                                      dense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                      activeColor: controlActive,
                                      checkColor: controlCheck,
                                      secondary: opt.isCustom
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: secondaryText,
                                              ),
                                              onPressed: () {
                                                viewModel.removeReminderOption(opt.id);
                                              },
                                              tooltip: 'Eliminar recordatorio personalizado',
                                            )
                                          : null,
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
                                  }),

                                  Divider(color: alternate, height: 1),

                                  // Botón para agregar recordatorio personalizado
                                  InkWell(
                                    onTap: () => _showAddCustomReminderDialog(context, viewModel, primaryText, secondaryBackground, alternate),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_alarm_rounded, size: 16, color: primaryText),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Agregar recordatorio personalizado',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: primaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Selector de sonido de notificaciones
                        _buildSettingsTile(
                          icon: Icons.music_note_rounded,
                          title: 'Sonido de notificación',
                          subtitle: viewModel.activeSoundName,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          onTap: () => _showSoundPickerModal(context, viewModel, primaryText, secondaryText, secondaryBackground, alternate),
                          trailing: Icon(Icons.chevron_right_rounded, color: secondaryText, size: 20),
                        ),

                        // SECCIÓN HISTORIAL
                        _buildSectionHeader('EVENTOS Y REGISTRO', primaryText, secondaryBackground, alternate),

                        _buildSettingsTile(
                          icon: Icons.history_rounded,
                          title: 'Historial de eventos',
                          subtitle: '${viewModel.completedEvents.length} eventos completados registrados',
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HistoryScreen(),
                              ),
                            );
                          },
                          trailing: Icon(Icons.chevron_right_rounded, color: secondaryText, size: 20),
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
                          icon: Icons.delete_forever_rounded,
                          title: 'Borrar Datos',
                          subtitle: 'Eliminar historial, eventos, recordatorios y reiniciar',
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
                                'TimeLeft v1.4.0',
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

  /// Diálogo para agregar recordatorio personalizado
  void _showAddCustomReminderDialog(
    BuildContext context,
    CountdownViewModel viewModel,
    Color primaryText,
    Color secondaryBackground,
    Color alternate,
  ) {
    final amountController = TextEditingController(text: '10');
    bool isHours = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: secondaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: alternate, width: 1),
              ),
              title: Text(
                'Nuevo recordatorio',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: primaryText),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recibir aviso con anticipación antes de la meta:',
                    style: GoogleFonts.inter(fontSize: 13, color: primaryText),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Input numérico
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: alternate),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.jetBrainsMono(
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Selector de unidad (minutos / horas)
                      Expanded(
                        flex: 3,
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('Min')),
                            ButtonSegment(value: true, label: Text('Horas')),
                          ],
                          selected: {isHours},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setDialogState(() {
                              isHours = newSelection.first;
                            });
                          },
                          style: ButtonStyle(
                            textStyle: WidgetStateProperty.all(
                              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    final amount = int.tryParse(amountController.text.trim()) ?? 0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor ingresa un número mayor a 0.')),
                      );
                      return;
                    }

                    final totalMinutes = isHours ? (amount * 60) : amount;
                    final success = await viewModel.addCustomReminder(minutesBefore: totalMinutes);

                    if (!context.mounted) return;
                    Navigator.of(dialogCtx).pop();

                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ya existe un recordatorio con ese mismo tiempo.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recordatorio personalizado añadido.')),
                      );
                    }
                  },
                  child: Text(
                    'Guardar',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: primaryText),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Modal para seleccionar el sonido de notificación
  void _showSoundPickerModal(
    BuildContext context,
    CountdownViewModel viewModel,
    Color primaryText,
    Color secondaryText,
    Color secondaryBackground,
    Color alternate,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SONIDO DE NOTIFICACIÓN',
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: primaryText,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),

                // Opción 1: Sonido predeterminado reloj.mp3
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.alarm_rounded,
                    color: viewModel.customSoundPath == null ? primaryText : secondaryText,
                  ),
                  title: Text(
                    'reloj.mp3 (Predeterminado)',
                    style: GoogleFonts.inter(
                      fontWeight: viewModel.customSoundPath == null ? FontWeight.bold : FontWeight.normal,
                      color: primaryText,
                    ),
                  ),
                  subtitle: Text(
                    'Sonido nativo empaquetado en la aplicación',
                    style: GoogleFonts.inter(fontSize: 12, color: secondaryText),
                  ),
                  trailing: viewModel.customSoundPath == null
                      ? Icon(Icons.check_rounded, color: primaryText)
                      : null,
                  onTap: () async {
                    await viewModel.resetToDefaultSound();
                    if (!context.mounted) return;
                    Navigator.of(bottomSheetCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sonido predeterminado reloj.mp3 activado.')),
                    );
                  },
                ),

                Divider(color: alternate),

                // Opción 2: Seleccionar MP3 del dispositivo
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.audio_file_rounded,
                    color: viewModel.customSoundPath != null ? primaryText : secondaryText,
                  ),
                  title: Text(
                    'Seleccionar archivo MP3 del dispositivo...',
                    style: GoogleFonts.inter(
                      fontWeight: viewModel.customSoundPath != null ? FontWeight.bold : FontWeight.normal,
                      color: primaryText,
                    ),
                  ),
                  subtitle: Text(
                    viewModel.customSoundPath != null
                        ? 'Activo: ${viewModel.customSoundName}'
                        : 'Elige cualquier archivo .mp3 almacenado en tu dispositivo',
                    style: GoogleFonts.inter(fontSize: 12, color: secondaryText),
                  ),
                  trailing: viewModel.customSoundPath != null
                      ? Icon(Icons.check_rounded, color: primaryText)
                      : null,
                  onTap: () async {
                    Navigator.of(bottomSheetCtx).pop();
                    try {
                      final files = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['mp3'],
                      );

                      if (files.isNotEmpty && files.first.path != null) {
                        final file = files.first;
                        await viewModel.setCustomSound(
                          path: file.path!,
                          name: file.name,
                        );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sonido personalizado asignado: ${file.name}'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No se pudo cargar el archivo MP3: $e'),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Nota técnica transparente sobre restricciones de Android
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: alternate.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: secondaryText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aviso de compatibilidad Android: En versiones modernas con Scoped Storage, el sistema puede restringir la lectura de archivos fuera de la app al disparar alertas en segundo plano. Si el sistema no puede acceder al archivo, TimeLeft usará automáticamente reloj.mp3 como respaldo seguro.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: secondaryText,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Diálogo con confirmación clara para borrar todos los datos
  void _confirmClearData(BuildContext context, CountdownViewModel viewModel, Color primaryText) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          '¿Borrar todos los datos?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Esta acción:\n\n'
          '• Cancelará el temporizador activo si existe.\n'
          '• Eliminará todas las notificaciones programadas.\n'
          '• Borrará todo el historial de eventos completados.\n'
          '• Restablecerá los recordatorios a los predeterminados.\n'
          '• Restaurará el sonido predeterminado (reloj.mp3).\n\n'
          '¿Deseas continuar con el borrado completo?',
          style: GoogleFonts.inter(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await viewModel.clearAllData();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todos los datos, eventos y configuraciones han sido restablecidos.'),
                ),
              );
            },
            child: Text(
              'Borrar todo',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
