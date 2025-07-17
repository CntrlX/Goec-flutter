import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Singletones/app_data.dart';
import '../Singletones/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:freelancer_app/constants.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freelancer_app/Model/chargeTransactionModel.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';

class ChargeScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  RxInt IsTabIndex = 0.obs;
  bool isLoading = false;

  // late TabController tabController;
  RxList<ChargeTransactionModel> model_list = RxList();
  RxDouble boxHeight = (0.0).obs;
  ScrollController scrollController = ScrollController();
  int page = 1;
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  bool lock = false;

  @override
  void onInit() {
    // / implement onInit
    super.onInit();
    getChargeTransactions();
    _scrollListen();
  }

  @override
  void onClose() {
    // / implement onClose
    super.onClose();
    scrollController.dispose();
  }

  _scrollListen() {
    scrollController.addListener(() async {
      var nextPageTrigger = 0.99 * scrollController.position.maxScrollExtent;
      if (model_list.length < appData.chargingHistoryCount &&
          !isLoading &&
          scrollController.position.pixels > nextPageTrigger) {
        page++;
        isLoading = true;
        await loadMore();
        isLoading = false;
      }
    });
  }

  onReload() async {
    var res = await CommonFunctions().getChargeTransactions('1', '', '');
    model_list.clear();
    model_list.addAll(res);
    page = 1;
  }

  getChargeTransactions() async {
    showLoading(kLoading);
    page = 1;
    String start = '';
    String end = '';
    if (startDate.text.isNotEmpty && endDate.text.isNotEmpty) {
      start = DateFormat('dd-MM-yyyy')
          .format(DateFormat('dd/MM/yyyy').parse(startDate.text));
      end = DateFormat('dd-MM-yyyy')
          .format(DateFormat('dd/MM/yyyy').parse(endDate.text));
    }
    var res =
        await CommonFunctions().getChargeTransactions('$page', start, end);
    model_list.clear();
    hideLoading();
    model_list.addAll(res);
  }

  loadMore() async {
    showLoading(kLoading);
    String start = '';
    String end = '';
    if (startDate.text.isNotEmpty && endDate.text.isNotEmpty) {
      start = DateFormat('dd-MM-yyyy')
          .format(DateFormat('dd/MM/yyyy').parse(startDate.text));
      end = DateFormat('dd-MM-yyyy')
          .format(DateFormat('dd/MM/yyyy').parse(endDate.text));
    }
    var res =
        await CommonFunctions().getChargeTransactions('$page', start, end);
    hideLoading();
    model_list.addAll(res);
  }

  getBooking(ChargeTransactionModel model) async {
    Dialogs().charge_transaction_popup(model: model);
    // if (isLoading) return;
    // isLoading = true;
    // showLoading(kLoading);
    // BookingModel model =
    //     await CommonFunctions().getBooking(bookingId: "${bookingId}");
    // hideLoading();

    // if (model.bookingId != -1) {
    //   Dialogs().charge_transaction_popup(
    //       model: model,
    //       stationAddress: stationAddress,
    //       stationName: stationName);
    // }
    // isLoading = false;
  }

  setBoxHeight() {
    boxHeight.value =
        size.height * .28 + (size.height * .11) * (model_list.length);
  }

  clearFilter() async {
    startDate.clear();
    endDate.clear();
    await getChargeTransactions();
  }

  applyFilter() async {
    if (lock) return;
    if (startDate.text.isEmpty || endDate.text.isEmpty) {
      EasyLoading.showInfo('Please select Start and End date.');
      return;
    }
    lock = true;
    await getChargeTransactions();
    Get.back();
    lock = false;
  }
}
