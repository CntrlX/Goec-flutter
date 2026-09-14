import 'package:freelancer_app/Model/favoriteModel.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';
import '../Utils/routes.dart';

class FavouritePageController extends GetxController {
  RxList<FavoriteModel> model_list = RxList();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getFavorites();
  }

  Future<void> getFavorites({bool showLoader = true}) async {
    if (showLoader) {
      isLoading.value = true;
      showLoading(kLoading);
    }
    try {
      final list = await CommonFunctions().getFavorites();
      model_list.value = list;
    } catch (_) {
    } finally {
      if (showLoader) {
        isLoading.value = false;
        hideLoading();
      }
    }
  }

  gotoStationDetailsPage(String stationId) async {
    Get.toNamed(Routes.calistaCafePageRoute, arguments: stationId);
  }

  changeFavoriteStatus(String stationId) async {
    showLoading(kLoading);
    bool res = await CommonFunctions()
        .changeFavorite(stationId: stationId, makeFavorite: false);
    if (res) {
      model_list.removeWhere((item) => item.id == stationId);
    }
    hideLoading();
  }
}
