import 'dart:developer';
import '../Model/vehicleModel.dart';
import 'package:get/state_manager.dart';
import 'package:freelancer_app/constants.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';
import 'package:freelancer_app/Singletones/app_data.dart';

class MyVehiclesScreenController extends GetxController {
  RxInt reload = 0.obs;
  RxList<VehicleModel> myVehicleList = RxList();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    getMyVehicles();
    super.onInit();
  }

  Future<void> getMyVehicles() async {
    showLoading(kLoading);
    isLoading.value = true;
    try {
      await CommonFunctions().getUserProfile();
      final defaultReg = appData.userModel.value.defaultVehicle.evRegNumber.trim().toLowerCase();
      final defaultId = appData.userModel.value.defaultVehicle.id;

      final vehicles = await CommonFunctions().getUserEvs();
      List<VehicleModel> processed = [];

      for (var v in vehicles) {
        bool isDefault = v.defaultVehicle ||
            (defaultReg.isNotEmpty && v.evRegNumber.trim().toLowerCase() == defaultReg) ||
            (defaultId != '-1' && defaultId.isNotEmpty && v.id == defaultId) ||
            vehicles.length == 1;

        processed.add(VehicleModel(
          id: v.id,
          icon: v.icon,
          brand: v.brand,
          modelName: v.modelName,
          evRegNumber: v.evRegNumber,
          compactable_port: v.compactable_port,
          defaultVehicle: isDefault,
        ));
      }

      int index = processed.indexWhere((item) => item.defaultVehicle == true);
      if (index != -1) {
        VehicleModel yItem = processed.removeAt(index);
        processed.insert(0, yItem);
      }
      myVehicleList.value = processed;
    } finally {
      isLoading.value = false;
      hideLoading();
    }
  }

  Future<void> setAsDefaultVehicle(VehicleModel model) async {
    if (model.defaultVehicle) return;
    showLoading(kLoading);
    log(model.id.toString());
    bool res = await CommonFunctions().setDefaultVehicle(
      regNumber: model.evRegNumber,
      vehicleId: model.id,
    );

    hideLoading();
    if (res) {
      await CommonFunctions().getUserProfile();
      await getMyVehicles();
      showSuccess('Default Vehicle Updated Successfully!');
    } else {
      showError('Failed to update default vehicle!\n Try again later');
    }
  }

  Future<void> deleteVehicle(VehicleModel model) async {
    showLoading(kLoading);
    bool res = await CommonFunctions().deleteEvOfUser(model.evRegNumber);
    hideLoading();
    if (res) {
      await getMyVehicles();
      await CommonFunctions().getUserProfile();
      showSuccess('Vehicle deleted successfully');
    } else {
      showError('Failed to delete vehicle. Try again later');
    }
  }
}
