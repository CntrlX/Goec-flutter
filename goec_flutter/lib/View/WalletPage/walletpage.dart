import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Controller/walletPage_controller.dart';
import '../../Model/orderModel.dart';
import '../../Singletones/app_data.dart';
import '../../Singletones/dialogs.dart';
import '../../constants.dart';
import 'topup_page.dart';
import 'wallet_filter_sheet.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with AutomaticKeepAliveClientMixin {
  final WalletPageController controller = Get.find<WalletPageController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: RefreshIndicator(
              displacement: 40,
              backgroundColor: Colors.white,
              color: kBrandPrimaryBlue,
              onRefresh: () async => await controller.onReload(),
              child: CustomScrollView(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Top Summary Section
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF6F8FA),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        children: [
                          _buildBalanceCard(),
                          SizedBox(height: 14.h),
                          _buildTopUpButton(),
                        ],
                      ),
                    ),
                  ),

                  // Recent Transactions Header & Sheet Handle
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: 10.h,
                        left: 16.w,
                        right: 16.w,
                        bottom: 8.h,
                      ),
                      child: Column(
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 44.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1D5DB),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          // Section Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Recent Transactions",
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF121D31),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => showWalletFilterSheet(context),
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Obx(() {
                                    final bool hasFilter =
                                        controller.hasActiveFilter.value ||
                                            controller.startDate.text.isNotEmpty ||
                                            controller.endDate.text.isNotEmpty ||
                                            controller.payment_mode.isNotEmpty ||
                                            controller.payment_status.isNotEmpty;

                                    return SvgPicture.asset(
                                      hasFilter
                                          ? 'assets/svg/wallet_filter_active.svg'
                                          : 'assets/svg/wallet_filter.svg',
                                      width: 22.w,
                                      height: 22.w,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(
                                        Icons.filter_list_rounded,
                                        size: 22.sp,
                                        color: const Color(0xFF121D31),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),

                  // Transactions List / Empty State
                  Obx(() {
                    final items = controller.modelList;
                    final loadingMore = controller.isLoadingMore.value;
                    final hasMore = controller.hasMore.value;

                    if (items.isEmpty && !controller.isInitialLoading.value) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= items.length) {
                            return Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              alignment: Alignment.center,
                              child: loadingMore
                                  ? SizedBox(
                                      width: 24.w,
                                      height: 24.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: kBrandPrimaryBlue,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            );
                          }

                          final model = items[index];
                          final isLast = index == items.length - 1;

                          return Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Dialogs().wallet_transaction_popup(
                                      model: model,
                                      index: index,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: _buildTransactionItem(model),
                                ),
                                if (!isLast)
                                  const Divider(
                                    color: Color(0xFFF1F5F9),
                                    height: 1,
                                    thickness: 1,
                                  ),
                              ],
                            ),
                          );
                        },
                        childCount:
                            items.length + ((hasMore || loadingMore) ? 1 : 0),
                      ),
                    );
                  }),

                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      height: 32.h,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kBrandPrimaryBlue,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 10.h,
              bottom: 14.h,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Text(
                  "Wallet",
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      height: 138.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Circle 1 (Outer soft blue ellipse touching edges)
          Positioned(
            right: -24.w,
            top: -24.h,
            bottom: -24.h,
            width: 190.w,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F6FE),
              ),
            ),
          ),

          // Background Circle 2 (Inner soft blue circle)
          Positioned(
            right: -6.w,
            top: -6.h,
            bottom: -6.h,
            width: 152.w,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE4EFFF),
              ),
            ),
          ),

          // Right 3D Wallet Illustration
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/wallet_card_3d.png',
              width: 162.w,
              fit: BoxFit.contain,
            ),
          ),

          // Left Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Available Balance",
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF68768E),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/wallet_gold_coin.png',
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF59E0B),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Obx(
                      () => Text(
                        _formatBalance(
                          appData.userModel.value.balanceAmount,
                        ),
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF121D31),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  "₹ 1 = 1 Coins",
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8C97A7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () {
          Get.to(() => const PopUpPage());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kBrandPrimaryBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8.w),
            Text(
              "Top-Up Wallet",
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/wallet_empty_transactions.png',
            width: 220.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 16.h),
          Text(
            "No Transactions Yet",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Your wallet transactions will appear here after you top up or make a charging payment.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF68768E),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(OrderModel model) {
    final bool isDebit =
        model.type.toLowerCase().contains('deduction') ||
        model.type.toLowerCase().contains('charging');

    final String title = isDebit ? "Charging Payment" : "Wallet Top-Up";

    final String subDetail = model.pgOrderId.isNotEmpty
        ? model.pgOrderId
        : (isDebit ? "Charging Session" : "Added via Online Payment");

    final String formattedDate = _formatDate(model.createdAt);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge - 44x44 rounded squircle
          SizedBox(
            width: 44.w,
            height: 44.w,
            child: isDebit
                ? SvgPicture.asset(
                    'assets/svg/wallet_charging_badge.svg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.bolt_rounded,
                        color: kBrandPrimaryBlue,
                        size: 24.sp,
                      ),
                    ),
                  )
                : SvgPicture.asset(
                    'assets/svg/wallet_topup_badge.svg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add_rounded,
                        color: Color(0xFF03E8BE),
                        size: 24,
                      ),
                    ),
                  ),
          ),
          SizedBox(width: 14.w),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF121D31),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subDetail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF68768E),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8C97A7),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // Amount Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isDebit ? '-' : '+'} ${model.amount.toStringAsFixed(2)} Coins",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isDebit
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                ),
              ),
              if (model.status.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  model.status.capitalizeFirst ?? model.status,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: model.status.toLowerCase() == 'success'
                        ? const Color(0xFF16A34A)
                        : (model.status.toLowerCase() == 'pending'
                            ? const Color(0xFFD97706)
                            : const Color(0xFF8C97A7)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatBalance(double amount) {
    final formatter = NumberFormat("#,##,##0.00", "en_IN");
    return formatter.format(amount);
  }

  String _formatDate(String rawDate) {
    if (rawDate.trim().isEmpty) return '';
    try {
      DateTime? dt;
      // Try standard ISO 8601
      dt = DateTime.tryParse(rawDate)?.toLocal();

      // Try other common formats if tryParse failed
      if (dt == null) {
        final formats = [
          'dd-MM-yyyy hh:mma',
          'dd-MM-yyyy HH:mm:ss',
          'dd-MM-yyyy hh:mm a',
          'dd/MM/yyyy HH:mm:ss',
          'dd/MM/yyyy hh:mm a',
          'dd/MM/yyyy',
          'dd-MM-yyyy',
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-ddTHH:mm:ss.SSSZ',
          'yyyy-MM-ddTHH:mm:ss',
        ];
        for (final f in formats) {
          try {
            dt = DateFormat(f).parseLoose(rawDate).toLocal();
            break;
          } catch (_) {}
        }
      }

      if (dt != null) {
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      }
    } catch (_) {}
    return rawDate;
  }
}
