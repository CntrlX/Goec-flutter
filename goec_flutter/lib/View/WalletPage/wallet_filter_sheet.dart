import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Controller/walletPage_controller.dart';
import '../../constants.dart';

/// Shows the Wallet Filter Modal Bottom Sheet with animated slide-up
/// and blurred / dimmed backdrop matching the calista_cafe_page modal design.
void showWalletFilterSheet(BuildContext context) {
  final controller = Get.find<WalletPageController>();

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss filter sheet',
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

          // Sliding modal sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: Material(
                color: Colors.transparent,
                child: WalletFilterModalContent(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class WalletFilterModalContent extends StatefulWidget {
  final WalletPageController controller;

  const WalletFilterModalContent({
    super.key,
    required this.controller,
  });

  @override
  State<WalletFilterModalContent> createState() =>
      _WalletFilterModalContentState();
}

class _WalletFilterModalContentState extends State<WalletFilterModalContent> {
  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;

  @override
  void initState() {
    super.initState();
    _startDateCtrl = TextEditingController(text: widget.controller.startDate.text);
    _endDateCtrl = TextEditingController(text: widget.controller.endDate.text);
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController textController,
  ) async {
    DateTime initialDate = DateTime.now();
    if (textController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(textController.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
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
        textController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final controller = widget.controller;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        20.h + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filter",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
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
                    color: const Color(0xFF8C97A7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // From Date Section
          Text(
            "From",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 8.h),
          _buildDateField(
            controller: _startDateCtrl,
            onTap: () => _pickDate(context, _startDateCtrl),
          ),
          SizedBox(height: 14.h),

          // To Date Section
          Text(
            "To",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 8.h),
          _buildDateField(
            controller: _endDateCtrl,
            onTap: () => _pickDate(context, _endDateCtrl),
          ),
          SizedBox(height: 20.h),

          // Payment Mode Section
          Text(
            "Payment Mode",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final adminSelected = controller.payment_mode
                .contains(WalletPageController.adminTopUp);
            final walletSelected = controller.payment_mode
                .contains(WalletPageController.walletTopUp);

            return Row(
              children: [
                Expanded(
                  child: _buildChip(
                    label: "Admin Topup",
                    isSelected: adminSelected,
                    onTap: () => controller.addRemoveOptionToMode(
                      WalletPageController.adminTopUp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildChip(
                    label: "Wallet Topup",
                    isSelected: walletSelected,
                    onTap: () => controller.addRemoveOptionToMode(
                      WalletPageController.walletTopUp,
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 20.h),

          // Payment Status Section
          Text(
            "Payment Status",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final successSelected =
                controller.payment_status.contains('success');
            final failedSelected =
                controller.payment_status.contains('failure');

            return Row(
              children: [
                Expanded(
                  child: _buildChip(
                    label: "Success",
                    isSelected: successSelected,
                    onTap: () =>
                        controller.addRemoveOptionToStatus('success'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildChip(
                    label: "Failed",
                    isSelected: failedSelected,
                    onTap: () =>
                        controller.addRemoveOptionToStatus('failure'),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 28.h),

          // Bottom Action Buttons (Cancel & Apply)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearFilter();
                      Navigator.of(context).maybePop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: kBrandPrimaryBlue,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: kBrandPrimaryBlue,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.startDate.text = _startDateCtrl.text;
                      controller.endDate.text = _endDateCtrl.text;
                      controller.applyFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPrimaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    ),
                    child: Text(
                      "Apply",
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14.sp,
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

  Widget _buildDateField({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    final hasValue = controller.text.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18.sp,
              color: const Color(0xFF8C97A7),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                hasValue ? controller.text : "dd/mm/yy",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: hasValue
                      ? const Color(0xFF121D31)
                      : const Color(0xFF8C97A7),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22.sp,
              color: const Color(0xFF8C97A7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: isSelected ? kBrandPrimaryBlue : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? kBrandPrimaryBlue : const Color(0xFF68768E),
          ),
        ),
      ),
    );
  }
}
