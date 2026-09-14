import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Controller/homepage_controller.dart';
import '../../Controller/notification_screen_controller.dart';
import '../../constants.dart';
import '../Widgets/customText.dart';

class NotiPageAlive extends StatefulWidget {
  const NotiPageAlive({super.key});

  @override
  State<NotiPageAlive> createState() => _NotiPageAliveState();
}

class _NotiPageAliveState extends State<NotiPageAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final HomePageController controller = Get.find();

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return dateStr.isNotEmpty ? dateStr : '11:37 AM';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Blue Top Header (Figma Node 195:10439 / 195:10595)
          Container(
            width: double.infinity,
            color: kBrandPrimaryBlue,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    children: [
                      CustomText(
                        text: 'Notifications',
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
          ),

          // 2. Body: Refreshable List or Empty State
          Expanded(
            child: RefreshIndicator(
              displacement: 40,
              backgroundColor: Colors.white,
              color: kBrandPrimaryBlue,
              strokeWidth: 3.0,
              onRefresh: () async {
                await Get.delete<NotificationScreenController>();
                await Get.put(NotificationScreenController());
              },
              child: Obx(() {
                final list = controller.notificationController.modelList;

                if (list.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 0.72.sh,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/notif_empty_img.png',
                                width: 225.w,
                                height: 146.h,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.notifications_none_rounded,
                                  size: 100.sp,
                                  color: const Color(0xFFC7D2FE),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              CustomText(
                                text: 'No Notifications Yet',
                                fontFamily: kFontFamily,
                                size: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF121D31),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              CustomText(
                                text:
                                    'You’re all caught up! We’ll notify you about station updates, offers and more.',
                                fontFamily: kFontFamily,
                                size: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF68768E),
                                textAlign: TextAlign.center,
                                height: 1.4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 17.w,
                    vertical: 16.h,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE6EAEF),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.imageUrl.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                height: 150.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 12.h),
                          ],

                          // Header Row: Title & Delete button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CustomText(
                                  text: item.title,
                                  fontFamily: kFontFamily,
                                  size: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF121D31),
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              InkWell(
                                onTap: () {
                                  controller.notificationController.modelList
                                      .removeAt(index);
                                },
                                borderRadius: BorderRadius.circular(6.r),
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: SvgPicture.string(
                                    '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M2.66663 4H13.3333M5.99996 1.33337H9.99996M6.66663 7.33337V11.3334M9.33329 7.33337V11.3334M3.99996 4L4.53329 13.0667C4.57143 13.7145 4.85806 14.3217 5.3334 14.7611C5.80874 15.2005 6.43577 15.4385 7.08663 15.4267H8.91329C9.56415 15.4385 10.1912 15.2005 10.6665 14.7611C11.1419 14.3217 11.4285 13.7145 11.4666 13.0667L12 4" stroke="#01B1E1" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
                                    width: 16.w,
                                    height: 16.w,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Notification Body Description
                          if (item.body.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            CustomText(
                              text: item.body,
                              fontFamily: kFontFamily,
                              size: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF68768E),
                              height: 1.45,
                            ),
                          ],

                          SizedBox(height: 12.h),

                          // Time & Status Dot
                          Row(
                            children: [
                              CustomText(
                                text: _formatDate(item.createdAt),
                                fontFamily: kFontFamily,
                                size: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFA0AABD),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF0049C2),
                                      Color(0xFF02E8BD),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
