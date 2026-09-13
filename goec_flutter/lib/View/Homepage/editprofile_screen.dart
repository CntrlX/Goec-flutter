import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Controller/editprofile_screen_controller.dart';
import '../../Singletones/app_data.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';
import '../Widgets/cached_network_image.dart';
import '../Widgets/customText.dart';
import '../Widgets/glass_circle_icon_button.dart';

class EditProfileScreen extends GetView<EditProfileScreenController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: Column(
          children: [
            // 1. Blue App Bar Header (Figma Node 188:9812)
            Container(
              width: double.infinity,
              color: kBrandPrimaryBlue,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      const GlassBackButton(),
                      width(12.w),
                      CustomText(
                        text: 'Edit Profile',
                        fontFamily: kFontFamily,
                        size: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  top: 38.h,
                  bottom: 24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with Edit Badge (Figma Node 188:9812)
                    Center(
                      child: Stack(
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
                                  color: Colors.black.withValues(alpha: 0.05),
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
                                  () => appData.userModel.value.image.isNotEmpty
                                      ? cachedNetworkImage(
                                          appData.userModel.value.image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Icon(
                                          Icons.person_rounded,
                                          size: 64.sp,
                                          color: const Color(0xFF0049C2),
                                        ),
                                ),
                              ),
                            ),
                          ),

                          // Edit Badge Button on Avatar
                          Positioned(
                            right: 2.w,
                            bottom: 2.h,
                            child: Material(
                              color: kBrandPrimaryBlue,
                              shape: const CircleBorder(),
                              elevation: 3,
                              shadowColor: Colors.black.withValues(alpha: 0.2),
                              child: InkWell(
                                onTap: () => controller.pickAndUploadImage(),
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
                    ),

                    height(36.h),

                    // Full Name Field (Underline style - Figma Node 188:9812)
                    _buildFieldLabel('Full Name'),
                    height(4.h),
                    TextField(
                      controller: controller.nameController,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF121D31),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 15.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFC4C6D2),
                    ),

                    height(24.h),

                    // Phone Number Field (Non-editable, matching user data)
                    _buildFieldLabel('Phone Number'),
                    height(4.h),
                    Row(
                      children: [
                        // Static Country Code from user data
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Obx(
                            () => CustomText(
                              text: controller.country.value.isNotEmpty
                                  ? '+${controller.country.value}'
                                  : '',
                              fontFamily: kFontFamily,
                              size: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF697B91),
                            ),
                          ),
                        ),

                        width(10.w),

                        // Vertical Hairline Divider
                        Container(
                          width: 1,
                          height: 20.h,
                          color: const Color(0xFFE6EAEF),
                        ),

                        width(12.w),

                        // Phone number text field (Read-only)
                        Expanded(
                          child: TextField(
                            controller: controller.phnNumberController,
                            readOnly: true,
                            enableInteractiveSelection: false,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF697B91),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Phone number',
                              hintStyle: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 15.sp,
                                color: const Color(0xFF9CA3AF),
                              ),
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 8.h),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFC4C6D2),
                    ),

                    height(24.h),

                    // Email Address Field (Underline style - Figma Node 188:9812)
                    _buildFieldLabel('Email Address'),
                    height(4.h),
                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF121D31),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter email address',
                        hintStyle: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 15.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFC4C6D2),
                    ),

                    height(40.h),
                  ],
                ),
              ),
            ),

            // 3. Bottom Pinned Save Button Container (Figma Node 188:9812)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFEBEFEA),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () => controller.updateUserProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPrimaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999.r),
                      ),
                    ),
                    child: CustomText(
                      text: 'Save Changes',
                      size: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return CustomText(
      text: label,
      size: 13.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF697B91),
    );
  }
}


