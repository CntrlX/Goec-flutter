import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? prefixText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final bool showDivider;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? height;
  final double? borderRadius;

  const CustomInputField({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixText,
    this.prefixWidget,
    this.suffixWidget,
    this.showDivider = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.backgroundColor,
    this.borderColor,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget? prefix = prefixWidget ??
        (prefixText != null
            ? Text(
                prefixText!,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w500,
                  color: kNeutralPrimary,
                ),
              )
            : null);

    return Container(
      height: height ?? 59.h,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        border: Border.all(
          color: borderColor ?? const Color(0xFFE6EAEF),
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefix != null) ...[
            prefix,
            if (showDivider) ...[
              SizedBox(width: 12.w),
              Container(
                width: 0.66,
                height: 24.h,
                color: const Color(0xFFE6EAEF),
              ),
              SizedBox(width: 12.w),
            ] else
              SizedBox(width: 8.w),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onTap: onTap,
              readOnly: readOnly,
              autofocus: autofocus,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: kNeutralPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA0AABD),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffixWidget != null) suffixWidget!,
        ],
      ),
    );
  }
}
