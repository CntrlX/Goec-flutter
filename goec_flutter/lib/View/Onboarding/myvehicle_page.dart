import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Model/vehicleModel.dart';
import '../../Utils/routes.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';
import '../Widgets/appbar.dart';
import '../Widgets/cached_network_image.dart';
import '../Widgets/customText.dart';
import '../Widgets/glass_circle_icon_button.dart';
import 'package:freelancer_app/Controller/my_vehicles_screen_controller.dart';

class MyVehiclePage extends GetView<MyVehiclesScreenController> {
  const MyVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueStatusBar(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Obx(() {
                if (controller.myVehicleList.isEmpty &&
                    !controller.isLoading.value) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  color: const Color(0xFF0049C2),
                  onRefresh: () => controller.getMyVehicles(),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    children: [
                      ...controller.myVehicleList.map(
                        (vehicle) => _buildVehicleCard(vehicle, context),
                      ),
                      _buildAddVehicleButton(),
                    ],
                  ),
                );
              }),
            ),
          ],
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
        children: [
          GlassBackButton(
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
          ),
          width(12.w),
          CustomText(
            text: 'My Vehicles',
            size: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel model, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: model.defaultVehicle
              ? const Color(0xFFC0D7FD)
              : const Color(0xFFE6EAEF),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            if (!model.defaultVehicle) {
              _showSetDefaultConfirmationBottomSheet(context, model);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Status Tag (Default / Secondary) & Delete Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: model.defaultVehicle
                            ? const Color(0xFFE0F7F1)
                            : const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: CustomText(
                        text: model.defaultVehicle ? 'Default' : 'Secondary',
                        size: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: model.defaultVehicle
                            ? const Color(0xFF0D9488)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    if (!model.defaultVehicle)
                      GestureDetector(
                        onTap: () =>
                            _showDeleteVehicleConfirmationBottomSheet(context, model),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 20.sp,
                            color: const Color(0xFFA0AABD),
                          ),
                        ),
                      ),
                  ],
                ),
                height(14.h),

                // Middle row: Vehicle Icon and Basic Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 87.w,
                      height: 52.h,
                      child: model.icon.isNotEmpty
                          ? cachedNetworkImage(
                              model.icon,
                              width: 87.w,
                              height: 52.h,
                              fit: BoxFit.contain,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F8FA),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.directions_car_outlined,
                                size: 32.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                    ),
                    width(14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: model.brand.isNotEmpty ? model.brand : 'Vehicle',
                            size: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: kNeutralPrimary,
                            height: 1.3,
                          ),
                          height(2.h),
                          CustomText(
                            text: model.modelName.isNotEmpty ? model.modelName : '',
                            size: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: kNeutralPrimary,
                            height: 1.3,
                          ),
                          height(2.h),
                          CustomText(
                            text: model.evRegNumber,
                            size: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: kNeutralMuted,
                            height: 1.3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom row: Connector Types
                if (model.compactable_port.isNotEmpty) ...[
                  height(14.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: model.compactable_port.map((port) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F8FA),
                          borderRadius: BorderRadius.circular(9999),
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
        ),
      ),
    );
  }

  Widget _buildAddVehicleButton() {
    return Container(
      width: double.infinity,
      height: 54.h,
      margin: EdgeInsets.only(top: 4.h, bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: kBrandPrimaryBlue,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () async {
            await Get.toNamed(Routes.addvehiclesRoute);
            controller.getMyVehicles();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 20.sp,
                color: kBrandPrimaryBlue,
              ),
              width(6.w),
              CustomText(
                text: 'Add New Vehicle',
                size: 16.sp,
                fontWeight: FontWeight.w600,
                color: kBrandPrimaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64.sp,
              color: kNeutralMuted,
            ),
            height(16.h),
            CustomText(
              text: 'No Vehicles Available',
              size: 18.sp,
              fontWeight: FontWeight.w600,
              color: kNeutralPrimary,
            ),
            height(8.h),
            CustomText(
              text: 'Add your electric vehicle to get started with charging.',
              textAlign: TextAlign.center,
              size: 14.sp,
              fontWeight: FontWeight.w400,
              color: kNeutralSecondary,
            ),
            height(24.h),
            _buildAddVehicleButton(),
          ],
        ),
      ),
    );
  }

  // Set Default Confirmation Bottom Sheet with Backdrop Blur
  void _showSetDefaultConfirmationBottomSheet(
    BuildContext context,
    VehicleModel model,
  ) {
    _showBlurredConfirmSheet(
      context: context,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36.r),
            topRight: Radius.circular(36.r),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF01B1E1).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE0F7F1).withValues(alpha: 0.7),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: const Color(0xFF0D9488),
                size: 32.sp,
              ),
            ),
            height(16.h),
            CustomText(
              text: 'Set as Default?',
              size: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
            height(8.h),
            CustomText(
              text:
                  'Are you sure you want to set ${model.brand} ${model.modelName} (${model.evRegNumber}) as your default vehicle?',
              size: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4B5563),
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            height(28.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: kBrandPrimaryBlue,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999.r),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: CustomText(
                        text: 'Cancel',
                        size: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: kBrandPrimaryBlue,
                      ),
                    ),
                  ),
                ),
                width(14.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                        controller.setAsDefaultVehicle(model);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandPrimaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999.r),
                        ),
                      ),
                      child: CustomText(
                        text: 'Confirm',
                        size: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            height(12.h),
            systemBottomSpacer(context),
          ],
        ),
      ),
    );
  }

  // Delete Vehicle Confirmation Bottom Sheet with Backdrop Blur
  void _showDeleteVehicleConfirmationBottomSheet(
    BuildContext context,
    VehicleModel model,
  ) {
    _showBlurredConfirmSheet(
      context: context,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36.r),
            topRight: Radius.circular(36.r),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF01B1E1).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFEE2E2).withValues(alpha: 0.6),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.delete_outline_rounded,
                color: const Color(0xFFFF0013),
                size: 32.sp,
              ),
            ),
            height(16.h),
            CustomText(
              text: 'Delete Vehicle?',
              size: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
            height(8.h),
            CustomText(
              text:
                  'Are you sure you want to delete ${model.brand} ${model.modelName} (${model.evRegNumber})?\nThis action cannot be undone.',
              size: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4B5563),
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            height(28.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: kBrandPrimaryBlue,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999.r),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: CustomText(
                        text: 'Cancel',
                        size: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: kBrandPrimaryBlue,
                      ),
                    ),
                  ),
                ),
                width(14.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                        controller.deleteVehicle(model);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0013),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999.r),
                        ),
                      ),
                      child: CustomText(
                        text: 'Delete',
                        size: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            height(12.h),
            systemBottomSpacer(context),
          ],
        ),
      ),
    );
  }

  /// Same overlay as station confirm sheet & profile sheets: blur 2 + 21% dim fades in place;
  /// only the sheet slides up.
  void _showBlurredConfirmSheet({
    required BuildContext context,
    required Widget child,
  }) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, _) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Stack(
          children: [
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
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: Material(
                  color: Colors.transparent,
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

