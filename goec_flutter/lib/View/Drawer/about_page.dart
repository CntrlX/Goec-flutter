import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _kPrimaryBlue = Color(0xFF0049C2);
  static const Color _kBgColor = Colors.white;
  static const Color _kBodyTextColor = Color(0xFF68768E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Banner
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Image.asset(
                      'assets/images/about_us_banner.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160.h,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: Text(
                          'Charge today\nfor a cleaner tomorrow',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF121D31),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content Body
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We are a future-centric company that is an amalgamation of a skilled workforce, industry experts who have the experience, knowledge, and a commitment to the revolution in the EV industry. Our platform brings together people, possibilities, technology and integrates that with our expertise into a systematic network designed to deliver optimized solutions through India.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: _kBodyTextColor,
                            height: 1.55,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Steered forward with the experience & vision of the management, we are redefining ourselves to match the future needs of a sustainable world through GOEC, a commitment to a cleaner and greener environment, and a complete solution for the electric vehicle industry with a diverse focus on manufacturing, infrastructure, and technology.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: _kBodyTextColor,
                            height: 1.55,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'GOEC is transforming the future of electric automobiles through a strategic and collective network of Electric Vehicle (EV) charging stations across India.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: _kBodyTextColor,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Version Text
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: _kBodyTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _kPrimaryBlue,
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
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Text(
                  'About us',
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

