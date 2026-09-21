import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewModel/countdown_view_model.dart';
import 'settings_screen.dart';

/// Pantalla principal de TimeLeft basada fielmente en el mockup diseño/main.dart
/// con estética monocromática (blanco, negro y escala de grises) y en español.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CountdownViewModel _viewModel;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _viewModel = CountdownViewModel.instance;
    _nameController = TextEditingController(text: _viewModel.eventTitle);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Muestra el selector nativo de hora (TimePicker)
  Future<void> _pickTime() async {
    final now = DateTime.now();
    final initial = _viewModel.targetDateTime != null
        ? TimeOfDay(
            hour: _viewModel.targetDateTime!.hour,
            minute: _viewModel.targetDateTime!.minute,
          )
        : TimeOfDay(hour: now.hour, minute: now.minute);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dialOnly,
      helpText: 'SELECCIONA LA HORA OBJETIVO',
      confirmText: 'CONFIRMAR',
      cancelText: 'CANCELAR',
    );

    if (picked != null) {
      _viewModel.setTargetTimeOfDay(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isDark = _viewModel.isDarkMode;
        final primaryBackground = isDark ? const Color(0xFF09090B) : const Color(0xFFF4F4F5);
        final secondaryBackground = isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF);
        final alternate = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
        final surfaceVariant30 = isDark ? const Color(0xFF141416) : const Color(0xFFFAFAFA);
        final primaryText = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF09090B);
        final secondaryText = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
        final buttonPrimary = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF09090B);
        final buttonText = isDark ? const Color(0xFF09090B) : const Color(0xFFFFFFFF);
        final isRunning = _viewModel.isRunning;
        final timeComponents = _viewModel.displayTimeComponents;

        // Si el título cambió desde otro lugar (e.g. SharedPreferences), mantener sincronizado el controller
        if (_nameController.text != _viewModel.eventTitle && !isRunning) {
          _nameController.text = _viewModel.eventTitle;
        }

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: primaryBackground,
            body: SafeArea(
              child: Column(
                children: [
                  // ENCABEZADO SUPERIOR DEL MOCKUP (Monocromático)
                  Container(
                    decoration: BoxDecoration(
                      color: primaryBackground,
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
                              Text(
                                'TimeLeft',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 26,
                                  color: primaryText,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.drag_handle_rounded,
                                  color: primaryText,
                                  size: 26,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  );
                                },
                                tooltip: 'Menú de configuración',
                              ),
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

                  // CONTENIDO PRINCIPAL SCROLLABLE
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. CAMPO: NOMBRE DEL EVENTO
                          _buildTextField(
                            label: 'Nombre del evento',
                            hint: 'Ingresa el nombre del evento...',
                            controller: _nameController,
                            enabled: !isRunning,
                            onChanged: (val) => _viewModel.setEventTitle(val),
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                            secondaryBackground: secondaryBackground,
                            alternate: alternate,
                          ),

                          const SizedBox(height: 16),

                          // 2. CAMPO: HORA OBJETIVO
                          _buildTargetTimeField(
                            label: 'Hora objetivo',
                            value: _viewModel.formatTargetTimeField(),
                            hint: '00:00:00',
                            enabled: !isRunning,
                            onTap: isRunning ? null : _pickTime,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                            secondaryBackground: secondaryBackground,
                            alternate: alternate,
                          ),

                          const SizedBox(height: 24),

                          // MENSAJE DE ERROR SI APLICA
                          if (_viewModel.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: secondaryBackground,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: alternate, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: primaryText, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _viewModel.errorMessage!,
                                      style: GoogleFonts.inter(
                                        color: primaryText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // 3. CAJA PRINCIPAL DEL TEMPORIZADOR
                          Container(
                            decoration: BoxDecoration(
                              color: secondaryBackground,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: alternate, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Etiqueta superior (TIEMPO RESTANTE / FALTAN / ATRASO / COMPLETADO)
                                Text(
                                  _viewModel.statusLabel,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: timeComponents.isOverdue
                                        ? primaryText
                                        : (_viewModel.isCompleted
                                            ? primaryText
                                            : secondaryText),
                                    letterSpacing: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // DISPLAY DE DÍGITOS GIGANTES SEGÚN MOCKUP
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (timeComponents.isOverdue) ...[
                                      Text(
                                        '+',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 48,
                                          color: primaryText,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    // Horas
                                    Text(
                                      timeComponents.hours,
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 56,
                                        color: primaryText,
                                        height: 1.1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        ':',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 42,
                                          color: secondaryText,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    // Minutos
                                    Text(
                                      timeComponents.minutes,
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 56,
                                        color: primaryText,
                                        height: 1.1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        ':',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 42,
                                          color: secondaryText,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    // Segundos
                                    Text(
                                      timeComponents.seconds,
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 56,
                                        color: primaryText,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 4. BOTONES DE CONTROL DE ACCIÓN
                          Row(
                            children: [
                              // Botón Iniciar / Detener (Monocromático alto contraste)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _viewModel.toggleTimer(),
                                  icon: Icon(
                                    isRunning
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 20,
                                    color: buttonText,
                                  ),
                                  label: Text(
                                    isRunning ? 'Detener' : 'Iniciar',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: buttonText,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonPrimary,
                                    foregroundColor: buttonText,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Botón Marcar Completado
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: (_viewModel.targetDateTime == null || _viewModel.isCompleted)
                                      ? null
                                      : () => _viewModel.markDone(),
                                  icon: Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 20,
                                    color: primaryText,
                                  ),
                                  label: Text(
                                    'Completar',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: primaryText,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: secondaryBackground,
                                    side: BorderSide(color: alternate, width: 1),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 5. TARJETA DE INFORMACIÓN / FECHA OBJETIVO Y RESUMEN
                          Container(
                            decoration: BoxDecoration(
                              color: surfaceVariant30,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: alternate, width: 1),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Fecha y hora objetivo',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryText,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (_viewModel.targetDateTime != null && !isRunning)
                                      InkWell(
                                        onTap: _pickTime,
                                        child: Text(
                                          'Cambiar',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: primaryText,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _viewModel.formatTargetDate(),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                  ),
                                ),
                                if (_viewModel.formatCompletionSummary() != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _viewModel.formatCompletionSummary()!,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryText,
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool enabled,
    required ValueChanged<String> onChanged,
    required Color primaryText,
    required Color secondaryText,
    required Color secondaryBackground,
    required Color alternate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: secondaryBackground,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: alternate, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            controller: controller,
            enabled: enabled,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: primaryText,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetTimeField({
    required String label,
    required String value,
    required String hint,
    required bool enabled,
    required VoidCallback? onTap,
    required Color primaryText,
    required Color secondaryText,
    required Color secondaryBackground,
    required Color alternate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
              color: secondaryBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: alternate, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: primaryText, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : hint,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: value.isNotEmpty ? primaryText : secondaryText.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                if (enabled)
                  Icon(Icons.access_time, color: secondaryText, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
