import 'package:flutter/material.dart';

/// Paleta clara/escura do app Xeque — mesmo mecanismo usado no Hermes:
/// dois conjuntos de cor const e um ValueNotifier dizendo qual está ativo.
class _Palette {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentDim;
  final Color accentBackground;
  final Color success;
  final Color successBackground;
  final Color warning;
  final Color warningBackground;
  final Color divider;

  const _Palette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentDim,
    required this.accentBackground,
    required this.success,
    required this.successBackground,
    required this.warning,
    required this.warningBackground,
    required this.divider,
  });

  // Escuro: tabuleiro à noite — roxo-azulado escuro + dourado de xeque-mate.
  static const dark = _Palette(
    background: Color(0xFF0D0F16),
    surface: Color(0xFF171A24),
    surfaceAlt: Color(0xFF12141C),
    border: Color(0xFF262B38),
    textPrimary: Color(0xFFF4F5F8),
    textSecondary: Color(0xFF9398A8),
    textMuted: Color(0xFF5F6578),
    accent: Color(0xFFE0B341), // dourado
    accentDim: Color(0xFFA6822C),
    accentBackground: Color(0x1FE0B341),
    success: Color(0xFF22C55E),
    successBackground: Color(0x1A22C55E),
    warning: Color(0xFFEF4444),
    warningBackground: Color(0x1AEF4444),
    divider: Color(0xFF20242F),
  );

  // Claro: tabuleiro de dia — branco + dourado mais profundo.
  static const light = _Palette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F7F9),
    surfaceAlt: Color(0xFFEDEFF3),
    border: Color(0xFFE3E6EC),
    textPrimary: Color(0xFF15181D),
    textSecondary: Color(0xFF5B6472),
    textMuted: Color(0xFF9AA2AF),
    accent: Color(0xFFB8860B), // dourado mais escuro p/ contraste no branco
    accentDim: Color(0xFF8C6608),
    accentBackground: Color(0x1FB8860B),
    success: Color(0xFF16A34A),
    successBackground: Color(0x1A16A34A),
    warning: Color(0xFFDC2626),
    warningBackground: Color(0x1ADC2626),
    divider: Color(0xFFE9EBF0),
  );
}

class AppColors {
  AppColors._();

  static final ValueNotifier<bool> themeIsDark = ValueNotifier<bool>(true);

  static void toggleTheme() => themeIsDark.value = !themeIsDark.value;

  static _Palette get _p => themeIsDark.value ? _Palette.dark : _Palette.light;

  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get surfaceAlt => _p.surfaceAlt;
  static Color get border => _p.border;
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textMuted => _p.textMuted;
  static Color get accent => _p.accent;
  static Color get accentDim => _p.accentDim;
  static Color get accentBackground => _p.accentBackground;
  static Color get success => _p.success;
  static Color get successBackground => _p.successBackground;
  static Color get warning => _p.warning;
  static Color get warningBackground => _p.warningBackground;
  static Color get divider => _p.divider;
}
