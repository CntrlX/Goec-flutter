import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../Model/chargeTransactionModel.dart';
import '../../Singletones/common_functions.dart';
import '../../Utils/utils.dart';
import '../../constants.dart';

/// Shows the Charging Summary Modal Bottom Sheet matching Figma frame 188:10175.
Future<void> showChargingSummaryModalSheet(
  BuildContext context, {
  required ChargeTransactionModel model,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss charging summary',
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
                child: ChargingSummaryModalContent(model: model),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class ChargingSummaryModalContent extends StatelessWidget {
  final ChargeTransactionModel model;

  const ChargingSummaryModalContent({
    super.key,
    required this.model,
  });

  String _formatDate(String dateRaw) {
    if (dateRaw.isEmpty) return '--';
    final formats = [
      'dd-MM-yyyy HH:mm:ss',
      'dd-MM-yyyy hh:mma',
      'dd/MM/yyyy HH:mm:ss',
      'dd/MM/yyyy hh:mm a',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-ddTHH:mm:ss.SSSZ',
      'yyyy-MM-ddTHH:mm:ss',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'yyyy-MM-dd',
    ];
    DateTime? parsed;
    for (final f in formats) {
      try {
        parsed ??= DateFormat(f).parseLoose(dateRaw);
      } catch (_) {}
    }
    parsed ??= DateTime.tryParse(dateRaw);
    if (parsed != null) {
      return DateFormat('dd MMM yyyy').format(parsed);
    }
    return dateRaw;
  }

  String _formatDuration(String startRaw, String stopRaw) {
    if (startRaw.isEmpty || stopRaw.isEmpty) return '0 hrs 0 min';
    try {
      List<int> time = getTimeDifferenceforHistory(
        startTime: startRaw,
        endTime: stopRaw,
      );
      if (time.length >= 2) {
        final hour = time[0];
        final minute = time[1];
        return '${hour} hrs ${minute} min';
      }
    } catch (_) {}
    return '0 hrs 0 min';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final stationName =
        model.stationName.isNotEmpty ? model.stationName : 'Charging Station';
    final stationAddress =
        model.stationAddress.isNotEmpty ? model.stationAddress : '--';
    final formattedDate = _formatDate(model.chargingStartTime);
    final duration =
        _formatDuration(model.chargingStartTime, model.chargingStopTime);
    final cpId = model.chargerName.isNotEmpty ? model.chargerName : '--';

    final chargingFee =
        (model.amount - model.taxAmount).clamp(0.0, double.infinity);
    final taxLabel = model.tax.isNotEmpty && model.tax != '0'
        ? '${model.tax}%'
        : '9%';

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
                'Charging Summary',
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

          // Location Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                // Bolt Icon in white badge
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.bolt_rounded,
                    color: kBrandPrimaryBlue,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),

                // Station details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stationName,
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
                        stationAddress,
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

                // Status Badge (Completed)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 13.sp,
                        color: const Color(0xFF059669),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),

          // Key Session Metrics Row (Date | Duration | CP ID | Tariff)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Col 1: Date
              Expanded(
                child: _buildMetricCol(
                  label: 'Date',
                  value: formattedDate,
                ),
              ),
              _buildMetricDivider(),

              // Col 2: Duration
              Expanded(
                child: _buildMetricCol(
                  label: 'Duration',
                  value: duration,
                ),
              ),
              _buildMetricDivider(),

              // Col 3: CP ID
              Expanded(
                child: _buildMetricCol(
                  label: 'CP ID',
                  value: cpId,
                ),
              ),
              _buildMetricDivider(),

              // Col 4: Tariff
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tariff',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA0AABD),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text.rich(
                      TextSpan(
                        text: '$kCurrency ${model.tariff.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF121D31),
                        ),
                        children: [
                          TextSpan(
                            text: '/kWh',
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF68768E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),

          // Section Title: Charging & Payment
          Text(
            'Charging & Payment',
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 12.h),

          // 4-Card Breakdown Grid
          Row(
            children: [
              // Card 1: Energy Charged
              Expanded(
                child: _buildPaymentCard(
                  label: 'Energy\nCharged',
                  value: '${model.unitConsumed.toStringAsFixed(2)} kWh',
                  isHighlighted: false,
                ),
              ),
              SizedBox(width: 8.w),

              // Card 2: Charging Fee
              Expanded(
                child: _buildPaymentCard(
                  label: 'Charging\nFee',
                  value: '$kCurrency ${chargingFee.toStringAsFixed(2)}',
                  isHighlighted: false,
                ),
              ),
              SizedBox(width: 8.w),

              // Card 3: Tax
              Expanded(
                child: _buildPaymentCard(
                  label: 'Tax\n($taxLabel)',
                  value: '$kCurrency ${model.taxAmount.toStringAsFixed(2)}',
                  isHighlighted: false,
                ),
              ),
              SizedBox(width: 8.w),

              // Card 4: Total Amount (Highlighted)
              Expanded(
                child: _buildPaymentCard(
                  label: 'Total\nAmount',
                  value: '$kCurrency ${model.amount.toStringAsFixed(2)}',
                  isHighlighted: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 26.h),

          // Download Invoice Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                CommonFunctions().downloadBookingInvoice(model.transactionId);
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
                  Icon(
                    Icons.file_download_outlined,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Download invoice',
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
    required bool isHighlighted,
  }) {
    return Container(
      height: 78.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isHighlighted
              ? kBrandPrimaryBlue.withValues(alpha: 0.3)
              : const Color(0xFFE6EAEF),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: isHighlighted
                  ? kBrandPrimaryBlue
                  : const Color(0xFF68768E),
              height: 1.2,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: isHighlighted
                  ? kBrandPrimaryBlue
                  : const Color(0xFF121D31),
            ),
          ),
        ],
      ),
    );
  }
}
