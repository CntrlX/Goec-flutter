import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

//CustomBigText Widget
class CustomBigText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final void Function()? ontap;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double? letterspacing;
  final TextOverflow? textOverflow;
    final int? maxLines;


  final TextAlign? align;

  const CustomBigText(
      {super.key,
      required this.text,
      this.size,
      this.color,
      this.fontWeight,
      this.ontap,
      this.fontFamily,
      this.letterspacing,
      this.textOverflow,
      this.maxLines,
      this.align});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        child: AutoSizeText(
          text,
          textAlign: align ?? TextAlign.left,
          minFontSize: 10,
          overflow: textOverflow,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            letterSpacing: letterspacing ?? null,
            fontSize: size ?? 20.sp,
            fontWeight: fontWeight ?? FontWeight.w600,
            color: color ?? Color(0xff828282),
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

//CustomSmallText Widget
class CustomSmallText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final void Function()? ontap;
  final FontWeight? fontWeight;
  final double? letterspacing;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final bool textOverflow;

  const CustomSmallText(
      {super.key,
      required this.text,
      this.size,
      this.color,
      this.fontWeight,
      this.ontap,
      this.letterspacing,
      this.textOverflow = true,
      this.textAlign,
      this.decoration});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        child: AutoSizeText(
          text,
          textAlign: textAlign ?? null,
          minFontSize: 12,
          overflow: textOverflow ? TextOverflow.ellipsis : null,
          style: GoogleFonts.poppins(
            decoration: decoration,
            letterSpacing: letterspacing ?? null,
            fontSize: size ?? 14.sp,
            fontWeight: fontWeight ?? FontWeight.w400,
            color: color ?? Color(0xff828282),
          ),
        ),
      ),
    );
  }
}
