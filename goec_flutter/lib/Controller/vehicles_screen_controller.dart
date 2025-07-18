import 'package:get/get.dart';
import '../Utils/routes.dart';
import '../Model/vehicleModel.dart';
import 'package:flutter/material.dart';
import 'package:freelancer_app/constants.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';

class VehiclesScreenController extends GetxController {
  RxInt reload = 0.obs;
  RxBool enablemailTextfield = false.obs;
  // RxBool isSelectColor = false.obs;
  // RxBool isVehicleColor = false.obs;
  RxBool isVisible = false.obs;
  bool isLoading = false;
  // RxInt isSelectedindex = (-1).obs;
  // RxInt isIndex = 0.obs;
  // RxInt isIndex1 = 0.obs;
  RxInt isSelectedVehicleindex = (-1).obs;
  RxList<VehicleModel> selectedVehicleList = RxList();
  Rx<VehicleModel> selectedVehicle = kVehicleModel.obs;
  RxString selectedBrand = kAll.obs;
  RxList<String> brands = RxList();
  RxMap<String, dynamic> brandVehicles = RxMap();

  TextEditingController numEditingController = TextEditingController();

  RxList<VehicleModel> vehicle_list = RxList();
  TextEditingController searchTextFieldcontroller = TextEditingController();

  @override
  void onInit() {
    // / implement onInit
    super.onInit();
    getAllVehicles();
    CommonFunctions().getUserProfile();
  }

  getAllVehicles() async {
    showLoading(kLoading);
    var res = await CommonFunctions().getEvTemplates();
    hideLoading();
    brands.value = res['brands'];
    res.remove('brands');
    brandVehicles.value = res;
    showAllVehicles();
  }

  showAllVehicles() {
    selectedVehicleList.clear();
    List<VehicleModel> list = [];
    brandVehicles.forEach((key, value) {
      list.addAll(value);
    });
    selectedVehicleList.value = list;
  }

  showBrandVehicles(String value) {
    selectedVehicleList.value = brandVehicles[value].toList();
  }

  onDropdownValuChanged(String? value) {
    selectedBrand.value = value ?? kAll;
    if (selectedBrand.value == kAll)
      showAllVehicles();
    else
      showBrandVehicles(selectedBrand.value);
  }

  onVehicleSubmit() async {
    if (isLoading) return;
    isLoading = true;
    showLoading('Adding vehicle...');
    bool isSuccess = await CommonFunctions().addEvToUser(
      vehicleId: selectedVehicle.value.id,
      regNumber: numEditingController.text,
    );
    hideLoading();
    if (isSuccess) {
      showSuccess('Vehicle added successfully');
      int s = 0;
      Get.offNamedUntil(
        Routes.myvehicleRoute,
        (route) => s++ >= 2,
        arguments: Get.arguments,
      );
    } else {
      showError('Failed to add vehicle. Try again!');
    }
    isLoading = false;
  }

  ///SEARCH VEHICLES///
  getSearchedVehicles() async {
    brandVehicles.forEach((key, value) {
      if (key.toLowerCase().contains(searchTextFieldcontroller.text) ||
          key.contains(searchTextFieldcontroller.text)) {
        vehicle_list.value = value;
      }
    });
    // vehicle_list.value = await CommonFunctions()
  }
}
