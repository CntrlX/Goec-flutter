import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Utils/routes.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';
import '../Widgets/appbar.dart';
import '../Widgets/cached_network_image.dart';
import '../Widgets/customText.dart';
import '../Widgets/glass_circle_icon_button.dart';
import '../Widgets/unfocus_wrapper.dart';
import 'package:freelancer_app/Controller/vehicles_screen_controller.dart';

class PersonalVechileDetailsPage extends GetView<VehiclesScreenController> {
  const PersonalVechileDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueStatusBar(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: UnfocusWrapper(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: 20.h,
                          bottom: 100.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVehicleOverview(context),
                            height(36.h),
                            _buildRegistrationInput(),
                            height(16.h),
                            _buildDefaultVehicleToggle(),
                          ],
                        ),
                      ),
                    ),
                    _buildAnimatedAddVehicleButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      color: const Color(0xFF0049C2),
      padding: EdgeInsets.only(
        top: topPad + 6.h,
        bottom: 14.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GlassBackButton(
                onTap: () => Get.back(),
              ),
              width(12.w),
              CustomText(
                text: 'Add New Vehicle',
                size: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              if (Get.arguments == 'isFirstTime') {
                Get.offAllNamed(
                  Routes.homePageRoute,
                  arguments: 'requestLocation',
                );
              } else {
                Get.back();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: CustomText(
                text: 'Skip',
                size: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleOverview(BuildContext context) {
    return Obx(() {
      final vehicle = controller.selectedVehicle.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FD),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFC0D7FD),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 87.w,
                  height: 52.h,
                  child: vehicle.icon.isNotEmpty
                      ? cachedNetworkImage(
                          vehicle.icon,
                          width: 87.w,
                          height: 52.h,
                          fit: BoxFit.contain,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.directions_car_outlined,
                            size: 32.sp,
                            color: kNeutralSecondary,
                          ),
                        ),
                ),
                width(16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: vehicle.brand.isNotEmpty ? vehicle.brand : 'Vehicle',
                        size: 12.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.55,
                        color: kNeutralSecondary,
                      ),
                      height(2.h),
                      CustomText(
                        text: vehicle.modelName.isNotEmpty ? vehicle.modelName : '',
                        size: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: kNeutralPrimary,
                      ),
                      if (vehicle.compactable_port.isNotEmpty) ...[
                        height(8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: vehicle.compactable_port.map((port) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(
                                  color: const Color(0xFFE6EAEF),
                                  width: 1,
                                ),
                              ),
                              child: CustomText(
                                text: port.toString(),
                                size: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: kBrandPrimaryBlue,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            height(16.h),
            InkWell(
              onTap: () => Get.back(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: 'Change vehicle',
                    size: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: kBrandPrimaryBlue,
                  ),
                  width(4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16.sp,
                    color: kBrandPrimaryBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRegistrationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Vehicle registration number ',
          size: 14.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.35,
          color: kNeutralPrimary,
        ),
        height(8.h),
        Container(
          width: double.infinity,
          height: 58.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: const Color(0xFFE6EAEF),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 18.sp,
                color: kNeutralMuted,
              ),
              Container(
                height: 24.h,
                width: 1,
                color: const Color(0xFFE6EAEF),
                margin: EdgeInsets.symmetric(horizontal: 12.w),
              ),
              Expanded(
                child: TextField(
                  controller: controller.numEditingController,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: kNeutralPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'KL 07 AB 1234',
                    hintStyle: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFA0AABD).withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultVehicleToggle() {
    return Obx(() {
      final isLocked = controller.isDefaultLocked.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: isLocked
              ? null
              : () {
                  controller.isDefaultVehicle.value =
                      !controller.isDefaultVehicle.value;
                },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE4FDF7),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFFAFF8E9),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Set as default vehicle',
                        size: 15.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.375,
                        color: kNeutralPrimary,
                      ),
                      height(2.h),
                      CustomText(
                        text: 'Used for quick-start charging sessions',
                        size: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: kNeutralSecondary,
                      ),
                    ],
                  ),
                ),
                width(12.w),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: controller.isDefaultVehicle.value,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF0D9488),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFE8EBF0),
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) => Colors.transparent,
                    ),
                    onChanged: isLocked
                        ? null
                        : (val) {
                            controller.isDefaultVehicle.value = val;
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAnimatedAddVehicleButton() {
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 24.h,
      child: Obx(() {
        final isValid = controller.isFormValid.value;

        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          offset: isValid ? Offset.zero : const Offset(0, 0.4),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isValid ? 1.0 : 0.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              scale: isValid ? 1.0 : 0.85,
              child: IgnorePointer(
                ignoring: !isValid,
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: isValid
                        ? () => controller.onVehicleSubmit()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPrimaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: kBrandPrimaryBlue.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    ),
                    child: CustomText(
                      text: 'Add vehicle',
                      size: 16.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

