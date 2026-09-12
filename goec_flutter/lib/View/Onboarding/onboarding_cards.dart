import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants.dart';

class OnboardingSlideData {
  final String image;
  final String prefixTitle;
  final String highlightTitle;
  final String subText;

  const OnboardingSlideData({
    required this.image,
    required this.prefixTitle,
    required this.highlightTitle,
    required this.subText,
  });
}

class CustomCards extends StatelessWidget {
  final String image;
  final String prefixTitle;
  final String highlightTitle;
  final String subText;

  const CustomCards({
    super.key,
    required this.image,
    required this.prefixTitle,
    required this.highlightTitle,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full screen background image
        Image.asset(
          image,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          width: double.infinity,
          height: double.infinity,
        ),

        // Title and Subtitle positioned exactly as in Figma above dots
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 245.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    prefixTitle,
                    style: kOnboardingHeadingStyle,
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => kOnboardingGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: Text(
                      highlightTitle,
                      style: kOnboardingHighlightStyle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  subText,
                  textAlign: TextAlign.center,
                  style: kOnboardingSubtitleStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
