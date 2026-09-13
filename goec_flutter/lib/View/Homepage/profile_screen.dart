import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Controller/profile_screen_controller.dart';
import '../../Singletones/app_data.dart';
import '../../Utils/routes.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';
import '../Widgets/cached_network_image.dart';
import '../Widgets/customText.dart';

class ProfileScreen extends GetView<ProfileScreenController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          // 1. Blue App Bar Header (Figma Node 188:8537)
          Container(
            width: double.infinity,
            color: kBrandPrimaryBlue,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button & Title
                    Row(
                      children: [
                        Material(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () => Get.back(),
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 1.2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 28.sp,
                              ),
                            ),
                          ),
                        ),
                        width(12.w),
                        CustomText(
                          text: 'Profile',
                          fontFamily: kFontFamily,
                          size: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),

                    // 3-Dot Popup Menu Button (Figma Node 188:8780)
                    PopupMenuButton<String>(
                      icon: Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      offset: Offset(0, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: const BorderSide(
                          color: Color(0xFFE6EAEF),
                          width: 1,
                        ),
                      ),
                      color: Colors.white,
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.08),
                      onSelected: (value) {
                        if (value == 'edit') {
                          Get.toNamed(Routes.editProfilePageRoute);
                        } else if (value == 'delete') {
                          _showDeleteConfirmationBottomSheet(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          height: 44.h,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/menu_edit.svg',
                                width: 18.sp,
                                height: 18.sp,
                              ),
                              width(12.w),
                              CustomText(
                                text: 'Edit',
                                size: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0049C2),
                              ),
                            ],
                          ),
                        ),
                        const _FigmaPopupDivider(),
                        PopupMenuItem<String>(
                          value: 'delete',
                          height: 44.h,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/menu_delete.svg',
                                width: 18.sp,
                                height: 18.sp,
                              ),
                              width(12.w),
                              CustomText(
                                text: 'Delete',
                                size: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF1100),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Scrollable Body with Bottom-Pinned Logout Button
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 38.h,
                    bottom: 20.h,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 58.h,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Avatar & Hero Info (Figma Node 188:8655)
                          Center(
                            child: Column(
                              children: [
                                // Avatar with Edit Button
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 110.w,
                                      height: 110.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0x992B80FF),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(3.w),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFE5EDF9),
                                        ),
                                        child: ClipOval(
                                          child: Obx(
                                            () => appData.userModel.value.image
                                                    .isNotEmpty
                                                ? cachedNetworkImage(
                                                    appData
                                                        .userModel.value.image,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  )
                                                : Icon(
                                                    Icons.person_rounded,
                                                    size: 64.sp,
                                                    color:
                                                        const Color(0xFF0049C2),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Edit Badge Button
                                    Positioned(
                                      right: 2.w,
                                      bottom: 2.h,
                                      child: Material(
                                        color: kBrandPrimaryBlue,
                                        shape: const CircleBorder(),
                                        elevation: 3,
                                        shadowColor: Colors.black
                                            .withValues(alpha: 0.2),
                                        child: InkWell(
                                          onTap: () => Get.toNamed(
                                              Routes.editProfilePageRoute),
                                          customBorder: const CircleBorder(),
                                          child: Container(
                                            width: 28.w,
                                            height: 28.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.edit_rounded,
                                              color: Colors.white,
                                              size: 14.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                height(14.h),

                                // Name
                                Obx(
                                  () => CustomText(
                                    text: appData.userModel.value.name.isNotEmpty
                                        ? appData.userModel.value.name
                                        : 'User',
                                    size: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: kNeutralPrimary,
                                  ),
                                ),

                                height(4.h),

                                // Phone
                                Obx(
                                  () {
                                    final rawPhone =
                                        appData.userModel.value.username;
                                    final formattedPhone = rawPhone.isEmpty
                                        ? ''
                                        : (rawPhone.startsWith('+')
                                            ? rawPhone
                                            : '+$rawPhone');
                                    return CustomText(
                                      text: formattedPhone,
                                      size: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: kNeutralSecondary,
                                    );
                                  },
                                ),

                                height(2.h),

                                // Email
                                Obx(
                                  () => CustomText(
                                    text: appData.userModel.value.email.isNotEmpty
                                        ? appData.userModel.value.email
                                        : '',
                                    size: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: kNeutralSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          height(24.h),

                          // RFID Number Card (Figma Node 188:8677)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFDCE3ED)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(14.w),
                            child: Row(
                              children: [
                                // Contactless / RFID SVG Icon Container
                                Container(
                                  width: 52.w,
                                  height: 52.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF2FE),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    'assets/svg/profile_rfid.svg',
                                    width: 26.w,
                                    height: 26.w,
                                  ),
                                ),

                                width(14.w),

                                // RFID Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: 'RFID Number',
                                        size: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: kNeutralSecondary,
                                      ),
                                      height(2.h),
                                      Obx(
                                        () {
                                          final rfid = appData.userModel.value
                                                  .rfidTag.isNotEmpty
                                              ? appData
                                                  .userModel.value.rfidTag[0]
                                              : 'XXXXXXXXXXXXX';
                                          return CustomText(
                                            text: rfid,
                                            size: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: kNeutralPrimary,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // Exact Copy Button from Figma
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      final rfid = appData.userModel.value
                                              .rfidTag.isNotEmpty
                                          ? appData.userModel.value.rfidTag[0]
                                          : '';
                                      if (rfid.isNotEmpty) {
                                        Clipboard.setData(
                                            ClipboardData(text: rfid));
                                        showSuccess(
                                            'RFID copied to clipboard!');
                                      } else {
                                        showInfo('No RFID registered yet.');
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.w),
                                      child: SvgPicture.asset(
                                        'assets/svg/profile_copy.svg',
                                        width: 20.sp,
                                        height: 20.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          height(16.h),

                          // Metrics Statistics Row (Figma Node 188:8696)
                          Row(
                            children: [
                              // Left Card: Total Sessions
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FAF5),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: const Color(0xFFB0F8E9),
                                      width: 1,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 32.w,
                                            height: 32.w,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFD6F5E5),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.bolt_rounded,
                                              color: const Color(0xFF03C681),
                                              size: 18.sp,
                                            ),
                                          ),
                                          width(8.w),
                                          Expanded(
                                            child: CustomText(
                                              text: 'Total Sessions',
                                              size: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: kNeutralSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      height(14.h),
                                      Obx(
                                        () => CustomText(
                                          text:
                                              '${appData.userModel.value.total_sessions}',
                                          size: 24.sp,
                                          fontWeight: FontWeight.w700,
                                          color: kNeutralPrimary,
                                        ),
                                      ),
                                      height(2.h),
                                      CustomText(
                                        text: 'Charging sessions',
                                        size: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: kNeutralSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              width(14.w),

                              // Right Card: Total Units
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F6FE),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: const Color(0xFFC0D6FD),
                                      width: 1,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 32.w,
                                            height: 32.w,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFDDEBFF),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.bar_chart_rounded,
                                              color: kBrandPrimaryBlue,
                                              size: 18.sp,
                                            ),
                                          ),
                                          width(8.w),
                                          Expanded(
                                            child: CustomText(
                                              text: 'Total Units',
                                              size: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: kNeutralSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      height(14.h),
                                      Obx(
                                        () => CustomText(
                                          text:
                                              '${appData.userModel.value.total_units.toStringAsFixed(2)} units',
                                          size: 24.sp,
                                          fontWeight: FontWeight.w700,
                                          color: kNeutralPrimary,
                                        ),
                                      ),
                                      height(2.h),
                                      CustomText(
                                        text: 'Energy charged',
                                        size: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: kNeutralSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          height(24.h),

                          // Logout Button (Figma Node 188:8766) Pinned to bottom
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: Material(
                              color: const Color(0x0FFF0013),
                              borderRadius: BorderRadius.circular(9999.r),
                              child: InkWell(
                                onTap: () =>
                                    _showLogoutConfirmationBottomSheet(context),
                                borderRadius: BorderRadius.circular(9999.r),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout_rounded,
                                      color: const Color(0xFFFF0013),
                                      size: 20.sp,
                                    ),
                                    width(8.w),
                                    CustomText(
                                      text: 'Logout',
                                      size: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFF0013),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          height(12.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Delete Profile Confirmation Bottom Sheet (Figma Node 188:9402) with Backdrop Blur
  void _showDeleteConfirmationBottomSheet(BuildContext context) {
    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
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
              // Trash Icon Circle
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

              // Title
              CustomText(
                text: 'Delete Profile?',
                size: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),

              height(8.h),

              // Description
              CustomText(
                text:
                    'Are you sure you want to delete your profile?\nThis action cannot be undone.',
                size: 15.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4B5563),
                textAlign: TextAlign.center,
                height: 1.4,
              ),

              height(28.h),

              // Buttons Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
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
                          Get.back();
                          controller.deleteProfile();
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
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.21),
    );
  }

  // Logout Confirmation Bottom Sheet (Figma Node 188:9251) with Backdrop Blur
  void _showLogoutConfirmationBottomSheet(BuildContext context) {
    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
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
              // Logout Icon Circle
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEE2E2).withValues(alpha: 0.6),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.logout_rounded,
                  color: const Color(0xFFFF0013),
                  size: 32.sp,
                ),
              ),

              height(16.h),

              // Title
              CustomText(
                text: 'Logout?',
                size: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),

              height(8.h),

              // Description
              CustomText(
                text: 'Are you sure you want to logout from your account?',
                size: 15.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4B5563),
                textAlign: TextAlign.center,
                height: 1.4,
              ),

              height(28.h),

              // Buttons Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
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
                          Get.back();
                          controller.logout();
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
                          text: 'Logout',
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
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.21),
    );
  }
}

class _FigmaPopupDivider extends PopupMenuEntry<Never> {
  const _FigmaPopupDivider();

  @override
  final double height = 1.0;

  @override
  bool represents(void value) => false;

  @override
  State<_FigmaPopupDivider> createState() => _FigmaPopupDividerState();
}

class _FigmaPopupDividerState extends State<_FigmaPopupDivider> {
  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF3F4F6),
      );
}

