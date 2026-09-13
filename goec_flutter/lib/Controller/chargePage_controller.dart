import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freelancer_app/Model/chargeTransactionModel.dart';
import 'package:freelancer_app/Model/paginated_result.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';
import 'package:freelancer_app/Singletones/dialogs.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChargeScreenController extends GetxController {
  static const int pageSize = 10;

  final TextEditingController startDate = TextEditingController();
  final TextEditingController endDate = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxInt IsTabIndex = 0.obs;
  final RxList<ChargeTransactionModel> model_list =
      <ChargeTransactionModel>[].obs;
  final RxDouble boxHeight = (0.0).obs;

  final RxBool isInitialLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool hasActiveFilter = false.obs;

  int _page = 0;
  int _totalCount = 0;
  int _fetchedCount = 0;
  bool _filterLock = false;

  bool get _isBusy => isInitialLoading.value || isLoadingMore.value;

  /// Backward-compatible alias used by older UI checks.
  bool get isLoading => _isBusy;

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

  Future<PaginatedResult<ChargeTransactionModel>> _fetchPage(int pageNo) {
    final dates = _formattedDateRange();
    return CommonFunctions().getChargeTransactionsPage(
      pageNo: pageNo,
      startDate: dates.start,
      endDate: dates.end,
    );
  }

  void _applyPageMeta(
    PaginatedResult<ChargeTransactionModel> page, {
    required bool reset,
  }) {
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

  void _updateFilterStatus() {
    hasActiveFilter.value =
        startDate.text.isNotEmpty || endDate.text.isNotEmpty;
  }

  Future<void> refreshTransactions({bool showOverlay = false}) async {
    if (isInitialLoading.value) return;

    isInitialLoading.value = true;
    if (showOverlay) showLoading(kLoading);

    try {
      final page = await _fetchPage(1);
      _applyPageMeta(page, reset: true);
      model_list
        ..clear()
        ..addAll(page.items);
      setBoxHeight();
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
        model_list.addAll(page.items);
        setBoxHeight();
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> getChargeTransactions() =>
      refreshTransactions(showOverlay: true);

  Future<void> onReload() async {
    await refreshTransactions(showOverlay: false);
  }

  Future<void> getBooking(ChargeTransactionModel model) async {
    Dialogs().charge_transaction_popup(model: model);
  }

  void setBoxHeight() {
    boxHeight.value =
        size.height * .28 + (size.height * .11) * (model_list.length);
  }

  Future<void> clearFilter() async {
    startDate.clear();
    endDate.clear();
    _updateFilterStatus();
    await refreshTransactions(showOverlay: true);
  }

  Future<void> applyFilter() async {
    if (_filterLock) return;
    if (startDate.text.isEmpty || endDate.text.isEmpty) {
      EasyLoading.showInfo('Please select Start and End date.');
      return;
    }
    _filterLock = true;
    try {
      _updateFilterStatus();
      await refreshTransactions(showOverlay: true);
      Get.back();
    } finally {
      _filterLock = false;
    }
  }
}
