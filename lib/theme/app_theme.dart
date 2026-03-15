import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_decorations.dart';
import 'app_text_styles.dart';

final class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryRed,
          onPrimary: AppColors.white,
          secondary: AppColors.caramel,
          onSecondary: AppColors.white,
          surface: AppColors.warmWhite,
          onSurface: AppColors.text,
          error: AppColors.terracotta,
          onError: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.disPlayMediumWhite,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          // bodyLarge: AppTextStyles.bodyLarge,
            titleSmall: AppTextStyles.bodySmallWhite, 
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelMedium: AppTextStyles.label,
          labelSmall: AppTextStyles.labelSmall,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryRed,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppColors.backgroundLight),
          titleTextStyle: AppTextStyles.headlineLarge,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusL),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: AppTextStyles.buttonPrimary,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            // Outlined: brand red border + red text on white.
            foregroundColor: AppColors.primaryRed,
            side: const BorderSide(color: AppColors.primaryRed, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusM),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusS),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              // Selected state → deeper opacity of primaryRed.
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryRed.withValues(alpha: 0.80);
              }
              // Default → primary brand red.
              return AppColors.primaryRed;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              // White label in both states.
              return AppColors.white;
            }),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              // Selected → primary red background.
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryRed;
              }
              // Default → Tailwind gray-100 (from HTML quantity track bg).
              return AppColors.beige;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                // Icon on primary red bg → white.
                return AppColors.white;
              }
              // Icon on gray bg → primary red.
              return AppColors.primaryRed;
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDecorations.radiusML),
              ),
            ),
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
    
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryRed;
              }
              return AppColors.white;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                // Label on brand red → white.
                return AppColors.white;
              }
              // Unselected → primary red text on white.
              return AppColors.primaryRed;
            }),
            
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDecorations.radiusS),
              ),
            ),
            side: const WidgetStatePropertyAll(BorderSide.none),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusM),
            borderSide: const BorderSide(color: AppColors.lightGold, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusM),
            borderSide: const BorderSide(color: AppColors.warmWhite, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusM),
            borderSide: const BorderSide(color: AppColors.caramel, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
        ),
        dividerColor: AppColors.lightGold,
        dividerTheme: const DividerThemeData(
          color: AppColors.lightGold,
          thickness: 1,
          space: 0,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppDecorations.radiusCard),
            ),
            side: BorderSide(color: AppColors.lightGold),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.golden,
          labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusSM),
            side: BorderSide.none,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDecorations.radiusCard),
            ),
          ),
        ),
        extensions: <ThemeExtension<dynamic>>[
          AppThemeExtension(
            productImageGradient: AppColors.productImageGradient,
            primaryGradient: AppColors.primaryGradient,
            heroGradient: AppColors.heroGradient,
            price: AppTextStyles.price,
            priceLarge: AppTextStyles.priceLarge,
            buttonPrimary: AppTextStyles.buttonPrimary,
            navLabel: AppTextStyles.navLabel,
            caption: AppTextStyles.caption,
          ),
        ],
      );
}


class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  // ── Gradients ──────────────────────────────────────────────
  final Gradient productImageGradient;
  final Gradient primaryGradient;
  final Gradient heroGradient;

  // ── Custom text styles ─────────────────────────────────────
  final TextStyle price;
  final TextStyle priceLarge;
  final TextStyle buttonPrimary;
  final TextStyle navLabel;
  final TextStyle caption;

  const AppThemeExtension({
    required this.productImageGradient,
    required this.primaryGradient,
    required this.heroGradient,
    required this.price,
    required this.priceLarge,
    required this.buttonPrimary,
    required this.navLabel,
    required this.caption,
  });

  @override
  AppThemeExtension copyWith({
    Gradient? productImageGradient,
    Gradient? primaryGradient,
    Gradient? heroGradient,
    TextStyle? price,
    TextStyle? priceLarge,
    TextStyle? buttonPrimary,
    TextStyle? navLabel,
    TextStyle? caption,
  }) {
    return AppThemeExtension(
      productImageGradient: productImageGradient ?? this.productImageGradient,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      heroGradient: heroGradient ?? this.heroGradient,
      price: price ?? this.price,
      priceLarge: priceLarge ?? this.priceLarge,
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      navLabel: navLabel ?? this.navLabel,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant AppThemeExtension? other,
    double t,
  ) {
    if (other == null) return this;
    return AppThemeExtension(
      productImageGradient:
          Gradient.lerp(productImageGradient, other.productImageGradient, t)!,
      primaryGradient:
          Gradient.lerp(primaryGradient, other.primaryGradient, t)!,
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t)!,
      price: TextStyle.lerp(price, other.price, t)!,
      priceLarge: TextStyle.lerp(priceLarge, other.priceLarge, t)!,
      buttonPrimary: TextStyle.lerp(buttonPrimary, other.buttonPrimary, t)!,
      navLabel: TextStyle.lerp(navLabel, other.navLabel, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}