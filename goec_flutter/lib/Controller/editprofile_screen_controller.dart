import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../Singletones/app_data.dart';
import '../Singletones/common_functions.dart';
import '../Singletones/dialogs.dart';
import '../Utils/toastUtils.dart';

class EditProfileScreenController extends GetxController {
  RxString country = '91'.obs;
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
    super.onInit();
    populateUserData();
  }

  void populateUserData() {
    nameController.text = appData.userModel.value.name;
    emailController.text = appData.userModel.value.email;

    final rawPhone = appData.userModel.value.username.trim();
    if (rawPhone.startsWith('+977')) {
      country.value = '977';
      phnNumberController.text = rawPhone.substring(4).trim();
    } else if (rawPhone.startsWith('+91')) {
      country.value = '91';
      phnNumberController.text = rawPhone.substring(3).trim();
    } else if (rawPhone.startsWith('977')) {
      country.value = '977';
      phnNumberController.text = rawPhone.substring(3).trim();
    } else if (rawPhone.startsWith('91')) {
      country.value = '91';
      phnNumberController.text = rawPhone.substring(2).trim();
    } else {
      phnNumberController.text = rawPhone.replaceAll('+', '').trim();
    }
  }

  Future<void> updateUserProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      showError('Please enter your name');
      return;
    }
    if (email.isEmpty) {
      showError('Please enter your email');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      showError('Please enter a valid email address');
      return;
    }

    showLoading('Updating profile...');
    bool res = await CommonFunctions().putUserNameEmail(name, email);
    hideLoading();

    if (res) {
      await CommonFunctions().getUserProfile();
      Get.back();
      saveSnack('Profile Details Updated');
    }
  }

  Future<void> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xfile != null) {
      File file = File(xfile.path);
      showLoading('Uploading image...');
      bool isUploaded = await CommonFunctions().putProfileImage(file);
      hideLoading();
      if (isUploaded) {
        await CommonFunctions().getUserProfile();
        saveSnack('Profile picture updated');
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phnNumberController.dispose();
    emailController.dispose();
    companyNameController.dispose();
    cityNameController.dispose();
    postalCodeController.dispose();
    stateNameController.dispose();
    countryNameController.dispose();
    gstNoController.dispose();
    super.onClose();
  }
}
