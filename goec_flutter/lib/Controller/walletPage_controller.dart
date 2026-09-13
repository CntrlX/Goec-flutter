import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freelancer_app/Model/orderModel.dart';
import 'package:freelancer_app/Model/paginated_result.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:validators/validators.dart';

class WalletPageController extends GetxController {
  static const int pageSize = 10;

  static const String adminTopUp = 'admin topup';
  static const String walletTopUp = 'wallet top-up';
  static const String chargingDeduction = 'charging deduction';

  final TextEditingController amountController = TextEditingController();
  final TextEditingController startDate = TextEditingController();
  final TextEditingController endDate = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxBool enablemailTextfield = false.obs;
  final RxList<OrderModel> modelList = <OrderModel>[].obs;
  final RxList<String> payment_mode = <String>[].obs;
  final RxList<String> payment_status = <String>[].obs;
  final RxInt reload = 0.obs;

  final RxBool isInitialLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  int _page = 0;
  int _totalCount = 0;
  int _fetchedCount = 0;
  bool _filterLock = false;

  bool get _isBusy => isInitialLoading.value || isLoadingMore.value;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    refreshTransactions(showOverlay: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    amountController.dispose();
    startDate.dispose();
    endDate.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients || _isBusy || !hasMore.value) return;
    final position = scrollController.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;

    final threshold = position.maxScrollExtent * 0.85;
    if (position.pixels >= threshold) {
      loadMoreTransactions();
    }
  }

  ({String start, String end}) _formattedDateRange() {
    if (startDate.text.isEmpty || endDate.text.isEmpty) {
      return (start: '', end: '');
    }
    return (
      start: DateFormat('dd-MM-yyyy').format(
        DateFormat('dd/MM/yyyy').parse(startDate.text),
      ),
      end: DateFormat('dd-MM-yyyy').format(
        DateFormat('dd/MM/yyyy').parse(endDate.text),
      ),
    );
  }

  Future<PaginatedResult<OrderModel>> _fetchPage(int pageNo) {
    final dates = _formattedDateRange();
    return CommonFunctions().getWalletTransactionsPage(
      pageNo: pageNo,
      startDate: dates.start,
      endDate: dates.end,
      types: payment_mode.toList(),
      statuses: payment_status.toList(),
    );
  }

  void _applyPageMeta(PaginatedResult<OrderModel> page, {required bool reset}) {
    if (reset) {
      _fetchedCount = 0;
    }
    _page = page.pageNo;
    _totalCount = page.totalCount;
    _fetchedCount += page.rawCount;
    hasMore.value = PaginatedResult.hasMorePages(
      fetchedSoFar: _fetchedCount,
      totalCount: _totalCount,
    );
  }

  Future<void> refreshTransactions({bool showOverlay = false}) async {
    if (isInitialLoading.value) return;

    isInitialLoading.value = true;
    if (showOverlay) showLoading(kLoading);

    try {
      final page = await _fetchPage(1);
      _applyPageMeta(page, reset: true);
      modelList
        ..clear()
        ..addAll(page.items);
    } finally {
      isInitialLoading.value = false;
      if (showOverlay) hideLoading();
    }
  }

  Future<void> loadMoreTransactions() async {
    if (_isBusy || !hasMore.value) return;

    isLoadingMore.value = true;
    try {
      final page = await _fetchPage(_page + 1);
      _applyPageMeta(page, reset: false);
      if (page.items.isNotEmpty) {
        modelList.addAll(page.items);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> getWalletTransactions() =>
      refreshTransactions(showOverlay: true);

  Future<void> onReload() async {
    await CommonFunctions().getUserProfile();
    await refreshTransactions(showOverlay: false);
  }

  Future<void> orderTopUp() async {
    if (!isNumeric(amountController.text)) return;
    showLoading(kLoading);
    final orderId = await CommonFunctions()
        .getOrderIdRazorpay(int.parse(amountController.text));
    hideLoading();
    CommonFunctions().openRazorPay(
      amount: int.parse(amountController.text),
      order_id: orderId,
      descirption: 'Top up your account',
    );
  }

  Future<void> getUserProfile() async {
    showLoading('Checking Balance...');
    await CommonFunctions().getUserProfile();
    hideLoading();
  }

  void addRemoveOptionToMode(String value) {
    if (payment_mode.contains(value)) {
      payment_mode.remove(value);
    } else {
      payment_mode.add(value);
    }
  }

  void addRemoveOptionToStatus(String value) {
    if (payment_status.contains(value)) {
      payment_status.remove(value);
    } else {
      payment_status.add(value);
    }
  }

  Future<void> clearFilter() async {
    startDate.clear();
    endDate.clear();
    payment_mode.clear();
    payment_status.clear();
    await refreshTransactions(showOverlay: true);
  }

  Future<void> applyFilter() async {
    if (_filterLock) return;
    if (startDate.text.isEmpty && endDate.text.isNotEmpty) {
      EasyLoading.showInfo('Please select Start Date');
      return;
    }
    if (startDate.text.isNotEmpty && endDate.text.isEmpty) {
      EasyLoading.showInfo('Please select End Date');
      return;
    }

    _filterLock = true;
    try {
      await refreshTransactions(showOverlay: true);
      Get.back();
    } finally {
      _filterLock = false;
    }
  }
}
