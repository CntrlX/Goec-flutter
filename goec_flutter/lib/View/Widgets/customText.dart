import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';

Widget CustomText({
  required String text,
  double? size,
  Color? color,
  int? maxLines,
  bool isAutoSize = false,
  FontWeight? fontWeight,
  TextOverflow? overflow,
  double? letterSpacing,
  double? height,
  double minFontSize = 8,
  bool? isRoboto,
  bool? isUnderScore,
  bool isItalic = false,
  TextAlign? textAlign,
  String? fontFamily,
}) {
  TextStyle style = isRoboto == null || !isRoboto
      ? TextStyle(
          fontFamily: fontFamily ?? kFontFamily,
          fontStyle: isItalic ? FontStyle.italic : null,
          fontSize: size ?? 16,
          color: color ?? Colors.black,
          fontWeight: fontWeight ?? FontWeight.normal,
          letterSpacing: letterSpacing,
          height: height,
          decoration: isUnderScore != null && isUnderScore
              ? TextDecoration.underline
              : null,
        )
      : GoogleFonts.roboto(
          fontSize: size ?? 16,
          color: color ?? Colors.black,
          fontWeight: fontWeight ?? FontWeight.normal,
          letterSpacing: letterSpacing,
        );
  return !isAutoSize
      ? Text(
          text,
          style: style,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        )
      : AutoSizeText(
          text,
          style: style,
          minFontSize: minFontSize,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        );
}
