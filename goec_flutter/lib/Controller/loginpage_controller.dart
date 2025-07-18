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
  RxString country = "91".obs;

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
    // / implement onInit
    // textEditingController.addListener(() {
    //   enablenameTextfield.value = nameEditingController.text.isNotEmpty;
    // });

    super.onInit();
  }

  Future<bool> login() async {
    showLoading(kLoading);
    if (phoneController.text.isEmpty) {
      EasyLoading.showInfo('Please enter phone number');
      return false;
    }
    bool res = await CommonFunctions()
        .sendOtp('+${country.value}${phoneController.text}');
    hideLoading();
    if (res) {
      Get.toNamed(Routes.enterotppageRoute,
          arguments: '+${country.value}${phoneController.text}');
    } else {
      showError('Failed to login. Try again.');
    }
    return res;
  }

  onSkip() {
    Get.offAllNamed(Routes.homePageRoute);
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
