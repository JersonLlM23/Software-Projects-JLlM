import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'viewModel/countdown_view_model.dart';
import 'viewModel/notification_service.dart';
import 'vistas/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localización para DateFormat en español
  await initializeDateFormatting('es', null);
  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';

  // Inicializar servicio de notificaciones locales y persistencia del ViewModel
  await NotificationService.instance.init();
  await CountdownViewModel.instance.init();

  runApp(const TimeLeftApp());
}

/// TimeLeftApp es el widget raíz de la aplicación TimeLeft (Fase 3 - Estética Monocromática).
class TimeLeftApp extends StatelessWidget {
  const TimeLeftApp({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = CountdownViewModel.instance;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final isDark = viewModel.isDarkMode;

        return MaterialApp(
          title: 'TimeLeft',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF4F4F5),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF09090B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF09090B),
              secondary: Color(0xFF71717A),
              outline: Color(0xFFE4E4E7),
              error: Color(0xFF18181B),
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF09090B),
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Color(0xFF09090B),
              surface: Color(0xFF18181B),
              onSurface: Colors.white,
              secondary: Color(0xFFA1A1AA),
              outline: Color(0xFF27272A),
              error: Colors.white,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
