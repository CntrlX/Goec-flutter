import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controller/rfid_page_controller.dart';
import '../../constants.dart';
import '../Widgets/glass_circle_icon_button.dart';

class OrderRFIDScreen extends GetView<RfidPageController> {
  const OrderRFIDScreen({Key? key}) : super(key: key);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(),
                  _buildContentBody(),
                ],
              ),
            ),
          ),
          _buildBottomButton(context),
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
                GlassBackButton(
                  onTap: () => Get.back(),
                ),
                SizedBox(width: 14.w),
                Text(
                  "Order RFID Card",
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

  Widget _buildHeroImage() {
    return SizedBox(
      width: double.infinity,
      height: 183.h,
      child: Image.asset(
        "assets/images/rfid_card_banner.png",
        width: double.infinity,
        height: 183.h,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildContentBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "GO EC Smart Charge",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff121D31),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: 38.w,
            height: 3.5.h,
            decoration: BoxDecoration(
              color: kBrandPrimaryBlue,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "GOEC \"Smart charge\" is a cool looking RFID tag. It is your One Key to all our chargers. Next time when you are at our chargers, all you have to do is plug in your vehicle and tap the key on the charger to start . Yes, its as simple as that. You don't need your mobile to start charging ever again.",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff68768E),
              height: 1.45,
            ),
          ),
          SizedBox(height: 14.h),
          _buildBulletItem("Contains RFID chip linked to your account."),
          _buildBulletItem("Cool looking key chain."),
          _buildBulletItem("Make EV charging a hassle free experience."),
          _buildBulletItem("Anyone having key can charge without the mobile app."),
          SizedBox(height: 18.h),
          Text(
            "Delivery time",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff121D31),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Will take up to 5-7 working days for shipment from the date of receipt of order. Shipment details will be shared as soon as shipment is made.",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff68768E),
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "*RFID acquisition is facilitated through the GO EC application, with validity of 1 year from the date of integration. Renewal is subject to applicable charges and is mandatory after the initial 1 year period and can be carried out either through the GOEC application or by contacting the customer care number. Replacements for physically damaged RFID are not provided, but RFID malfunctions due to technical issues will be addressed or replaced as necessary.*",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: const Color(0xff68768E),
              height: 1.4,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(color: Color(0xffE6EAEF), height: 1),
          ),
          Text(
            "Contact Us:",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff121D31),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 16.sp,
                color: const Color(0xff68768E),
              ),
              SizedBox(width: 8.w),
              Text(
                "info@goecworld.com",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff68768E),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 16.sp,
                color: const Color(0xff68768E),
              ),
              SizedBox(width: 8.w),
              Text(
                "+918281100520",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff68768E),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(color: Color(0xffE6EAEF), height: 1),
          ),
          Text(
            "Terms & Conditions:",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff121D31),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Return / Cancellation Policy",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff68768E),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "No Cancellation / Non-Returnable. The selected item is not eligible for return and/or replacement.\\n\\nHowever, this policy will not apply if you have received a physically damaged key or the key does not functions as required. In such cases, once intimated GOEC shall contact you to ascertain the damage or malfunction in the product prior to initiating a return or replacement as applicable.\\n\\nYou agree to share information entered on this page with GOEC CHARGING (owner of this page) and Razorpay, adhering to applicable laws.\\n\\nYou agree to share information entered on this page with GO EC (owner of this page) and Razorpay, adhering to applicable laws.",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff68768E),
              height: 1.45,
            ),
          ),
          SizedBox(height: 18.h),
          _buildPriceCard(),
          SizedBox(height: 16.h),
          _buildRazorpayFooter(),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5.w,
            height: 5.w,
            margin: EdgeInsets.only(top: 7.h, right: 8.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff68768E),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xff68768E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffE6EAEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "One-time card price",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff121D31),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "(Including delivery)",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff68768E),
                ),
              ),
            ],
          ),
          Obx(() {
            final price = controller.rfid_price.value > 0
                ? controller.rfid_price.value
                : 370;
            return Text(
              "₹$price",
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: kBrandPrimaryBlue,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRazorpayFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: kBrandPrimaryBlue,
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                "Razorpay",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff121D31),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            "Want to create page like this for your Business? Visit",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 10.5.sp,
              color: const Color(0xff68768E),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            "Razorpay Payment Pages ↗ to get started!",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: kBrandPrimaryBlue,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 12.sp,
                color: const Color(0xff94A3B8),
              ),
              SizedBox(width: 4.w),
              Text(
                "Report Page",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 10.5.sp,
                  color: const Color(0xff94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 10.h,
        bottom: MediaQuery.of(context).padding.bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () {
            controller.orderRFID();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrandPrimaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
            elevation: 0,
          ),
          child: Text(
            "Next",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
