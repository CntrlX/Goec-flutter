import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../Utils/toastUtils.dart';
import '../Singletones/app_data.dart';
import '../Singletones/common_functions.dart';

class RfidPageController extends GetxController {
  RxList carouselText = [
    "GOEC super charging station Provides High ROI",
    "operate your charging station from anywhere in the world without human intervention.",
    "For a future-focused business, capitalize on the growing EV market."
  ].obs;
  RxList carouselImage = [
    "assets/images/carouselOne.png",
    "assets/images/carouselTwo.png",
    "assets/images/carouselThree.png",
  ].obs;
  
  RxDouble currentIndex = 0.0.obs;
  RxInt rfid_price = 0.obs;
  RxList rfid_list = RxList();

  // Delivery form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Prefill user information if available
    final user = appData.userModel.value;
    nameController.text = user.name.isNotEmpty ? user.name : '';
    phoneController.text = user.username.isNotEmpty ? user.username : '';
    getRFIDPriceAndUserRFID();
  }

  getRFIDPriceAndUserRFID() async {
    showLoading(kLoading);
    rfid_price.value = await CommonFunctions().getRFIDPrice();
    rfid_list.value = appData.userModel.value.rfidTag;
    hideLoading();
  }

  orderRFID() async {
    final int price = rfid_price.value > 0 ? rfid_price.value : 370;
    showLoading(kLoading);
    String order_id = await CommonFunctions().getOrderIdRazorpay(price);
    hideLoading();
    
    if (order_id.isNotEmpty) {
      CommonFunctions().openRazorPay(
        amount: price,
        order_id: order_id,
        descirption: 'RFID payment',
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    CommonFunctions().closeRazorPay();
    super.onClose();
  }
}
