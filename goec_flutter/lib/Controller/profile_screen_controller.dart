import 'package:freelancer_app/Singletones/app_data.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';
import 'package:freelancer_app/Utils/SharedPreferenceUtils.dart';
import 'package:freelancer_app/Utils/firebase_notifications.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';
import '../Utils/routes.dart';

class ProfileScreenController extends GetxController {
  RxInt reload = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getProfileDetails();
  }

  getProfileDetails() async {
    showLoading(kLoading);
    await CommonFunctions().getUserProfile();
    hideLoading();
  }

  deleteProfile() async {
    kLog(appData.userModel.value.id.toString());
    showLoading(kLoading);
    bool res = await CommonFunctions().deleteUser();
    hideLoading();
    if (res) {
      await clearData();
      FireBaseNotification().unsubscribeFirebaseNotification();
      appData.token = '';
      appData.userModel.value = kUserModel;
      appData.userModel.value.username = '';
      showSuccess('Account deleted successfully!');
      Get.offAllNamed(Routes.loginpageRoute);
    } else {
      showError('Failed to delete account!');
    }
  }

  logout() async {
    showLoading(kLoading);
    await clearData();
    FireBaseNotification().unsubscribeFirebaseNotification();
    appData.token = '';
    appData.userModel.value = kUserModel;
    appData.userModel.value.username = '';
    hideLoading();
    Get.offAllNamed(Routes.loginpageRoute);
  }
}
