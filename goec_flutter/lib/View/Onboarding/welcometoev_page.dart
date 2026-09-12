import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Controller/loginpage_controller.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';
import '../Widgets/customText.dart';
import '../Widgets/unfocus_wrapper.dart';

class WelcomeToEvPage extends GetView<LoginPageController> {
  const WelcomeToEvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: UnfocusWrapper(
        child: SafeArea(
          child: Stack(
            children: [
              // Scrollable Content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      height(40.h),

                      // Headline & Subtitle Group
                      Obx(
                            () {
                              final countryName =
                                  controller.country.value == '977'
                                      ? "Nepal's"
                                      : "India's";
                              return RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: kFontFamily,
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w700,
                                    color: kNeutralPrimary,
                                    height: 1.35,
                                  ),
                                  children: [
                                    TextSpan(text: 'Welcome to $countryName \n'),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            kOnboardingGradient.createShader(
                                          Rect.fromLTWH(
                                              0, 0, bounds.width, bounds.height),
                                        ),
                                        child: Text(
                                          'Largest ',
                                          style: TextStyle(
                                            fontFamily: kFontFamily,
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'EV charging \nnetwork',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          height(4.h),

                          // Subtitle
                          CustomText(
                            text:
                                'Add your name and email so we can personalise your charging experience.',
                            textAlign: TextAlign.left,
                            size: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: kNeutralSecondary,
                            height: 1.4,
                          ),

                          height(16.h),

                          // Form Section
                          // 1. Full Name
                          CustomText(
                            text: 'Full name',
                            size: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: kNeutralPrimary,
                          ),
                          height(8.h),
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
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 18.sp,
                                  color: const Color(0xFFA0AABD),
                                ),
                                width(12.w),
                                Container(
                                  width: 0.66,
                                  height: 24.h,
                                  color: const Color(0xFFE6EAEF),
                                ),
                                width(12.w),
                                Expanded(
                                  child: TextField(
                                    controller:
                                        controller.nameEditingController,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: kNeutralPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Jane Doe',
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
                                  ),
                                ),
                              ],
                            ),
                          ),

                          height(16.h),

                          // 2. Email Address
                          CustomText(
                            text: 'Email address',
                            size: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: kNeutralPrimary,
                          ),
                          height(8.h),
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
                                Icon(
                                  Icons.mail_outline_rounded,
                                  size: 18.sp,
                                  color: const Color(0xFFA0AABD),
                                ),
                                width(12.w),
                                Container(
                                  width: 0.66,
                                  height: 24.h,
                                  color: const Color(0xFFE6EAEF),
                                ),
                                width(12.w),
                                Expanded(
                                  child: TextField(
                                    controller:
                                        controller.mailEditingController,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: kNeutralPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'you@example.com',
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
                                      if (controller.isFormValid.value) {
                                        controller.saveUserNameEmail();
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

                  // Bottom Submit Button with Dynamic State
                  Positioned(
                    left: 24.w,
                    right: 24.w,
                    bottom: 24.h,
                    child: Obx(
                      () {
                        final isValid = controller.isFormValid.value;
                        return SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: isValid
                                ? () => controller.saveUserNameEmail()
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBrandPrimaryBlue,
                              disabledBackgroundColor: const Color(0xFFA0AABD),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              elevation: isValid ? 4 : 0,
                              shadowColor: isValid
                                  ? kBrandPrimaryBlue.withValues(alpha: 0.35)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.r),
                              ),
                            ),
                            child: CustomText(
                              text: 'Submit',
                              size: 16.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: Colors.white,
                            ),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
