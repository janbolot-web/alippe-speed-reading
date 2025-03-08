import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Заголовки
  static TextStyle headline1 = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle headline2 = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Основной текст
  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 12,
    color: AppColors.textPrimary,
  );

  // Дополнительные стили
  static TextStyle buttonText = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static TextStyle hintText = GoogleFonts.montserrat(
    fontSize: 14,
    color: Colors.grey[600],
  );
}