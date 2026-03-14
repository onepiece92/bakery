import 'package:bakery_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppThemeExtension get appTheme => Theme.of(this).extension<AppThemeExtension>()!;
}