import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/food_view_model.dart';
import '../providers/home_view_model.dart';
import '../providers/profile_view_model.dart';
import 'home_view.dart';

/// Splash Screen for Foodly displaying the app identity, brand colors,
/// and smooth entrance before transitioning to HomeView.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    // Ensure animation and initial asynchronous loading complete seamlessly.
    // Total splash duration: ~2 seconds (800ms animation + 1600ms minimum wait)
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1600)),
      _loadInitialData(),
    ]);

    if (!mounted) return;

    // Smooth transition to HomeView
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _loadInitialData() async {
    try {
      final homeVm = context.read<HomeViewModel>();
      final profileVm = context.read<ProfileViewModel>();
      final foodVm = context.read<FoodViewModel>();

      await Future.wait([
        profileVm.loadProfile(),
        homeVm.loadCurrentDate(),
        foodVm.loadFoods(),
      ]);
    } catch (_) {
      // Allow fallback if load fails
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFF7FAF7),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Foodly logo centrado
                    Image.asset(
                      'assets/images/Logo_Jely.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    // App Title
                    const Text(
                      'Foodly',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Nutrición, actividad y balance',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
