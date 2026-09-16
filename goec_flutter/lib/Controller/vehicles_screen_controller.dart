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
  RxBool isVisible = false.obs;
  bool isLoading = false;
  RxBool isDefaultVehicle = true.obs;
  RxBool isDefaultLocked = false.obs;
  RxBool isFormValid = false.obs;

  RxInt isSelectedVehicleindex = (-1).obs;
  RxList<VehicleModel> selectedVehicleList = RxList();
  Rx<VehicleModel> selectedVehicle = kVehicleModel.obs;
  RxString selectedBrand = ''.obs;
  RxList<String> brands = RxList();
  RxMap<String, dynamic> brandVehicles = RxMap();

  TextEditingController numEditingController = TextEditingController();
  TextEditingController searchBrandController = TextEditingController();
  TextEditingController searchModelController = TextEditingController();

  RxList<String> filteredBrands = RxList();
  RxList<VehicleModel> filteredModels = RxList();

  RxList<VehicleModel> vehicle_list = RxList();
  TextEditingController searchTextFieldcontroller = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    numEditingController.addListener(_validateForm);
    _checkDefaultLock();
    getAllVehicles();
    CommonFunctions().getUserProfile();
  }

  @override
  void onClose() {
    numEditingController.removeListener(_validateForm);
    super.onClose();
  }

  Future<void> _checkDefaultLock() async {
    try {
      final evs = await CommonFunctions().getUserEvs();
      if (evs.isEmpty || Get.arguments == 'isFirstTime') {
        isDefaultVehicle.value = true;
        isDefaultLocked.value = true;
      } else {
        isDefaultLocked.value = false;
      }
    } catch (_) {
      if (Get.arguments == 'isFirstTime') {
        isDefaultVehicle.value = true;
        isDefaultLocked.value = true;
      }
    }
  }

  void _validateForm() {
    isFormValid.value = numEditingController.text.trim().isNotEmpty &&
        selectedVehicle.value.id != '-1' &&
        selectedVehicle.value.id.isNotEmpty;
  }

  Future<void> getAllVehicles() async {
    showLoading(kLoading);
    var res = await CommonFunctions().getEvTemplates();
    hideLoading();
    if (res['brands'] != null) {
      brands.value = List<String>.from(res['brands']);
      filteredBrands.value = List<String>.from(res['brands']);
      res.remove('brands');
      brandVehicles.value = res;
    }
  }

  void filterBrands(String query) {
    if (query.isEmpty) {
      filteredBrands.value = List<String>.from(brands);
    } else {
      filteredBrands.value = brands
          .where((b) => b.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void selectBrand(String brand) {
    selectedBrand.value = brand;
    searchModelController.clear();
    if (brandVehicles.containsKey(brand)) {
      final models = List<VehicleModel>.from(brandVehicles[brand]);
      selectedVehicleList.value = models;
      filteredModels.value = models;
    } else {
      selectedVehicleList.clear();
      filteredModels.clear();
    }
  }

  void filterModels(String query) {
    if (query.isEmpty) {
      filteredModels.value = List<VehicleModel>.from(selectedVehicleList);
    } else {
      filteredModels.value = selectedVehicleList
          .where((m) =>
              m.modelName.toLowerCase().contains(query.toLowerCase()) ||
              m.brand.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void selectVehicle(VehicleModel model) {
    selectedVehicle.value = model;
    isVisible.value = true;
    _validateForm();
  }

  Future<void> onVehicleSubmit() async {
    if (isLoading) return;
    if (selectedVehicle.value.id == '-1' || selectedVehicle.value.id.isEmpty) {
      showError('Please select a vehicle model');
      return;
    }
    if (numEditingController.text.trim().isEmpty) {
      showError('Please enter your vehicle registration number');
      return;
    }
    isLoading = true;
    showLoading('Adding vehicle...');
    bool isSuccess = await CommonFunctions().addEvToUser(
      vehicleId: selectedVehicle.value.id,
      regNumber: numEditingController.text.trim(),
      defaultVehicle: isDefaultVehicle.value,
    );
    if (isSuccess && isDefaultVehicle.value) {
      await CommonFunctions().setDefaultVehicle(
        regNumber: numEditingController.text.trim(),
        vehicleId: selectedVehicle.value.id,
      );
      await CommonFunctions().getUserProfile();
    }
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

  void getSearchedVehicles() {
    List<VehicleModel> results = [];
    final q = searchTextFieldcontroller.text.toLowerCase();
    brandVehicles.forEach((key, value) {
      if (value is List) {
        for (var v in value) {
          if (v is VehicleModel) {
            if (v.brand.toLowerCase().contains(q) ||
                v.modelName.toLowerCase().contains(q)) {
              results.add(v);
            }
          }
        }
      }
    });
    vehicle_list.value = results;
  }
}

