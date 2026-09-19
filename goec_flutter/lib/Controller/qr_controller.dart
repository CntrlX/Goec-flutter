import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Model/activeSessionModel.dart';
import '../Singletones/app_data.dart';
import '../Singletones/common_functions.dart';
import '../Singletones/dialogs.dart';
import '../Utils/toastUtils.dart';
import '../constants.dart';

class QrController extends GetxController with WidgetsBindingObserver {
  MobileScannerController? cameraController;

  final RxBool hasCameraPermission = false.obs;
  final RxBool permanentlyDenied = false.obs;
  final RxBool checkingPermission = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    ensureCameraPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ensureCameraPermission(showSheetIfNeeded: true);
    }
  }

  Future<void> ensureCameraPermission({bool showSheetIfNeeded = true}) async {
    checkingPermission.value = true;
    var status = await Permission.camera.status;

    if (!status.isGranted && !status.isPermanentlyDenied && !status.isRestricted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      permanentlyDenied.value = false;
      hasCameraPermission.value = true;
      if (Get.isBottomSheetOpen == true) Get.back();
      cameraController ??= MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
      try {
        await cameraController?.start();
      } catch (_) {}
      checkingPermission.value = false;
      return;
    }

    hasCameraPermission.value = false;
    permanentlyDenied.value = status.isPermanentlyDenied || status.isRestricted;
    try {
      await cameraController?.stop();
    } catch (_) {}
    checkingPermission.value = false;

    if (showSheetIfNeeded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Dialogs().showCameraPermissionSheet(
          permanentlyDenied: permanentlyDenied.value,
          onEnabled: () => ensureCameraPermission(showSheetIfNeeded: false),
        );
      });
    }
  }

  Future<void> openCameraSettings() async {
    await openAppSettings();
  }

  onQrCodeReceived(String? barcode) async {
    await cameraController?.stop();
    try {
      Map<String, dynamic> map = json.decode(barcode ?? '');
      var model = ActiveSessionModel.fromJson(map);
      logger.i(model.chargerName);
      appData.tempActiveSessionModel = model;
      CommonFunctions()
          .createBookingAndCheck(appData.tempActiveSessionModel, null);
    } catch (e) {
      showError('No Valid QR Code Detected!');
      if (hasCameraPermission.value) {
        await cameraController?.start();
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    cameraController = null;
    super.onClose();
  }
}
