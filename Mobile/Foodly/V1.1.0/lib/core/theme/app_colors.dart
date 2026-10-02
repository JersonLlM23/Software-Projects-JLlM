import 'package:flutter/material.dart';

/// App color palette for Foodly with a modern, fresh green wellness identity.
class AppColors {
  AppColors._();

  // Primary brand green colors
  static const Color primary = Color(0xFF2E7D32); // Forest Green 800
  static const Color primaryLight = Color(0xFF4CAF50); // Fresh Green 500
  static const Color primaryDark = Color(0xFF1B5E20); // Deep Botanical Green 900
  static const Color primaryContainer = Color(0xFFE8F5E9); // Light Mint/Sage Green 50
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1B5E20);

  // Accent & harmony colors
  static const Color accent = Color(0xFF10B981); // Emerald 500
  static const Color accentLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color secondary = Color(0xFF66BB6A); // Soft Green
  static const Color tertiary = Color(0xFFA5D6A7); // Sage Pastel

  // Category & metric colors
  static const Color energyConsumed = Color(0xFFF59E0B); // Warm Amber 500
  static const Color energyConsumedLight = Color(0xFFFFFBEB); // Amber 50
  static const Color energyBurned = Color(0xFF16A34A); // Active Forest Green
  static const Color energyBurnedLight = Color(0xFFF0FDF4); // Green 50
  static const Color energyBalancePositive = Color(0xFF16A34A); // Healthy Balance Emerald
  static const Color energyBalanceDeficit = Color(0xFF0284C7); // Sky Blue 600
  static const Color energyBalanceSurplus = Color(0xFFD97706); // Amber 600
  static const Color energyBalanceLight = Color(0xFFE8F5E9); // Soft Green 50

  // Background & surface
  static const Color background = Color(0xFFF7FAF7); // Pure soft off-white with gentle green tint
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5ECE5); // Clean subtle green-gray border

  // Text
  static const Color textPrimary = Color(0xFF1B2E1E); // Deep forest slate
  static const Color textSecondary = Color(0xFF5D7060); // Neutral sage
  static const Color textMuted = Color(0xFF8F9E90); // Light muted slate

  // Activity Specific
  static const Color activityWalk = Color(0xFF2E7D32);
  static const Color activitySleep = Color(0xFF3B82F6);
  static const Color activityStudy = Color(0xFF8B5CF6);
  static const Color mealColor = Color(0xFFF59E0B);
}
