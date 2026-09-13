import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freelancer_app/Model/chargingStatusModel.dart';
import 'package:freelancer_app/Utils/routes.dart';
import 'package:get/get.dart';

import '../Singletones/common_functions.dart';
import '../Utils/toastUtils.dart';
import '../constants.dart';

class FeedBackPageController extends GetxController {
  static const maxReviewLength = 500;

  RxInt selectedRating = 0.obs;
  RxInt reviewLength = 0.obs;
  String stationId = '-1';
  Rx<ChargingStatusModel> status_model = kChargingStatusModel.obs;
  TextEditingController feedbackController = TextEditingController();
  List<String> seperator = [];

  bool get canSubmit =>
      selectedRating.value >= 1 && feedbackController.text.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    getArguments();
    feedbackController.addListener(_onReviewChanged);
  }

  @override
  void onClose() {
    feedbackController.removeListener(_onReviewChanged);
    feedbackController.dispose();
    super.onClose();
  }

  void _onReviewChanged() {
    reviewLength.value = feedbackController.text.length;
  }

  void setRating(int rating) {
    selectedRating.value = rating;
  }

  getArguments() {
    // '253-z1-1-Q  for QR code. A for App'
    var arg = Get.arguments;
    if (arg != null && arg is String) {
      stationId = Get.arguments;
      kLog('id: $stationId');
    } else if (arg != null) {
      seperator = (arg[0] as String).split('-');
      stationId = seperator[0];
      status_model.value = arg[1];
      kLog('not id');
    }
  }

  Future<bool> postReviewForChargeStation(context) async {
    if (!canSubmit) {
      if (selectedRating.value < 1) {
        EasyLoading.showInfo('Please select a star rating');
      } else {
        EasyLoading.showInfo('Please write a short review');
      }
      return false;
    }
    showLoading(kLoading);
    kLog(stationId);
    kLog(seperator);
    bool status = await CommonFunctions().postReviewForChargeStation(
      stationId.toString(),
      selectedRating.value,
      feedbackController.text.trim(),
    );
    hideLoading();
    if (status) {
      FocusScope.of(context).unfocus();
      Get.toNamed(Routes.thankfeedbackPageRoute);
    } else {
      EasyLoading.showInfo('Something Went Wrong, Please Try Again');
      return false;
    }
    return status;
  }

  backToMaps() {
    Get.offAllNamed(Routes.homePageRoute);
  }
}
