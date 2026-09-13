import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Controller/rfid_page_controller.dart';
import '../../Utils/routes.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';

class RFIDnumberScreen extends GetView<RfidPageController> {
  const RFIDnumberScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeroCard(),
                  _buildContentCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kBrandPrimaryBlue,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 10.h,
              bottom: 14.h,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Text(
                  "RFID",
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Image.asset(
        "assets/images/rfid_card_banner.png",
        width: double.infinity,
        height: 183.h,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        children: [
          Text(
            "Your Charging Card",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff0C1A30),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Tap and start charging at supported GOEC\nstations without opening the app.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff76859D),
              height: 1.35,
            ),
          ),
          SizedBox(height: 24.h),
          // 3 Benefit Cards
          Row(
            children: [
              Expanded(
                child: _buildBenefitCard(
                  svgPath: 'assets/svg/rfid_no_app.svg',
                  title: "No app\nneeded",
                  topPadding: 20.h,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildBenefitCard(
                  svgPath: 'assets/svg/rfid_instant.svg',
                  title: "Instant\ntap-start",
                  topPadding: 20.h,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildBenefitCard(
                  svgPath: 'assets/svg/rfid_globe.svg',
                  title: "Works at all\nGO EC\nstations",
                  topPadding: 12.h,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Linked RFID list or Order RFID card box
          Obx(() {
            if (controller.rfid_list.isEmpty) {
              return _buildEmptyStateCard();
            } else {
              return _buildLinkedRfidSection();
            }
          }),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required String svgPath,
    required String title,
    double topPadding = 16,
  }) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xffE6EAEF), width: 1),
      ),
      child: Column(
        children: [
          SizedBox(height: topPadding),
          SizedBox(
            width: 32.w,
            height: 32.w,
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff1E293B),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xffF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0F172A).withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "No RFID card linked yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff121D31),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Order your GOEC RFID card and enjoy a faster,\nmore convenient charging experience.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff68768E),
              height: 1.35,
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.orderRfidPageRoute);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPrimaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              child: Text(
                "Order RFID Card",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedRfidSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Linked Cards",
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xff121D31),
          ),
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.rfid_list.length,
          separatorBuilder: (context, index) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final tag = controller.rfid_list[index].toString();
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xffE6EAEF)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: const Color(0xffE6F0FF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/svg/profile_rfid.svg',
                      width: 18.w,
                      height: 18.w,
                      colorFilter: ColorFilter.mode(kBrandPrimaryBlue, BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tag,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff121D31),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Color(0xff10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Active",
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/svg/profile_copy.svg',
                      width: 18.w,
                      height: 18.w,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: tag));
                      showSuccess("RFID number copied to clipboard!");
                    },
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 18.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(Routes.orderRfidPageRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrandPrimaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              elevation: 0,
            ),
            child: Text(
              "Order Additional RFID Card",
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
