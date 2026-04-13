import 'package:flutter/material.dart';

/// App-wide color palette.
class AppColors {
  AppColors._();

  // ── Primary (Gold / Brass - Elite) ──
  static const Color primary = Color(0xFFFFD700);
  static const Color primaryLight = Color(0xFFFFE55C);
  static const Color primaryDark = Color(0xFFB39700);

  // ── Secondary / Accent (Electric Cyan - Funky) ──
  static const Color secondary = Color(0xFF00E5FF);
  static const Color secondaryLight = Color(0xFF6EFFFF);
  static const Color secondaryDark = Color(0xFF00A3B3);

  // ── Surfaces (Light) ──
  static const Color surfaceLight = Color(0xFFF7F9FC);
  static const Color backgroundLight = Color(0xFFEef2f8);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ── Surfaces (Dark) ──
  static const Color surfaceDark = Color(0xFF131B39);
  static const Color backgroundDark = Color(0xFF0A0F25);
  static const Color cardDark = Color(0xFF1D264A);

  // ── Text ──
  static const Color textPrimaryLight = Color(0xFF0B1120);
  static const Color textSecondaryLight = Color(0xFF4A5568);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ── Functional ──
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF32ADE6);

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF0055FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
