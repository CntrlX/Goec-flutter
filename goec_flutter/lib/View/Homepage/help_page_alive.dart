import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../Controller/homepage_controller.dart';
import '../../constants.dart';
import '../Widgets/appbar.dart';

class HelpPageAlive extends StatefulWidget {
  const HelpPageAlive({super.key});

  @override
  State<HelpPageAlive> createState() => _HelpPageAliveState();
}

class _HelpPageAliveState extends State<HelpPageAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final HomePageController controller = Get.find<HomePageController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlueStatusBar(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildCarousel(),
                    SizedBox(height: 24.h),
                    _buildGetSupportSection(),
                    SizedBox(height: 120.h),
                  ],
                ),
              ),
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
        top: topPad + 12.h,
        bottom: 16.h,
        left: 20.w,
        right: 20.w,
      ),
      child: Text(
        'Support',
        style: GoogleFonts.nunitoSans(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          height: 28.5 / 20,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        CarouselSlider(
          items: controller.carouselImage.map<Widget>((img) {
            return SizedBox(
              width: double.infinity,
              height: 210.h,
              child: Image.asset(
                img.toString(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 210.h,
                errorBuilder: (_, __, ___) => Container(
                  height: 210.h,
                  color: const Color(0xFFF6F8FA),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 210.h,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 700),
            autoPlayCurve: Curves.easeInOutCubic,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              controller.currentIndex.value = index.toDouble();
            },
          ),
        ),
        SizedBox(height: 14.h),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: controller.carouselImage.asMap().entries.map((entry) {
              final isSelected =
                  controller.currentIndex.value.round() == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: isSelected ? 16.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  color: isSelected
                      ? const Color(0xFF1552C6)
                      : const Color(0xFFBFDBFE),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGetSupportSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Get Support',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 25.5 / 16,
                  color: const Color(0xFF121D31),
                ),
              ),
              Text(
                'Quick help, just a tap away',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 16 / 14,
                  color: const Color(0xFF68768E),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildSupportCard(
            title: 'Talk to Customer Care',
            subtitle: 'Speak with our support team',
            iconBg: const Color(0xFFEFF6FF),
            iconWidget: Icon(
              Icons.phone_rounded,
              color: const Color(0xFF0049C2),
              size: 20.sp,
            ),
            onTap: () {
              controller.openPhoneCall(
                isNepal ? "+919739457112" : "+919778687615",
              );
            },
          ),
          SizedBox(height: 10.h),
          _buildSupportCard(
            title: 'Chat on WhatsApp',
            subtitle: 'Get instant support on WhatsApp',
            iconBg: const Color(0xFFECFDF5),
            iconWidget: Image.asset(
              'assets/images/whatsapp.png',
              width: 22.w,
              height: 22.w,
              errorBuilder: (_, __, ___) => Icon(
                Icons.chat_bubble_rounded,
                color: const Color(0xFF25D366),
                size: 20.sp,
              ),
            ),
            onTap: () {
              controller.openWhatsApp();
            },
          ),
          SizedBox(height: 10.h),
          _buildSupportCard(
            title: 'Report an Issue',
            subtitle: 'Let us know what went wrong',
            iconBg: const Color(0xFFFFF1F2),
            iconWidget: Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFF43F5E),
              size: 22.sp,
            ),
            onTap: () {
              controller.openMail("care@goecworld.com");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard({
    required String title,
    required String subtitle,
    required Color iconBg,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFF1F5F9).withValues(alpha: 0.9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg,
                ),
                alignment: Alignment.center,
                child: iconWidget,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 21 / 16,
                        color: const Color(0xFF121D31),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 18 / 14,
                        color: const Color(0xFF68768E),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: const Color(0xFFA0AABD),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

