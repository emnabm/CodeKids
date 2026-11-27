import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic colors specific to the CodeKids space theme.
@immutable
class CodeKidsColors extends ThemeExtension<CodeKidsColors> {
  const CodeKidsColors({
    required this.background,
    required this.card,
    required this.cardElevated,
    required this.primary,
    required this.flame,
    required this.mutedText,
    required this.success,
    required this.error,
    required this.border,
  });

  final Color background;
  final Color card;
  final Color cardElevated;
  final Color primary;
  final Color flame;
  final Color mutedText;
  final Color success;
  final Color error;
  final Color border;

  static const dark = CodeKidsColors(
    background: Color(0xFF0D0830),
    card: Color(0xFF1B1450),
    cardElevated: Color(0xFF251D68),
    primary: Color(0xFF5B4BD6),
    flame: Color(0xFFFFB020),
    mutedText: Color(0xFFB9B3E6),
    success: Color(0xFF7BE0A0),
    error: Color(0xFFFF9AA8),
    border: Color(0xFF342A78),
  );

  @override
  CodeKidsColors copyWith({
    Color? background,
    Color? card,
    Color? cardElevated,
    Color? primary,
    Color? flame,
    Color? mutedText,
    Color? success,
    Color? error,
    Color? border,
  }) {
    return CodeKidsColors(
      background: background ?? this.background,
      card: card ?? this.card,
      cardElevated: cardElevated ?? this.cardElevated,
      primary: primary ?? this.primary,
      flame: flame ?? this.flame,
      mutedText: mutedText ?? this.mutedText,
      success: success ?? this.success,
      error: error ?? this.error,
      border: border ?? this.border,
    );
  }

  @override
  CodeKidsColors lerp(ThemeExtension<CodeKidsColors>? other, double t) {
    if (other is! CodeKidsColors) return this;
    return CodeKidsColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardElevated: Color.lerp(cardElevated, other.cardElevated, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      flame: Color.lerp(flame, other.flame, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

/// Provides the single global [ThemeData] for CodeKids.
class AppTheme {
  const AppTheme._();

  static const CodeKidsColors colors = CodeKidsColors.dark;

  static ThemeData buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    final fredokaTextTheme = GoogleFonts.fredokaTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF5B4BD6),
      onPrimary: Colors.white,
      secondary: Color(0xFFFFB020),
      onSecondary: Color(0xFF0D0830),
      surface: Color(0xFF1B1450),
      onSurface: Colors.white,
      error: Color(0xFFFF9AA8),
      onError: Color(0xFF0D0830),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: fredokaTextTheme.copyWith(
        bodySmall: fredokaTextTheme.bodySmall?.copyWith(color: colors.mutedText),
        bodyMedium: fredokaTextTheme.bodyMedium?.copyWith(color: Colors.white),
        titleLarge: fredokaTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: fredokaTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border, width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        hintStyle: GoogleFonts.fredoka(color: colors.mutedText),
        labelStyle: GoogleFonts.fredoka(color: colors.mutedText),
        prefixIconColor: colors.mutedText,
        suffixIconColor: colors.mutedText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          side: BorderSide(color: colors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(48, 48),
          textStyle: GoogleFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF130D3C),
        selectedItemColor: Colors.white,
        unselectedItemColor: colors.mutedText,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.fredoka(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.fredoka(fontSize: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.cardElevated,
        contentTextStyle: GoogleFonts.fredoka(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
      extensions: const <ThemeExtension<dynamic>>[CodeKidsColors.dark],
    );
  }
}

extension CodeKidsThemeX on BuildContext {
  CodeKidsColors get ckColors =>
      Theme.of(this).extension<CodeKidsColors>() ?? CodeKidsColors.dark;
}
