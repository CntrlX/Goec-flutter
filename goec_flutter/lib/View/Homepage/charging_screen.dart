// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../Utils/routes.dart';
import '../../Singletones/dialogs.dart';
import '../../Controller/charging_screen_controller.dart';
import 'ChargningAnimations/charging_progress.dart';
import 'ChargningAnimations/charging_loader.dart';
import '../Widgets/glass_circle_icon_button.dart';

class ChargingScreen extends GetView<ChargingScreenController> {
  const ChargingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Container(
          color: const Color(0xFF0049C2),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [

                  GlassBackButton(),
                  SizedBox(width: 14.w),
                  Text(
                    'Charging Session',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 28.5 / 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),

              // 1. Hero Charging Gauge
              _buildHeroGauge(controller),

              SizedBox(height: 28.h),

              // 2. Charger Details Card
              _buildChargerDetailsCard(context, controller),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() => _buildFooter(context, controller)),
    );
  }

  /// 1. Hero Circular Gauge and SOC / Time display
  Widget _buildHeroGauge(ChargingScreenController controller) {
    final percentage = controller.status_model.value.percentage;
    final isInitiating = controller.chargingStatus.value == 'initiating' ||
        ((controller.chargingStatus.value.isEmpty ||
                controller.activeSessionModel.outputType == 'AC') &&
            (controller.chargingStatus.value != 'finished' &&
                controller.chargingStatus.value != 'completed'));

    return Column(
      children: [
        // Circular Gauge Animation
        SizedBox(
          width: double.infinity,
          child: isInitiating
              ? const Center(child: ChargingLoader())
              : ChargingProgress(progress: percentage / 100.0),
        ),

        SizedBox(height: 20.h),

        // Percentage & Elapsed Time Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cyan Lightning Icon
            SvgPicture.asset(
              'assets/svg/charging_energy.svg',
              width: 18.w,
              height: 18.w,
              colorFilter: const ColorFilter.mode(
                Color(0xFF0284C7),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 6.w),

            // Gradient SOC Text
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF0049C2), Color(0xFF02E8BD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w800,
                  height: 36 / 30,
                  color: Colors.white,
                  letterSpacing: -0.75,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Estimated Duration Pill Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(9999.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${controller.time[0]}',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      height: 20 / 14,
                      color: const Color(0xFF0049C2),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'hrs',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: const Color(0xFF68768E),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${controller.time[1]}',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      height: 20 / 14,
                      color: const Color(0xFF0049C2),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'min',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: const Color(0xFF68768E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 6.h),

        // Subtitle status
        Text(
          _getStatusSubtitle(controller.chargingStatus.value),
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            height: 19.5 / 13,
            color: const Color(0xFF68768E),
          ),
        ),
      ],
    );
  }

  String _getStatusSubtitle(String status) {
    if (status == 'finishing') return 'Charging finishing...';
    if (status == 'finished') return 'Charging Finished';
    if (status == 'completed') return 'Charging Completed';
    if (status == 'disconnected') return 'Charger Disconnected';
    if (status == 'initiating') return 'Initiating session...';
    return 'Charging in progress';
  }

  /// 2. Charger Details Card
  Widget _buildChargerDetailsCard(
      BuildContext context, ChargingScreenController controller) {
    final active = controller.activeSessionModel;
    final status = controller.status_model.value;

    final outputType = status.outputType.isNotEmpty
        ? status.outputType
        : (active.outputType.isNotEmpty ? active.outputType : 'AC');
    final capacity = status.capacity > 0 ? status.capacity : active.capacity;
    final connectorType = status.connectorType.isNotEmpty
        ? status.connectorType
        : (active.connectorType.isNotEmpty ? active.connectorType : 'Type 2');
    final tariff = active.tariff > 0 ? active.tariff : 0.0;
    final energyUsed = status.unitUsed;
    final chargedAmount = status.amount > 0 ? status.amount : (tariff * energyUsed);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: const Color(0xFFE6EAEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Charger Details + View Station Link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Charger Details',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  height: 24 / 14,
                  color: const Color(0xFF121D31),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (active.chargingStationId.isNotEmpty &&
                      active.chargingStationId != '-1') {
                    Get.toNamed(
                      Routes.calistaCafePageRoute,
                      arguments: active.chargingStationId,
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'View Station',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        height: 19.5 / 12,
                        color: const Color(0xFF0049C2),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10.w,
                      color: const Color(0xFF0049C2),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Row 1: Power & Connector Type Columns
          Row(
            children: [
              // Power Column
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FD),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/svg/charging_power.svg',
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$outputType ${capacity.toStringAsFixed(1)} kW',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              height: 21 / 14,
                              color: const Color(0xFF121D31),
                            ),
                          ),
                          Text(
                            'Charger Power',
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              height: 16.5 / 11,
                              color: const Color(0xFF68768E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // Connector Column
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FD),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/svg/charging_connector.svg',
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            connectorType,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              height: 21 / 14,
                              color: const Color(0xFF121D31),
                            ),
                          ),
                          Text(
                            'Connector Type',
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              height: 16.5 / 11,
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

          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: const Divider(
              color: Color(0xFFF1F5F9),
              thickness: 1,
              height: 1,
            ),
          ),

          // Row 2: Tariff Rate Row
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FD),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/svg/charging_tariff.svg',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '$kCurrency ${tariff.toStringAsFixed(2)} ',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 21.75 / 14,
                        color: const Color(0xFF121D31),
                      ),
                      children: [
                        TextSpan(
                          text: '/kWh',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            height: 18 / 12,
                            color: const Color(0xFF68768E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Tariff Rate',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      height: 16.5 / 11,
                      color: const Color(0xFF68768E),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Row 3: Energy Consumed & Charged Amount Dynamic Sub-Cards
          Row(
            children: [
              // Energy Consumed Sub-Card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svg/charging_energy.svg',
                            width: 14.w,
                            height: 14.w,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              'Energy Consumed',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                height: 16.5 / 11,
                                color: const Color(0xFF68768E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${energyUsed.toStringAsFixed(2)} kWh',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          height: 25.5 / 16,
                          color: const Color(0xFF0049C2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Charged Amount Sub-Card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svg/charging_coins.svg',
                            width: 14.w,
                            height: 14.w,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              'Charged Amount',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                height: 16.5 / 11,
                                color: const Color(0xFF68768E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '$kCurrency ${chargedAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          height: 25.5 / 16,
                          color: const Color(0xFF0049C2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Bottom Action Footer & Disclaimer
  Widget _buildFooter(
      BuildContext context, ChargingScreenController controller) {
    final status = controller.chargingStatus.value;
    final isFinished = status == 'finished' ||
        status == 'completed' ||
        status == 'disconnected';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: Color(0xFFEBEFEA), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFinished)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.downloadInvoice(),
                      child: Container(
                        height: 52.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.r),
                          border: Border.all(
                            color: const Color(0xFF0049C2),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Download Invoice',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            height: 24 / 16,
                            color: const Color(0xFF0049C2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.onClickFinished(),
                      child: Container(
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0049C2),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Finish',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            height: 24 / 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: () {
                  if (status == 'finishing') return;
                  _showStopChargingConfirmationSheet(context, controller);
                },
                child: Container(
                  height: 56.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: status == 'finishing'
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0049C2),
                    borderRadius: BorderRadius.circular(100.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0049C2).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Square Stop Icon
                      Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        status == 'finishing' ? 'Finishing...' : 'Stop Charging',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          height: 24 / 16,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 10.h),

            // Helper Disclaimer Note
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 15.w,
                    color: const Color(0xFFA0AABD),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'You can stop charging anytime. Final amount will be calculated based on actual energy consumed.',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFA0AABD),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStopChargingConfirmationSheet(
      BuildContext context, ChargingScreenController controller) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Stop Charging Confirmation',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Stack(
          children: [
            // Blurred and dimmed backdrop
            Positioned.fill(
              child: FadeTransition(
                opacity: curved,
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).maybePop(),
                  behavior: HitTestBehavior.opaque,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            ),

            // Sliding modal sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: Material(
                  color: Colors.transparent,
                  child: _StopChargingModalContent(controller: controller),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StopChargingModalContent extends StatelessWidget {
  final ChargingScreenController controller;

  const _StopChargingModalContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF011631).withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24.w,
        28.h,
        24.w,
        24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Stop charging?',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.w,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Description
          Text(
            'Your charging session will end now. You’ll only be charged for the energy consumed so far.',
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              height: 22 / 15,
            ),
          ),

          SizedBox(height: 20.h),

          // Dynamic Live Energy & Amount Sub-Cards
          Obx(() {
            final active = controller.activeSessionModel;
            final status = controller.status_model.value;
            final tariff = active.tariff > 0 ? active.tariff : 0.0;
            final energyUsed = status.unitUsed;
            final chargedAmount =
                status.amount > 0 ? status.amount : (tariff * energyUsed);

            return Row(
              children: [
                // Energy Consumed Sub-Card
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/charging_energy.svg',
                              width: 14.w,
                              height: 14.w,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF10B981),
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Energy Consumed',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 16.5 / 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${energyUsed.toStringAsFixed(2)} kWh',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            height: 25.5 / 16,
                            color: const Color(0xFF0049C2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Charged Amount Sub-Card
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/charging_coins.svg',
                              width: 14.w,
                              height: 14.w,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Charged Amount',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 16.5 / 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '$kCurrency ${chargedAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            height: 25.5 / 16,
                            color: const Color(0xFF0049C2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          SizedBox(height: 24.h),

          // Primary Button: Yes, Stop Charging
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              if (controller.chargingStatus.value == 'progress' ||
                  controller.chargingStatus.value.isEmpty) {
                controller.chargingStatus.value = 'finishing';
              }
              if (Get.isDialogOpen == false) {
                Dialogs().gunStatusAlert(
                  'Finishing up',
                  'Please wait till Charging session is finished to unplug the charger',
                );
              }
              controller.stopCharging();
            },
            child: Container(
              height: 52.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0049C2),
                borderRadius: BorderRadius.circular(100.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'Yes, Stop Charging',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Secondary Button: Continue Charging
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 52.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: const Color(0xFF0049C2),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Continue Charging',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                  color: const Color(0xFF0049C2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
