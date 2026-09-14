import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freelancer_app/Model/activeSessionModel.dart';
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
  ActiveSessionModel? activeSessionModel;
  RxString stationName = ''.obs;
  RxString stationAddress = ''.obs;
  RxString sessionDuration = '0 hrs 0 min'.obs;
  RxString connectorTypeName = 'Type 2'.obs;
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

  getArguments() async {
    // '253-z1-1-Q  for QR code. A for App'
    var arg = Get.arguments;
    if (arg != null && arg is String) {
      stationId = Get.arguments;
      kLog('id: $stationId');
    } else if (arg != null && arg is List) {
      if (arg.isNotEmpty && arg[0] != null) {
        seperator = (arg[0] as String).split('-');
        stationId = seperator[0];
      }
      if (arg.length > 1 && arg[1] is ChargingStatusModel) {
        status_model.value = arg[1];
        if (status_model.value.connectorType.isNotEmpty) {
          connectorTypeName.value = status_model.value.connectorType;
        }
      }
      if (arg.length > 2 && arg[2] is ActiveSessionModel) {
        activeSessionModel = arg[2];
        if (activeSessionModel!.connectorType.isNotEmpty) {
          connectorTypeName.value = activeSessionModel!.connectorType;
        }
        if (activeSessionModel!.chargerName.isNotEmpty) {
          stationName.value = activeSessionModel!.chargerName;
        }
      }
      if (arg.length > 3) {
        if (arg[3] is List) {
          final t = arg[3] as List;
          if (t.length >= 2) {
            sessionDuration.value = '${t[0]} hrs ${t[1]} min';
          }
        } else if (arg[3] is String) {
          sessionDuration.value = arg[3];
        }
      }
    }

    if (stationId.isNotEmpty && stationId != '-1') {
      try {
        final details =
            await CommonFunctions().getChargeStationDetails(stationId);
        if (details.name.isNotEmpty) {
          stationName.value = details.name;
        }
        if (details.address.isNotEmpty) {
          stationAddress.value = details.address;
        }
      } catch (e) {
        kLog('Failed to fetch station details: $e');
      }
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
