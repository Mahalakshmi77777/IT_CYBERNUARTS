import 'package:flutter/material.dart';

/// App-wide color palette — Warm Minimal.
class AppColors {
  AppColors._();

  // ── Primary (Soft Charcoal) ──
  static const Color primary = Color(0xFF2C2C2C);
  static const Color primaryLight = Color(0xFF4A4A4A);
  static const Color primaryDark = Color(0xFF1A1A1A);

  // ── Accent ──
  static const Color accent = Color(0xFFDCAE1D);       // Muted Mustard
  static const Color accentAlt = Color(0xFFB24C38);     // Brick Red

  // ── Secondary (Mustard) ──
  static const Color secondary = Color(0xFFDCAE1D);
  static const Color secondaryLight = Color(0xFFF5E6A3);
  static const Color secondaryDark = Color(0xFFB8920F);

  // ── Surfaces (Light) ──
  static const Color surfaceLight = Color(0xFFF5F2EC);
  static const Color backgroundLight = Color(0xFFF9F6F0);  // Bone White
  static const Color cardLight = Color(0xFFFFFFFF);

  // ── Surfaces (Dark) ──
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundDark = Color(0xFF141414);
  static const Color cardDark = Color(0xFF282828);

  // ── Text ──
  static const Color textPrimaryLight = Color(0xFF2C2C2C);   // Soft Charcoal
  static const Color textSecondaryLight = Color(0xFF8A8A80);
  static const Color textPrimaryDark = Color(0xFFF5F2EC);
  static const Color textSecondaryDark = Color(0xFF9E9E94);

  // ── Functional ──
  static const Color error = Color(0xFFB24C38);        // Brick Red
  static const Color success = Color(0xFF4A7C59);      // Olive Green
  static const Color warning = Color(0xFFDCAE1D);      // Muted Mustard
  static const Color info = Color(0xFF5B7B8A);          // Steel Blue

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFDCAE1D), Color(0xFFB24C38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF2C2C2C), Color(0xFF4A4A4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
