import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

/// Shows the Date Range Picker Bottom Sheet modal matching Figma node 184:7928.
Future<void> showDateRangePickerSheet(
  BuildContext context, {
  required String initialStartDate,
  required String initialEndDate,
  required void Function(String startDate, String endDate) onApply,
  VoidCallback? onClear,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss date range picker',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return Stack(
        children: [
          // Blurred and dimmed backdrop
          Positioned.fill(
            child: FadeTransition(
              opacity: curved,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.21),
                  ),
                ),
              ),
            ),
          ),

          // Slide-up sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: Material(
                color: Colors.transparent,
                child: DateRangePickerModalContent(
                  initialStartDate: initialStartDate,
                  initialEndDate: initialEndDate,
                  onApply: onApply,
                  onClear: onClear,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class DateRangePickerModalContent extends StatefulWidget {
  final String initialStartDate;
  final String initialEndDate;
  final void Function(String startDate, String endDate) onApply;
  final VoidCallback? onClear;

  const DateRangePickerModalContent({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onApply,
    this.onClear,
  });

  @override
  State<DateRangePickerModalContent> createState() =>
      _DateRangePickerModalContentState();
}

class _DateRangePickerModalContentState
    extends State<DateRangePickerModalContent> {
  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;

  @override
  void initState() {
    super.initState();
    _startDateCtrl = TextEditingController(text: widget.initialStartDate);
    _endDateCtrl = TextEditingController(text: widget.initialEndDate);
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromDate(BuildContext context) async {
    DateTime initial = DateTime.now();
    if (_startDateCtrl.text.isNotEmpty) {
      try {
        initial = DateFormat('dd/MM/yyyy').parse(_startDateCtrl.text);
      } catch (_) {}
    }

    DateTime lastDate = DateTime(2030);
    if (_endDateCtrl.text.isNotEmpty) {
      try {
        final parsedEnd = DateFormat('dd/MM/yyyy').parse(_endDateCtrl.text);
        if (parsedEnd.isAfter(DateTime(2020))) {
          lastDate = parsedEnd;
          if (initial.isAfter(lastDate)) {
            initial = lastDate;
          }
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kBrandPrimaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF121D31),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    DateTime initial = DateTime.now();
    if (_endDateCtrl.text.isNotEmpty) {
      try {
        initial = DateFormat('dd/MM/yyyy').parse(_endDateCtrl.text);
      } catch (_) {}
    }

    DateTime firstDate = DateTime(2020);
    if (_startDateCtrl.text.isNotEmpty) {
      try {
        final parsedStart = DateFormat('dd/MM/yyyy').parse(_startDateCtrl.text);
        firstDate = parsedStart;
        if (initial.isBefore(firstDate)) {
          initial = firstDate;
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kBrandPrimaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF121D31),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24.w,
        22.h,
        24.w,
        20.h + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Select Date Range',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF121D31),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22.sp,
                    color: const Color(0xFFA0AABD),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // From Date Section
          Text(
            'From',
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 8.h),
          DateRangePickerFieldBox(
            text: _startDateCtrl.text,
            onTap: () => _pickFromDate(context),
          ),
          SizedBox(height: 16.h),

          // To Date Section
          Text(
            'To',
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 8.h),
          DateRangePickerFieldBox(
            text: _endDateCtrl.text,
            onTap: () => _pickToDate(context),
          ),
          SizedBox(height: 28.h),

          // Bottom Action Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () {
                      if (widget.onClear != null &&
                          (_startDateCtrl.text.isNotEmpty ||
                              _endDateCtrl.text.isNotEmpty)) {
                        widget.onClear!();
                      }
                      Navigator.of(context).maybePop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: kBrandPrimaryBlue,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: kBrandPrimaryBlue,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),

              // Apply Button
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        _startDateCtrl.text,
                        _endDateCtrl.text,
                      );
                      Navigator.of(context).maybePop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPrimaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable Date Picker input field container matching Figma design specs.
class DateRangePickerFieldBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final String placeholder;

  const DateRangePickerFieldBox({
    super.key,
    required this.text,
    required this.onTap,
    this.placeholder = 'dd/mm/yy',
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = text.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xFFE6EAEF),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Calendar icon
            Icon(
              Icons.calendar_today_outlined,
              size: 18.sp,
              color: const Color(0xFF68768E),
            ),
            SizedBox(width: 12.w),

            // Subtle hairline vertical divider
            Container(
              width: 1,
              height: 20.h,
              color: const Color(0xFFE6EAEF),
            ),
            SizedBox(width: 12.w),

            // Selected Date / Placeholder Text
            Expanded(
              child: Text(
                hasValue ? text : placeholder,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w500,
                  color: hasValue
                      ? const Color(0xFF121D31)
                      : const Color(0xFFA0AABD),
                ),
              ),
            ),

            // Chevron down
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20.sp,
              color: const Color(0xFFA0AABD),
            ),
          ],
        ),
      ),
    );
  }
}
