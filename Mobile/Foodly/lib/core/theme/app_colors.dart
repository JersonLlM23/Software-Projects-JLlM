import 'package:flutter/material.dart';

/// App color palette for a clean, modern, and accessible interface.
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF334155); // Slate 700
  static const Color accent = Color(0xFF3B82F6); // Blue 500

  // Category & metric colors
  static const Color energyConsumed = Color(0xFFF97316); // Amber / Orange 500
  static const Color energyConsumedLight = Color(0xFFFFF7ED); // Orange 50
  static const Color energyBurned = Color(0xFFEF4444); // Red / Flame 500
  static const Color energyBurnedLight = Color(0xFFFEF2F2); // Red 50
  static const Color energyBalancePositive = Color(0xFF10B981); // Emerald 500
  static const Color energyBalanceDeficit = Color(0xFF6366F1); // Indigo 500
  static const Color energyBalanceLight = Color(0xFFECFDF5); // Emerald 50

  // Background & surface
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Activity Specific
  static const Color activityWalk = Color(0xFF10B981);
  static const Color activitySleep = Color(0xFF6366F1);
  static const Color activityStudy = Color(0xFF8B5CF6);
  static const Color mealColor = Color(0xFFF97316);
}
