import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freelancer_app/Controller/splash_screen_controller.dart';
import 'package:freelancer_app/View/Widgets/appbar.dart';
import 'package:get/get.dart';
import '../../constants.dart';

class SplashScreen extends GetView<SplashScreenController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashScreenController());
    if (size.height == 0) {
      size = MediaQuery.of(context).size;
    }
    return WhiteStatusBar(
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SvgPicture.asset(
          "assets/svg/goec_m_logo.svg",
          width: 190.w,
          fit: BoxFit.contain,
        ),
      ),
    ),
    );
  }
}
