import '../constants.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Utils/toastUtils.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import '../Singletones/common_functions.dart';
import 'package:freelancer_app/Model/orderModel.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class WalletPageController extends GetxController {
  RxBool enablemailTextfield = false.obs;
  final TextEditingController amountController = TextEditingController();
  RxList<OrderModel> modelList = RxList();
  ScrollController scrollController = ScrollController();
  // int page = 0, size = 10, totalElements = 0;
  RxInt reload = 0.obs;
  bool isLoading = false;
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  RxList<String> payment_mode = RxList();
  RxList<String> payment_status = RxList();
  bool lock = false;
  String adminTopUp = 'AdminTopUp', walletTopUp = 'wallet top-up';

  @override
  void onInit() {
    // / implement onInit
    super.onInit();
    getWalletTransactions();
    // _scrollListen();
  }

  onClose() {
    super.onClose();
    scrollController.dispose();
  }

//   _scrollListen() {
//     scrollController.addListener(() async {
// // nextPageTrigger will have a value equivalent to 80% of the list size.
//       var nextPageTrigger = 0.99 * scrollController.position.maxScrollExtent;

// // _scrollController fetches the next paginated data when the current postion of the user on the screen has surpassed
//       if (modelList.length < totalElements &&
//           !isLoading &&
//           scrollController.position.pixels > nextPageTrigger) {
//         // loading = true;
//         // fetchData();
//         page++;
//         isLoading = true;
//         await getWalletTransactions();
//         isLoading = false;
//       }
//     });
//   }

  getWalletTransactions() async {
    showLoading(kLoading);
    String start = '';
    String end = '';
    if (startDate.text.isNotEmpty && endDate.text.isNotEmpty) {
      start = DateFormat('dd-MM-yyyy')
          .format(DateFormat('dd/MM/yyyy').parse(startDate.text));
      end = DateFormat('dd-MM-yyyy')
          .format(DateFormat('dd/MM/yyyy').parse(endDate.text));
    }

    var res = await CommonFunctions()
        .getWalletTransactions(start, end, payment_mode, payment_status);
    hideLoading();
    // if (isVerifyPayment)
    //   modelList.value = res;
    // else
    modelList.clear();
    modelList.addAll(res);
  }

  orderTopUp() async {
    if (!isNumeric(amountController.text)) return;
    showLoading(kLoading);
    String order_id = await CommonFunctions()
        .getOrderIdRazorpay(int.parse(amountController.text));
    hideLoading();
    CommonFunctions().openRazorPay(
        amount: int.parse(amountController.text),
        order_id: order_id,
        descirption: 'Top up your account');
  }

  // verifyPayment(String transactionId, String orderId, int index) async {
  //   kLog('value');
  //   showLoading('Verifying payment...\n$kLoading');
  //   OrderModel res = await CommonFunctions().savePaymentRazorpay(
  //       PaymentSuccessResponse('', '', ''),
  //       transactionId: transactionId,
  //       orderId: orderId);
  //   hideLoading();
  //   if (res.transactionId != '-1') {
  //     Get.back();
  //     // showSuccess('Successfully verified!');
  //     modelList[index] = res;
  //     getUserProfile();
  //   } else {
  //     showError('Failed to verify payment!');
  //   }
  // }

  getUserProfile() async {
    showLoading('Checking Balance...');
    await CommonFunctions().getUserProfile();
    hideLoading();
  }

  addRemoveOptionToMode(String value) {
    if (payment_mode.contains(value))
      payment_mode.remove(value);
    else
      payment_mode.add(value);
    update();
  }

  addRemoveOptionToStatus(String value) {
    if (payment_status.contains(value))
      payment_status.remove(value);
    else
      payment_status.add(value);
  }

  clearFilter() async {
    startDate.clear();
    endDate.clear();
    payment_mode.clear();
    payment_status.clear();
    await getWalletTransactions();
  }

  applyFilter() async {
    if (lock) return;
    if (startDate.text.isEmpty && startDate.text.isNotEmpty) {
      EasyLoading.showInfo('Please select Start Date');
      return;
    } else if (startDate.text.isNotEmpty && startDate.text.isEmpty) {
      EasyLoading.showInfo('Please select Start Date');
      return;
    }

    lock = true;
    // page = 0;
    // totalElements = 0;
    modelList.clear();
    await getWalletTransactions();

    Get.back();
    lock = false;
  }

  onReload() async {
    await CommonFunctions().getUserProfile();
    String start = '';
    String end = '';
    if (startDate.text.isNotEmpty && endDate.text.isNotEmpty) {
      start = DateFormat('dd-MM-yyyy').format(
        DateFormat('dd/MM/yyyy').parse(startDate.text),
      );
      end = DateFormat('dd-MM-yyyy').format(
        DateFormat('dd/MM/yyyy').parse(endDate.text),
      );
    }
    var res = await CommonFunctions().getWalletTransactions(
      start,
      end,
      payment_mode,
      payment_status,
    );
    modelList.clear();
    modelList.addAll(res);
  }
}
