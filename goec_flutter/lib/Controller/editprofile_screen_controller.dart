import 'dart:io';
import 'package:get/get.dart';
import '../Singletones/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/Singletones/app_data.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';

class EditProfileScreenController extends GetxController {
  RxString country =
      appData.userModel.value.username.contains('+977') ? "977".obs : '91'.obs;
  RxString textfield = "".obs;
  RxInt reload = 0.obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phnNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController stateNameController = TextEditingController();
  final TextEditingController countryNameController = TextEditingController();
  final TextEditingController gstNoController = TextEditingController();

  @override
  void onInit() {
    // / implement onInit
    super.onInit();
    nameController.text = appData.userModel.value.name;
    emailController.text = appData.userModel.value.email;
    phnNumberController.text = appData.userModel.value.username
        .replaceAll('+91', '')
        .replaceAll('+977', '')
        .trim();
  }

  updateUserProfile() async {
    showLoading('Updating profile...');
    bool res = await CommonFunctions().putUserProfile(
      nameController.text,
      emailController.text,
      '+${country.value}${phnNumberController.text}',
    );
    hideLoading();
    if (res) {
      //showSuccess('Successfully updated profile!');
      await CommonFunctions().getUserProfile();
      Get.back();
      saveSnack('Profile Details Updated');
    }
  }

  pickAndUploadImage() async {
    ImagePicker _picker = ImagePicker();
    XFile? xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      //upload the file
      File file = File(xfile.path);
      showLoading('Uploading...');
      bool isUploaded = await CommonFunctions().putProfileImage(file);
      hideLoading();
      if (isUploaded) await CommonFunctions().getUserProfile();
    } else {
      showError('No image choosed!');
    }
  }
}
