import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Controller/walletPage_controller.dart';
import '../../Singletones/app_data.dart';
import '../../constants.dart';
import '../Widgets/custom_input_field.dart';

class PopUpPage extends StatefulWidget {
  const PopUpPage({super.key});

  @override
  State<PopUpPage> createState() => _PopUpPageState();
}

class _PopUpPageState extends State<PopUpPage> {
  final WalletPageController controller = Get.find<WalletPageController>();

  final List<int> _quickAmounts = [200, 500, 1000, 2000, 5000, 10000];

  @override
  void initState() {
    super.initState();
    controller.amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    controller.amountController.removeListener(_onAmountChanged);
    super.dispose();
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  int? get _currentSelectedAmount {
    final text = controller.amountController.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  bool get _isValidAmount {
    final amount = _currentSelectedAmount;
    return amount != null && amount > 0;
  }

  void _selectAmount(int amount) {
    controller.amountController.text = amount.toString();
    appData.rechargeAmount = amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Summary & Info Banner Section (Grey Background)
                  Container(
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
                        _buildInfoBanner(),
                      ],
                    ),
                  ),

                  // Input & Quick Select Section (White Background)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enter Amount Title
                        Text(
                          "Enter Amount",
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF121D31),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Amount Input using reusable CustomInputField
                        CustomInputField(
                          controller: controller.amountController,
                          hintText: "Enter amount in Coins",
                          prefixWidget: Text(
                            "₹",
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF121D31),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (val) {
                            appData.rechargeAmount = val;
                          },
                        ),

                        SizedBox(height: 24.h),

                        // Quick Select Title
                        Text(
                          "Quick Select",
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0E1726),
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // Quick Select Chips
                        _buildQuickSelectGrid(),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sticky Button Bar (Shown only when valid amount is entered/selected)
          if (_isValidAmount) _buildBottomBar(context),
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
                  "Top-Up Wallet",
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

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE6EAEF),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Minimum top-up box
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.local_offer_rounded,
              color: kBrandPrimaryBlue,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Minimum top-up\namount",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFA0AABD),
                  height: 1.25,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "200 Coins",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: kBrandPrimaryBlue,
                ),
              ),
            ],
          ),

          // Vertical Divider
          Container(
            height: 44.h,
            width: 1,
            color: const Color(0xFFE6EAEF),
            margin: EdgeInsets.symmetric(horizontal: 14.w),
          ),

          // Right Secure & Instant box
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15.sp,
                      color: kBrandPrimaryBlue,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "Secure & Instant",
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF121D31),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  "Coins will be added to your wallet immediately after payment.",
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFA0AABD),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectGrid() {
    final currentAmount = _currentSelectedAmount;

    return Column(
      children: [
        // Row 1: 200, 500, 1000
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) SizedBox(width: 10.w),
              Expanded(
                child: _buildQuickChip(
                  amount: _quickAmounts[i],
                  isSelected: currentAmount == _quickAmounts[i],
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12.h),
        // Row 2: 2000, 5000, 10000
        Row(
          children: [
            for (int i = 3; i < 6; i++) ...[
              if (i > 3) SizedBox(width: 10.w),
              Expanded(
                child: _buildQuickChip(
                  amount: _quickAmounts[i],
                  isSelected: currentAmount == _quickAmounts[i],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQuickChip({
    required int amount,
    required bool isSelected,
  }) {
    final formattedAmount = NumberFormat("#,##,###", "en_IN").format(amount);

    return GestureDetector(
      onTap: () => _selectAmount(amount),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 45.h,
        decoration: BoxDecoration(
          color: isSelected ? kBrandPrimaryBlue : const Color(0xFFEAF3FD),
          borderRadius: BorderRadius.circular(100.r),
        ),
        alignment: Alignment.center,
        child: Text(
          "$formattedAmount Coins",
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : kBrandPrimaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFEBEFEA),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        14.h,
        20.w,
        14.h + bottomInset,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: () {
            controller.orderTopUp();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrandPrimaryBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
          child: Text(
            "Add Money",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _formatBalance(double amount) {
    final formatter = NumberFormat("#,##,##0.00", "en_IN");
    return formatter.format(amount);
  }
}
