import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/Controller/loginpage_controller.dart';
import 'package:freelancer_app/Utils/routes.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_cards.dart';

class LoginPage extends GetView<LoginPageController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (size.height == 0) {
      size = MediaQuery.of(context).size;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full-screen PageView for the 3 Onboarding screens
          PageView(
            controller: controller.cardController,
            children: const [
              CustomCards(
                image: "assets/images/onboarding_1.png",
                prefixTitle: "Locate ",
                highlightTitle: "chargers",
                subText:
                    "Find nearby charging stations with real-time availability.",
              ),
              CustomCards(
                image: "assets/images/onboarding_2.png",
                prefixTitle: "Monitor ",
                highlightTitle: "Charging's",
                subText:
                    "Track your charging progress and session status in real time.",
              ),
              CustomCards(
                image: "assets/images/onboarding_3.png",
                prefixTitle: "Pay ",
                highlightTitle: "Conveniently",
                subText:
                    "Pay securely and charge seamlessly with flexible payment options.",
              ),
            ],
          ),

          // Pinned Bottom Section: Indicator, CTA Button, and Terms
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pagination Dots Indicator
                    SmoothPageIndicator(
                      controller: controller.cardController,
                      count: 3,
                      effect: CustomizableEffect(
                        activeDotDecoration: DotDecoration(
                          width: 24.w,
                          height: 8.h,
                          color: kBrandPrimaryMint,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        dotDecoration: DotDecoration(
                          width: 8.w,
                          height: 8.h,
                          color: kInactiveDotColor,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        spacing: 10.w,
                      ),
                    ),

                    // Exact Figma Spacing between Dots and Main Button: 58.h
                    height(58.h),

                    // Get Started CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(Routes.enternumberpageRoute);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandPrimaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                        ),
                        child: Text(
                          "Get Started",
                          style: kOnboardingButtonTextStyle,
                        ),
                      ),
                    ),

                    height(14.h),

                    // Terms & Privacy Text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "By selecting get started, you are agreeing to the",
                          textAlign: TextAlign.center,
                          style: kOnboardingTermsMutedStyle,
                        ),
                        height(2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => controller.onTermsCondition(),
                              child: Text(
                                "Terms & Conditions",
                                style: kOnboardingTermsLinkStyle,
                              ),
                            ),
                            Text(
                              " and ",
                              style: kOnboardingTermsMutedStyle,
                            ),
                            GestureDetector(
                              onTap: () => controller.onPrivacyPolicy(),
                              child: Text(
                                "Privacy Policy.",
                                style: kOnboardingTermsLinkStyle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    height(16.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
