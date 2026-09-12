import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Controller/loginpage_controller.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';
import '../Widgets/country_code_picker_dialog.dart';
import '../Widgets/customText.dart';
import '../Widgets/unfocus_wrapper.dart';

class EnterNumberPage extends GetView<LoginPageController> {
  const EnterNumberPage({Key? key}) : super(key: key);

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
                                const TextSpan(text: 'Enter your '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        kOnboardingGradient.createShader(
                                      Rect.fromLTWH(
                                          0, 0, bounds.width, bounds.height),
                                    ),
                                    child: Text(
                                      'mobile number',
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
                                "We'll send a 5-digit OTP to verify your number.",
                            textAlign: TextAlign.center,
                            size: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: kNeutralSecondary,
                            height: 1.4,
                          ),

                          height(14.h),

                          // Phone Number Input Box
                          Container(
                            height: 59.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: const Color(0xFFE6EAEF),
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              children: [
                                // Country Selector
                                Obx(
                                  () => InkWell(
                                    onTap: () async {
                                      final selected =
                                          await CountryCodePickerDialog.show(
                                        context,
                                        selectedCountry: CountryCode(
                                          name: '',
                                          dialCode:
                                              '+${controller.country.value}',
                                          code: controller.countryCode.value,
                                          flag: controller.countryFlag.value,
                                        ),
                                      );
                                      if (selected != null) {
                                        controller.setCountry(
                                          dialCode: selected.dialCode,
                                          flag: selected.flag,
                                          code: selected.code,
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.h),
                                      child: CustomText(
                                        text: '+${controller.country.value}',
                                        size: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: kNeutralPrimary,
                                      ),
                                    ),
                                  ),
                                ),

                                width(12.w),

                                // Hairline vertical divider
                                Container(
                                  width: 0.66,
                                  height: 24.h,
                                  color: const Color(0xFFE6EAEF),
                                ),

                                width(12.w),

                                // Mobile Number Input Field
                                Expanded(
                                  child: TextField(
                                    controller: controller.phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(15),
                                    ],
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: kNeutralPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter mobile number',
                                      hintStyle: TextStyle(
                                        fontFamily: kFontFamily,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFFA0AABD),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onSubmitted: (_) {
                                      if (controller.isPhoneValid.value) {
                                        controller.login();
                                      }
                                    },
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

                  // Animated Popup "Send OTP" Button at Bottom
                  Positioned(
                    left: 24.w,
                    right: 24.w,
                    bottom: 24.h,
                    child: Obx(
                      () {
                        final isValid = controller.isPhoneValid.value;
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
                                        ? () => controller.login()
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
                                      text: 'Send OTP',
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
