import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'package:freelancer_app/Controller/favourite_page_controller.dart';
import 'package:freelancer_app/Model/favoriteModel.dart';
import 'package:freelancer_app/Singletones/map_functions.dart';
import 'package:freelancer_app/Utils/routes.dart';
import 'package:freelancer_app/View/Widgets/appbar.dart';
import 'package:freelancer_app/View/Widgets/glass_circle_icon_button.dart';

class FavouriteScreen extends GetView<FavouritePageController> {
  const FavouriteScreen({super.key});

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
                if (controller.model_list.isEmpty &&
                    !controller.isLoading.value) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  color: const Color(0xFF0049C2),
                  onRefresh: () =>
                      controller.getFavorites(showLoader: false),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    itemCount: controller.model_list.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (ctx, index) {
                      final model = controller.model_list[index];
                      return _buildStationCard(model);
                    },
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
            size: 36.w,
            onTap: () => Get.back(),
          ),
          SizedBox(width: 12.w),
          Text(
            'Favorites',
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(FavoriteModel model) {
    String distance = '0.0';
    if (MapFunctions().curPos.latitude != 0) {
      distance = (MapFunctions.distanceBetweenCoordinates(
                  model.latitude,
                  model.longitude,
                  MapFunctions().curPos.latitude,
                  MapFunctions().curPos.longitude) /
              1000.0)
          .toStringAsFixed(1);
    }

    String subtitle = '$distance km away';
    if (model.address.trim().isNotEmpty) {
      final loc = model.address.split(',').first.trim();
      if (loc.isNotEmpty) {
        subtitle = '$loc · $distance km away';
      }
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          controller.gotoStationDetailsPage(model.id.toString());
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE6EAEF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: model.image,
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 48.w,
                    height: 48.w,
                    color: const Color(0xFFE2E8F0),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 48.w,
                    height: 48.w,
                    color: const Color(0xFFE2E8F0),
                    child: Icon(
                      Icons.ev_station_rounded,
                      size: 24.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      model.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    controller.changeFavoriteStatus(model.id);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: const Color(0xFFEB4D4B),
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: const Color(0xFFF1F5F9).withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF011631).withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Badge
              SizedBox(
                width: 112.w,
                height: 112.w,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Outer Halo
                    Container(
                      width: 112.w,
                      height: 112.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(
                          color: const Color(0xFFDBEAFE),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Center Gradient Box
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ),
                    // Floating Top-Right Heart
                    Positioned(
                      top: -2.h,
                      right: -2.w,
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFF1F2),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            color: const Color(0xFFEB4D4B),
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              Text(
                'No Saved Stations Yet',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'Tap the heart icon on any charging station to save it here for quick access',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                  height: 1.45,
                ),
              ),

              SizedBox(height: 28.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offNamedUntil(
                      Routes.homePageRoute,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0049C2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Explore Stations',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
