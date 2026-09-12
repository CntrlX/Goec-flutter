import 'dart:async';
import 'package:get/get.dart';
import '../Utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:freelancer_app/constants.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/Singletones/app_data.dart';
import 'package:freelancer_app/Model/apiResponseModel.dart';
import 'package:freelancer_app/Utils/SharedPreferenceUtils.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';

class OtpNumberPageController extends GetxController {
  RxInt isIndex = (-1).obs;
  RxBool isFocus = false.obs;
  RxBool isOtpValid = false.obs;
  TextEditingController otpController = TextEditingController();
  String phone = '+91';
  Timer? timer;
  RxInt s = 30.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is List) {
        phone = Get.arguments[0] ?? '';
        String? autoOtp = Get.arguments.length > 1 ? Get.arguments[1] : null;
        if (autoOtp != null) {
          otpController.text = autoOtp;
          isOtpValid.value = autoOtp.trim().length >= 5;
        }
      } else {
        phone = Get.arguments.toString();
      }
    } else {
      phone = '';
    }

    otpController.addListener(() {
      final text = otpController.text.trim();
      isOtpValid.value = text.length >= 5;
    });

    startTimer();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  startTimer() {
    timer?.cancel();
    s.value = 30;
    timer = Timer.periodic(const Duration(seconds: 1), (_timer) {
      if (s.value <= 0) {
        s.value = 0;
        _timer.cancel();
      } else {
        s.value--;
      }
    });
  }

  resendOTP() async {
    showLoading(kLoading);
    String? otp = await CommonFunctions().sendOtpAndGetOtp(phone);
    hideLoading();
    if (otp != null) {
      otpController.text = otp;
      startTimer();
    } else {
      showError('Failed to resend OTP. Try again.');
    }
  }

  verifyOTP() async {
    if (otpController.text.trim().isEmpty) return;
    showLoading(kLoading);
    ResponseModel res =
        await CommonFunctions().verifyOTP(phone, otpController.text.trim());
    hideLoading();
    if (res.statusCode == 200) {
      appData.token = res.body['result']['token'];
      appData.userModel.value.username = res.body['result']['username'];
      await saveString('token', appData.token);
      await saveString('username', appData.userModel.value.username);
      appData.userModel.value = await CommonFunctions().getUserProfile();
      if (appData.userModel.value.name.isEmpty ||
          appData.userModel.value.email.isEmpty) {
        Get.offAllNamed(Routes.addNameEmailPageRoute);
      } else {
        Get.offAllNamed(Routes.homePageRoute);
      }
    } else {
      showError('Failed to login. Try again.');
    }
  }
}
