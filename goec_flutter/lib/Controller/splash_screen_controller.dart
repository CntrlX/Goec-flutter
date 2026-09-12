import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';

import '../Singletones/app_data.dart';
import '../Singletones/common_functions.dart';
import '../Utils/SharedPreferenceUtils.dart';
import '../Utils/routes.dart';

class SplashScreenController extends GetxController {
  RxInt reload = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // 2-second splash delay for smooth visual transition
      await Future.delayed(const Duration(seconds: 2));

      appData.token = await getString('token') ?? '';
      appData.userModel.value.username = await getString('username') ?? '';

      kLog('username: ${appData.userModel.value.username}');
      kLog('token: ${appData.token}');

      if (appData.token.isEmpty || appData.userModel.value.username.isEmpty) {
        Get.offAllNamed(Routes.loginpageRoute);
        return;
      }

      var res = await CommonFunctions()
          .getUserProfile()
          .timeout(const Duration(seconds: 4), onTimeout: () => kUserModel);

      if (res.username.isEmpty) {
        Get.offAllNamed(Routes.loginpageRoute);
      } else {
        Get.offAllNamed(Routes.homePageRoute);
      }
    } catch (e) {
      kLog('SplashScreen navigation error: $e');
      Get.offAllNamed(Routes.loginpageRoute);
    }
  }
}
