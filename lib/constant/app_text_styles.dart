import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle h1() => GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 32.0,
      );

  static TextStyle h2() => GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
      );

  static TextStyle h3() => GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
      );

  static TextStyle h4() => GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
      );

  static TextStyle h5() => GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      );

  static TextStyle h6() => GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
      );

  static TextStyle regular({double? fontSize}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        fontSize: fontSize ?? 16.0,
      );

  static TextStyle medium({double? fontSize}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: fontSize ?? 16.0,
      );

  static TextStyle semiBold({double? fontSize}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: fontSize ?? 16.0,
      );

  static TextStyle bold({double? fontSize}) => GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: fontSize ?? 16.0,
      );

  static TextStyle regular12() => regular(fontSize: 12.0);
  static TextStyle medium12() => medium(fontSize: 12.0);
  static TextStyle semiBold12() => semiBold(fontSize: 12.0);
  static TextStyle bold12() => bold(fontSize: 12.0);

  static TextStyle regular14() => regular(fontSize: 14.0);
  static TextStyle medium14() => medium(fontSize: 14.0);
  static TextStyle semiBold14() => semiBold(fontSize: 14.0);
  static TextStyle bold14() => bold(fontSize: 14.0);
}
