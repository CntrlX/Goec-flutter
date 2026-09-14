import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../Model/orderModel.dart';
import '../../constants.dart';

/// Shows the Wallet Transaction Summary Modal Bottom Sheet matching the charging summary design.
Future<void> showWalletTransactionModalSheet(
  BuildContext context, {
  required OrderModel model,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss transaction summary',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return Stack(
        children: [
          // Blurred & dimmed backdrop
          Positioned.fill(
            child: FadeTransition(
              opacity: curved,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.21),
                  ),
                ),
              ),
            ),
          ),

          // Slide-up modal sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: Material(
                color: Colors.transparent,
                child: WalletTransactionModalContent(model: model),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class WalletTransactionModalContent extends StatelessWidget {
  final OrderModel model;

  const WalletTransactionModalContent({
    super.key,
    required this.model,
  });

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _fullFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static const List<String> _dateParseFormats = [
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

  DateTime? _parseDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    DateTime? dt = DateTime.tryParse(trimmed)?.toLocal();
    if (dt != null) return dt;
    for (final f in _dateParseFormats) {
      try {
        dt = DateFormat(f).parseLoose(trimmed).toLocal();
        return dt;
      } catch (_) {}
    }
    return null;
  }

  bool get _isDebit {
    final t = model.type.toLowerCase();
    return t.contains('charging') ||
        t.contains('deduction') ||
        t.contains('debit');
  }

  String get _title {
    final t = model.type.toLowerCase();
    if (t.contains('top-up') || t.contains('topup')) {
      return 'Wallet Top-up';
    } else if (t.contains('charging') || t.contains('deduction')) {
      return 'Charging Deduction';
    } else if (t.contains('admin')) {
      return 'Admin Top-up';
    }
    return model.type.isNotEmpty ? model.type : 'Wallet Transaction';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final parsedDt = _parseDate(model.createdAt);
    final dateStr = parsedDt != null ? _dateFormat.format(parsedDt) : (model.createdAt.isNotEmpty ? model.createdAt : '--');
    final timeStr = parsedDt != null ? _timeFormat.format(parsedDt) : '--';
    final fullDateStr = parsedDt != null ? _fullFormat.format(parsedDt) : (model.createdAt.isNotEmpty ? model.createdAt : '--');

    final statusLower = model.status.toLowerCase();
    final isSuccess = statusLower == 'success' || statusLower == 'completed';
    final isPending = statusLower == 'pending';

    final statusBg = isSuccess
        ? const Color(0xFFECFDF5)
        : (isPending ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2));
    final statusColor = isSuccess
        ? const Color(0xFF059669)
        : (isPending ? const Color(0xFFD97706) : const Color(0xFFDC2626));
    final statusIcon = isSuccess
        ? Icons.check_circle_rounded
        : (isPending ? Icons.schedule_rounded : Icons.cancel_rounded);
    final statusText = isSuccess
        ? 'Completed'
        : (isPending ? 'Pending' : (model.status.isNotEmpty ? model.status : 'Failed'));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        22.h,
        20.w,
        20.h + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Transaction Summary',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF121D31),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22.sp,
                    color: const Color(0xFFA0AABD),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Banner Info Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                // Badge Icon matching listtile
                SizedBox(
                  width: 42.w,
                  height: 42.w,
                  child: SvgPicture.asset(
                    _isDebit
                        ? 'assets/svg/wallet_charging_badge.svg'
                        : 'assets/svg/wallet_topup_badge.svg',
                    width: 42.w,
                    height: 42.w,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: _isDebit
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _isDebit ? Icons.bolt_rounded : Icons.add_rounded,
                        color: _isDebit
                            ? kBrandPrimaryBlue
                            : const Color(0xFF03E8BE),
                        size: 22.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Title and Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF121D31),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        fullDateStr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF68768E),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 13.sp,
                        color: statusColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),

          // Key Metrics Row (Date | Time | Type | Method)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Col 1: Date
              Expanded(
                child: _buildMetricCol(
                  label: 'Date',
                  value: dateStr,
                ),
              ),
              _buildMetricDivider(),

              // Col 2: Time
              Expanded(
                child: _buildMetricCol(
                  label: 'Time',
                  value: timeStr,
                ),
              ),
              _buildMetricDivider(),

              // Col 3: Type
              Expanded(
                child: _buildMetricCol(
                  label: 'Type',
                  value: _isDebit ? 'Deduction' : 'Top-up',
                ),
              ),
              _buildMetricDivider(),

              // Col 4: Payment Mode
              Expanded(
                child: _buildMetricCol(
                  label: 'Mode',
                  value: _isDebit ? 'Wallet' : 'Online',
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),

          // Section Title: Payment Details
          Text(
            'Payment Details',
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 12.h),

          // Highlighted Coins Added / Deducted Card (Full width horizontal)
          _buildPaymentCard(
            label: _isDebit ? 'Coins Deducted' : 'Coins Added',
            value: '${_isDebit ? '-' : '+'} ${model.amount.toStringAsFixed(2)} Coins',
            subtitle: '₹ 1 = 1 Coin',
            isHighlighted: true,
            isDebit: _isDebit,
          ),
          SizedBox(height: 26.h),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPrimaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFA0AABD),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF121D31),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 32.h,
      color: const Color(0xFFF1F5F9),
      margin: EdgeInsets.symmetric(horizontal: 6.w),
    );
  }

  Widget _buildPaymentCard({
    required String label,
    required String value,
    String? subtitle,
    required bool isHighlighted,
    bool isDebit = false,
  }) {
    final bgColor = isHighlighted
        ? (isDebit ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF))
        : const Color(0xFFF8FAFC);
    final borderColor = isHighlighted
        ? (isDebit ? const Color(0xFFFEE2E2) : const Color(0xFFDBEAFE))
        : const Color(0xFFF1F5F9);
    final valueColor = isHighlighted
        ? (isDebit ? const Color(0xFFDC2626) : const Color(0xFF16A34A))
        : const Color(0xFF121D31);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF68768E),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
