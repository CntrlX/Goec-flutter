import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../Controller/otpnumberPage_controller.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';
import '../Widgets/customText.dart';
import '../Widgets/unfocus_wrapper.dart';

class EnterOtpPage extends GetView<OtpNumberPageController> {
  const EnterOtpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: UnfocusWrapper(
        child: Stack(
          children: [
            // Background Illustration & Gradient Overlay from Figma
            Positioned.fill(
              child: Image.asset(
                'assets/images/phone_bg.png',
                fit: BoxFit.cover,
              ),
            ),

            // Foreground Content
            SafeArea(
              child: Stack(
                children: [
                  // Scrollable Form Content
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          height(48.h),

                          // Brand Logo
                          SvgPicture.asset(
                            'assets/svg/goec_m_logo.svg',
                            height: 42.h,
                            fit: BoxFit.contain,
                          ),

                          height(20.h),

                          // Title with Gradient Accent
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                color: kNeutralPrimary,
                                height: 1.3,
                              ),
                              children: [
                                const TextSpan(text: 'Enter '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        kOnboardingGradient.createShader(
                                      Rect.fromLTWH(
                                          0, 0, bounds.width, bounds.height),
                                    ),
                                    child: Text(
                                      'OTP code',
                                      style: TextStyle(
                                        fontFamily: kFontFamily,
                                        fontSize: 26.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          height(2.h),

                          // Subtitle
                          CustomText(
                            text:
                                "We've sent a 5-digit OTP to ${controller.phone.isNotEmpty ? controller.phone : 'your number'}",
                            textAlign: TextAlign.center,
                            size: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: kNeutralSecondary,
                            height: 1.4,
                          ),

                          height(24.h),

                          // 5-Digit Pin Input Field
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: PinCodeTextField(
                              appContext: context,
                              controller: controller.otpController,
                              length: 5,
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.fade,
                              textStyle: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: kNeutralPrimary,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(8.r),
                                fieldHeight: 56.h,
                                fieldWidth: 54.w,
                                activeColor: kBrandPrimaryBlue,
                                selectedColor: kBrandPrimaryBlue,
                                inactiveColor: const Color(0xFFE6EAEF),
                                activeFillColor: Colors.white,
                                selectedFillColor: Colors.white,
                                inactiveFillColor: Colors.white,
                                borderWidth: 1.2,
                              ),
                              enableActiveFill: true,
                              cursorColor: kBrandPrimaryBlue,
                              onChanged: (val) {},
                              onCompleted: (_) {
                                controller.verifyOTP();
                              },
                            ),
                          ),

                          height(16.h),

                          // Timer and Resend Row
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CustomText(
                                      text: "Time remaining: ",
                                      size: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: kNeutralSecondary,
                                    ),
                                    CustomText(
                                      text: "${controller.s.value}s",
                                      size: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: controller.s.value > 0
                                          ? kBrandPrimaryBlue
                                          : const Color(0xFFA0AABD),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: controller.s.value <= 0
                                      ? () => controller.resendOTP()
                                      : null,
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.h, horizontal: 2.w),
                                    child: CustomText(
                                      text: "Resend OTP",
                                      size: 14.sp,
                                      fontWeight: controller.s.value <= 0
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: controller.s.value <= 0
                                          ? kBrandPrimaryBlue
                                          : const Color(0xFFA0AABD),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          height(120.h),
                        ],
                      ),
                    ),
                  ),

                  // Animated Popup "Verify & Proceed" Button at Bottom
                  Positioned(
                    left: 24.w,
                    right: 24.w,
                    bottom: 24.h,
                    child: Obx(
                      () {
                        final isValid = controller.isOtpValid.value;
                        return AnimatedSlide(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          offset:
                              isValid ? Offset.zero : const Offset(0, 0.4),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: isValid ? 1.0 : 0.0,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutBack,
                              scale: isValid ? 1.0 : 0.85,
                              child: IgnorePointer(
                                ignoring: !isValid,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 54.h,
                                  child: ElevatedButton(
                                    onPressed: isValid
                                        ? () => controller.verifyOTP()
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kBrandPrimaryBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor: kBrandPrimaryBlue
                                          .withValues(alpha: 0.35),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.r),
                                      ),
                                    ),
                                    child: CustomText(
                                      text: 'Verify & Proceed',
                                      size: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
