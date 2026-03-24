import 'package:flutter/material.dart';

/// App-wide color palette.
class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary = Color(0xFF4A3AFF);
  static const Color primaryLight = Color(0xFF7C6FFF);
  static const Color primaryDark = Color(0xFF2A1FCC);

  // ── Secondary / Accent ──
  static const Color secondary = Color(0xFF00C9A7);
  static const Color secondaryLight = Color(0xFF5EFCE8);
  static const Color secondaryDark = Color(0xFF009B7D);

  // ── Surfaces (Light) ──
  static const Color surfaceLight = Color(0xFFF8F8FF);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ── Surfaces (Dark) ──
  static const Color surfaceDark = Color(0xFF1E1E2C);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF2A2A3C);

  // ── Text ──
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B6B8D);
  static const Color textPrimaryDark = Color(0xFFF0F0F5);
  static const Color textSecondaryDark = Color(0xFFA0A0B8);

  // ── Functional ──
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF6C4FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
