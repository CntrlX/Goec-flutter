import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Utils/routes.dart';

class LoginPageController extends GetxController {
  // TextEditingController textEditingController = TextEditingController();
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mailEditingController = TextEditingController();
  TextEditingController tempEmailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  PageController cardController = PageController();
  RxBool enablenameTextfield = false.obs;
  RxBool enablemailTextfield = false.obs;
  RxInt selectedIndex = 0.obs;
  RxString textfield = "".obs;
  RxString country = "977".obs;
  RxString countryFlag = "🇳🇵".obs;
  RxString countryCode = "NP".obs;
  RxBool isPhoneValid = false.obs;
  RxBool isFormValid = false.obs;

  void setCountry({required String dialCode, required String flag, required String code}) {
    country.value = dialCode.replaceAll('+', '');
    countryFlag.value = flag;
    countryCode.value = code;
    _validatePhone(phoneController.text);
  }

  void _validatePhone(String val) {
    final clean = val.trim();
    textfield.value = clean;
    // Nepal numbers are typically 10 digits; standard international 7-15 digits
    if (country.value == "977" || country.value == "91") {
      isPhoneValid.value = clean.length >= 10;
    } else {
      isPhoneValid.value = clean.length >= 7;
    }
  }

  void _validateForm() {
    final name = nameEditingController.text.trim();
    final email = mailEditingController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    isFormValid.value = name.isNotEmpty && email.isNotEmpty && emailRegex.hasMatch(email);
  }

  void nameTextfieldColorChange() {
    enablenameTextfield.value = true;
    if (enablenameTextfield == true) {
      enablemailTextfield.value = false;
    }
  }

  void mailTextFieldColorChange() {
    enablemailTextfield.value = true;
    if (enablemailTextfield == true) {
      enablenameTextfield.value = false;
    }
  }

  @override
  void onInit() {
    phoneController.addListener(() {
      _validatePhone(phoneController.text);
    });
    nameEditingController.addListener(_validateForm);
    mailEditingController.addListener(_validateForm);
    super.onInit();
  }

  @override
  void onClose() {
    // phoneController.dispose();
    super.onClose();
  }

  Future<bool> login() async {
    showLoading(kLoading);
    if (phoneController.text.isEmpty) {
      EasyLoading.showInfo('Please enter phone number');
      return false;
    }
    // TODO: DELETE IN PRODUCTION - Using workaround function to get OTP for auto-fill
    String? otp = await CommonFunctions()
        .sendOtpAndGetOtp('+${country.value}${phoneController.text}');
    // bool res = await CommonFunctions()
    //     .sendOtp('+${country.value}${phoneController.text}');
    hideLoading();
    if (otp != null) {
      Get.toNamed(
        Routes.enterotppageRoute,
        arguments: [
          '+${country.value}${phoneController.text}',
          if (otp.isNotEmpty) otp,
        ],
      );
    } else {
      showError('Failed to login. Try again.');
    }
    return otp != null;
  }

  onSkip() {
    Get.offAllNamed(
      Routes.homePageRoute,
      arguments: 'requestLocation',
    );
  }

  //FOR UPDATING USER NAME AND EMAIL AFTER OTP
  saveUserNameEmail() async {
    if (nameEditingController.text.isEmpty ||
        mailEditingController.text.isEmpty) {
      EasyLoading.showInfo('Please fill up all the fields!');
      return;
    }
    showLoading(kLoading);
    bool res = await CommonFunctions().putUserNameEmail(
        nameEditingController.text, mailEditingController.text);
    if (res) Get.toNamed(Routes.addvehiclesRoute, arguments: 'isFirstTime');
    hideLoading();
  }

  onTermsCondition() {
    launchUrlString('https://goecworld.com/terms-and-conditions');
  }

  onPrivacyPolicy() {
    launchUrlString('https://goecworld.com/privacy-policy');
  }
}
