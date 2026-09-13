import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Singletones/app_data.dart';
import '../../Utils/routes.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';
import '../Widgets/cached_network_image.dart';
import '../Widgets/customText.dart';

class ProfilePageAlive extends StatefulWidget {
  const ProfilePageAlive({super.key});

  @override
  State<ProfilePageAlive> createState() => _ProfilePageAliveState();
}

class _ProfilePageAliveState extends State<ProfilePageAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Blue Top Header
          Container(
            width: double.infinity,
            color: kBrandPrimaryBlue,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                child: Row(
                  children: [
                    CustomText(
                      text: 'Profile',
                      fontFamily: kFontFamily,
                      size: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Promotional Hero Banner from Figma Node 121:2612
                  SizedBox(
                    width: double.infinity,
                    height: 145.h,
                    child: Stack(
                      children: [
                        // Background image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/profile_banner.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: const Color(0xFFEAF2FD)),
                          ),
                        ),

                        // Left subtle white gradient mask
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                stops: const [0.2, 0.75],
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.88),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Left Tagline & Logo
                        Positioned(
                          left: 20.w,
                          top: 20.h,
                          bottom: 20.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/goec_m_logo.svg',
                                height: 30.h,
                                errorBuilder: (context, error, stackTrace) =>
                                    SvgPicture.asset(
                                  'assets/svg/drawer_logo.svg',
                                  height: 28.h,
                                ),
                              ),
                              height(8.h),
                              CustomText(
                                text: 'Charge today\nfor a cleaner tomorrow',
                                size: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: kNeutralSecondary,
                                height: 1.35,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. User Profile Card (Figma Node 121:2642 - Full width band with #EAF2FD)
                  Material(
                    color: const Color(0xFFEAF2FD),
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(Routes.profilePageRoute);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 16.h),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
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
                                          size: 36.sp,
                                          color: const Color(0xFF0049C2),
                                        ),
                                ),
                              ),
                            ),

                            width(16.w),

                            // Name & Phone
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => CustomText(
                                      text: appData.userModel.value.name.isNotEmpty
                                          ? appData.userModel.value.name
                                          : 'User',
                                      size: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF032F68),
                                    ),
                                  ),
                                  height(2.h),
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
                                        size: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF697B91),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SvgPicture.asset(
                              'assets/svg/profile_chevron.svg',
                              width: 16.sp,
                              height: 16.sp,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF697B91),
                                BlendMode.srcIn,
                              ),
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16.sp,
                                color: const Color(0xFF697B91),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  height(16.h),

                  // 4. Navigation Menu Items (Figma Node 121:2426)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          iconPath: 'assets/svg/profile_car.svg',
                          fallbackIcon: Icons.directions_car_rounded,
                          title: 'My Vehicles',
                          onTap: () => Get.toNamed(Routes.myvehicleRoute),
                        ),
                        height(4.h),
                        _buildMenuItem(
                          iconPath: 'assets/svg/profile_rfid.svg',
                          fallbackIcon: Icons.credit_card_rounded,
                          title: 'RFID',
                          onTap: () => Get.toNamed(Routes.rfidNumberRoute),
                        ),
                        height(4.h),
                        _buildMenuItem(
                          iconPath: 'assets/svg/profile_favorites.svg',
                          fallbackIcon: Icons.favorite_rounded,
                          title: 'Favorites',
                          onTap: () => Get.toNamed(Routes.favouritePageRoute),
                        ),
                        height(4.h),
                        _buildMenuItem(
                          iconPath: 'assets/svg/profile_about.svg',
                          fallbackIcon: Icons.info_outline_rounded,
                          title: 'About us',
                          onTap: () => Get.toNamed(Routes.aboutPageRoute),
                        ),
                        height(8.h),
                        Divider(
                          color: const Color(0x33BEC9C1),
                          thickness: 1,
                          height: 16.h,
                        ),
                        height(24.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required IconData fallbackIcon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 24.sp,
                    height: 24.sp,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF68768E),
                      BlendMode.srcIn,
                    ),
                    errorBuilder: (context, error, stackTrace) => Icon(
                      fallbackIcon,
                      size: 24.sp,
                      color: const Color(0xFF68768E),
                    ),
                  ),
                ),
              ),
              width(16.w),
              Expanded(
                child: CustomText(
                  text: title,
                  size: 16.sp,
                  fontWeight: title == 'My Vehicles'
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: const Color(0xFF68768E),
                ),
              ),
              SvgPicture.asset(
                'assets/svg/profile_chevron.svg',
                width: 16.sp,
                height: 16.sp,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFA0AABD),
                  BlendMode.srcIn,
                ),
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: const Color(0xFFA0AABD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
