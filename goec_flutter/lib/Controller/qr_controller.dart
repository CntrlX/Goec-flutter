import 'dart:convert';
import '../Model/activeSessionModel.dart';
import '../Utils/toastUtils.dart';
import '../constants.dart';
import 'package:get/get.dart';
import '../Singletones/app_data.dart';
import '../Singletones/common_functions.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:flutter/material.dart';
// import 'package:freelancer_app/constants.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:freelancer_app/Singletones/app_data.dart';
// import 'package:freelancer_app/Singletones/common_functions.dart';

class QrController extends GetxController {
  MobileScannerController cameraController = MobileScannerController();
  // RxBool iskeybort =(MediaQuery.of(context).viewInsets.bottom!=0).obs ;

  // final qrKey = GlobalKey(debugLabel: "QR");
  // QRViewController? qrViewController;
  // TextEditingController pinCodeController = TextEditingController();

  // RxInt otpTimer = 30.obs;
  @override
  void onInit() {
    cameraController.stop();
    super.onInit();
  }

  // @override
  // void dispose() {
  //   cameraController.dispose();
  //   super.dispose();
  // }

  onQrCodeReceived(String? barcode) async {
    cameraController.stop();
    try {
      Map<String, dynamic> map = json.decode(barcode ?? '');
      var model = ActiveSessionModel.fromJson(map);
      logger.i(model.chargerName);
      appData.tempActiveSessionModel = model;
      CommonFunctions().createBookingAndCheck(appData.tempActiveSessionModel,null);
    } catch (e) {
      showError('No Valid QR Code Detected!');
      cameraController.start();
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
