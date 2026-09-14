import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Controller/homepage_controller.dart';
import '../../Controller/search_screen_controller.dart';
import '../../Utils/routes.dart';
import '../../constants.dart';
import 'Widgets/station_card_item.dart';

class SearchScreen extends GetView<SearchScreenController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(height: 14.h),

              // 1. Top Bar: Matching Back Button + Hero Search Bar Capsule
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    // Back Button matching the search bar design
                    GestureDetector(
                      onTap: () => Get.back(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 48.h,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFFF1F5F9),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A)
                                  .withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/svg/arrow_back_ios.svg',
                          width: 18.w,
                          height: 18.w,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF121D31),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // Search Bar Capsule with Hero Transition
                    Expanded(
                      child: Hero(
                        tag: 'search_bar_hero',
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            height: 48.h,
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/search-zoom-in.svg',
                                  width: 18.w,
                                  height: 18.w,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF68768E),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 10.w),

                                // Input Field
                                Expanded(
                                  child: TextField(
                                    controller: controller.searchTextController,
                                    focusNode: controller.searchFocusNode,
                                    autofocus: false,
                                    cursorColor: const Color(0xFF0049C2),
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 16 / 14,
                                      color: const Color(0xFF121D31),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search for stations..',
                                      hintStyle: TextStyle(
                                        fontFamily: kFontFamily,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        height: 16 / 14,
                                        color: const Color(0xFF68768E),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),

                                // Clear Button (visible when query is not empty)
                                Obx(() {
                                  if (controller.searchQuery.value.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return GestureDetector(
                                    onTap: controller.clearSearch,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 6.w),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 18.sp,
                                        color: const Color(0xFF68768E),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Results Area
              Expanded(
                child: Obx(() {
                  final query = controller.searchQuery.value;
                  final results = controller.searchResults;

                  // Empty State: query is empty (clean blank state as in Figma)
                  if (query.trim().isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // No Results State
                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/search-zoom-in.svg',
                            width: 42.w,
                            height: 42.w,
                            colorFilter: ColorFilter.mode(
                              const Color(0xFFA0AABD).withValues(alpha: 0.5),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No stations found matching "$query"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFA0AABD),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // With Data State: List of Station Cards matching Figma
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final station = results[index];
                      return StationCardItem(
                        station: station,
                        onTap: () {
                          if (Get.isRegistered<HomePageController>()) {
                            Get.find<HomePageController>()
                                .getChargeStationDetails(
                              station.id,
                              isCardTap: true,
                            );
                          } else {
                            Get.toNamed(
                              Routes.calistaCafePageRoute,
                              arguments: station.id,
                            );
                          }
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
