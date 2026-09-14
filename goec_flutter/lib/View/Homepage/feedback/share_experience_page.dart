import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../Controller/feedback_page_controller.dart';
import '../../../Utils/routes.dart';
import '../../../constants.dart';

/// Charging Completed Screen — Matching Figma Frame 320:2511
class ShareExperienceScreen extends GetView<FeedBackPageController> {
  const ShareExperienceScreen({super.key});

  static const _pageBg = Color(0xFFF6F8FA);
  static const _headingColor = Color(0xFF121D31);
  static const _completedGreen = Color(0xFF05C06A);
  static const _mutedColor = Color(0xFF68768E);
  static const _subtextColor = Color(0xFF64748B);
  static const _primaryBlue = Color(0xFF0049C2);
  static const _skipCyan = Color(0xFF01B1E1);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar: Skip Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => controller.backToMaps(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: _skipCyan,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Celebratory Animated Tick with Floating Confetti
                      const ChargingCompletedCelebrationWidget(),

                      SizedBox(height: 12.h),

                      // 2. Headline
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            height: 39 / 26,
                            letterSpacing: -0.65,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Charging ',
                              style: TextStyle(color: _headingColor),
                            ),
                            TextSpan(
                              text: 'Completed!',
                              style: TextStyle(color: _completedGreen),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // 3. Subtitle
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'Your charging session has been successfully\ncompleted. Thank you for choosing us!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: _subtextColor,
                            height: 17.88 / 14,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // 4. Section: Charging Summary Card
                      _buildChargingSummaryCard(controller),

                      SizedBox(height: 16.h),

                      // 5. Section: Feedback Experience Card
                      _buildFeedbackCard(context, controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Charging Summary Card
  Widget _buildChargingSummaryCard(FeedBackPageController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Charging Summary" + "Completed" Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Charging Summary',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _headingColor,
                  letterSpacing: -0.4,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F0),
                  borderRadius: BorderRadius.circular(9999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        color: _completedGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        height: 16.5 / 11,
                        color: _completedGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Row: Metric Tiles (Total Energy & Amount Debited)
          Obx(() {
            final status = controller.status_model.value;
            final active = controller.activeSessionModel;
            final tariff =
                (active?.tariff != null && active!.tariff > 0)
                    ? active.tariff
                    : 0.0;
            final energyUsed = status.unitUsed;
            final amountDebited =
                status.amount > 0 ? status.amount : (tariff * energyUsed);

            return Row(
              children: [
                // Metric 1: Total Energy
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FD),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDCE8FC),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/svg/charging_energy.svg',
                            width: 16.w,
                            height: 16.w,
                            colorFilter: const ColorFilter.mode(
                              _primaryBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Total Energy',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: kFontFamily,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: _mutedColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  maxLines: 1,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${energyUsed.toStringAsFixed(2)} ',
                                        style: TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          height: 18 / 18,
                                          color: _headingColor,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'kWh',
                                        style: TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          height: 16 / 12,
                                          color: _mutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                // Metric 2: Amount Debited
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEFAF4),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD5F5E4),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/svg/charging_coins.svg',
                            width: 16.w,
                            height: 16.w,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Amount Debited',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: kFontFamily,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: _mutedColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  maxLines: 1,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${amountDebited.toStringAsFixed(2)} ',
                                        style: TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          height: 18 / 18,
                                          color: _headingColor,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Coins',
                                        style: TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          height: 16 / 12,
                                          color: _mutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          SizedBox(height: 6.h),

          // Metadata List
          // 1. Session Duration
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16.w,
                      color: _mutedColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Session Duration',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: _mutedColor,
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => Text(
                    controller.sessionDuration.value,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _headingColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9), height: 1),

          // 2. Charging Station
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.w,
                      color: _mutedColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Charging Station',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: _mutedColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          controller.stationName.value.isNotEmpty
                              ? controller.stationName.value
                              : (controller.activeSessionModel?.chargerName
                                          .isNotEmpty ==
                                      true
                                  ? controller
                                      .activeSessionModel!.chargerName
                                  : 'Charging Station'),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _headingColor,
                          ),
                        ),
                        if (controller.stationAddress.value.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Text(
                              controller.stationAddress.value,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: _mutedColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9), height: 1),

          // 3. Connector Type
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/svg/charging_connector.svg',
                      width: 16.w,
                      height: 16.w,
                      colorFilter: const ColorFilter.mode(
                        _mutedColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Connector Type',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: _mutedColor,
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => Text(
                    controller.connectorTypeName.value,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _headingColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Feedback Experience Card
  Widget _buildFeedbackCard(
      BuildContext context, FeedBackPageController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'How was your charging experience?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _headingColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Tap a star to rate',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: _mutedColor,
            ),
          ),
          SizedBox(height: 18.h),

          // 5 Interactive Rating Stars
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNum = index + 1;
                final isSelected = starNum <= controller.selectedRating.value;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.setRating(starNum);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        Icons.star_rounded,
                        size: 36.w,
                        color: isSelected
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 20.h),

          // "Leave a Feedback" Button
          GestureDetector(
            onTap: () {
              Get.toNamed(
                Routes.paymentfeedbackPageRoute,
                arguments: controller.stationId,
              );
            },
            child: Container(
              height: 52.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _primaryBlue,
                borderRadius: BorderRadius.circular(100.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'Leave a Feedback',
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
        ],
      ),
    );
  }
}

/// Celebratory Animated Badge with Floating Confetti
class ChargingCompletedCelebrationWidget extends StatefulWidget {
  const ChargingCompletedCelebrationWidget({super.key});

  @override
  State<ChargingCompletedCelebrationWidget> createState() =>
      _ChargingCompletedCelebrationWidgetState();
}

class _ChargingCompletedCelebrationWidgetState
    extends State<ChargingCompletedCelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _floatingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _confettiProgress;

  // Particle models
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (pop & burst)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );

    _confettiProgress = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.9, curve: Curves.easeOutBack),
    );

    // 2. Ambient floating oscillation
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // Generate 12 confetti particles matching Figma
    _particles = [
      _ConfettiParticle(
        angle: -math.pi / 2, // Top
        targetRadius: 62.0,
        isPill: true,
        width: 4.5,
        height: 12.0,
        rotation: -0.25,
        color: const Color(0xFF05C06A),
        driftSpeed: 1.0,
        driftPhase: 0.0,
      ),
      _ConfettiParticle(
        angle: -math.pi / 3, // Top-right circle
        targetRadius: 66.0,
        isPill: false,
        width: 6.0,
        height: 6.0,
        rotation: 0.0,
        color: const Color(0xFF34D399),
        driftSpeed: 1.3,
        driftPhase: 0.8,
      ),
      _ConfettiParticle(
        angle: -math.pi / 6, // Top-right pill
        targetRadius: 72.0,
        isPill: false,
        width: 7.5,
        height: 7.5,
        rotation: 0.0,
        color: const Color(0xFF38BDF8),
        driftSpeed: 0.9,
        driftPhase: 1.5,
      ),
      _ConfettiParticle(
        angle: 0.1, // Right
        targetRadius: 64.0,
        isPill: true,
        width: 4.5,
        height: 11.0,
        rotation: 0.8,
        color: const Color(0xFF05C06A),
        driftSpeed: 1.1,
        driftPhase: 2.2,
      ),
      _ConfettiParticle(
        angle: math.pi / 4, // Bottom-right circle
        targetRadius: 60.0,
        isPill: false,
        width: 6.5,
        height: 6.5,
        rotation: 0.0,
        color: const Color(0xFF0049C2),
        driftSpeed: 1.4,
        driftPhase: 3.0,
      ),
      _ConfettiParticle(
        angle: math.pi / 2.2, // Bottom-right pill
        targetRadius: 66.0,
        isPill: true,
        width: 4.5,
        height: 12.0,
        rotation: -0.7,
        color: const Color(0xFF05C06A),
        driftSpeed: 0.8,
        driftPhase: 3.8,
      ),
      _ConfettiParticle(
        angle: math.pi / 1.7, // Bottom-left circle
        targetRadius: 64.0,
        isPill: false,
        width: 7.0,
        height: 7.0,
        rotation: 0.0,
        color: const Color(0xFF01B1E1),
        driftSpeed: 1.2,
        driftPhase: 4.5,
      ),
      _ConfettiParticle(
        angle: math.pi * 0.82, // Bottom-left pill
        targetRadius: 68.0,
        isPill: true,
        width: 4.5,
        height: 10.0,
        rotation: 0.4,
        color: const Color(0xFF05C06A),
        driftSpeed: 1.0,
        driftPhase: 5.2,
      ),
      _ConfettiParticle(
        angle: math.pi * 0.95, // Left circle
        targetRadius: 62.0,
        isPill: false,
        width: 6.0,
        height: 6.0,
        rotation: 0.0,
        color: const Color(0xFF0284C7),
        driftSpeed: 1.5,
        driftPhase: 0.4,
      ),
      _ConfettiParticle(
        angle: -math.pi * 0.85, // Top-left circle
        targetRadius: 70.0,
        isPill: false,
        width: 7.5,
        height: 7.5,
        rotation: 0.0,
        color: const Color(0xFF38BDF8),
        driftSpeed: 1.1,
        driftPhase: 1.2,
      ),
      _ConfettiParticle(
        angle: -math.pi * 0.65, // Top-left pill
        targetRadius: 65.0,
        isPill: true,
        width: 4.5,
        height: 11.5,
        rotation: -0.9,
        color: const Color(0xFF05C06A),
        driftSpeed: 0.9,
        driftPhase: 2.0,
      ),
      _ConfettiParticle(
        angle: -math.pi * 0.42, // Top-center circle
        targetRadius: 60.0,
        isPill: false,
        width: 5.5,
        height: 5.5,
        rotation: 0.0,
        color: const Color(0xFF00C087),
        driftSpeed: 1.3,
        driftPhase: 2.7,
      ),
    ];

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const containerSize = 160.0;

    return SizedBox(
      width: containerSize.w,
      height: containerSize.w,
      child: AnimatedBuilder(
        animation: Listenable.merge([_entranceController, _floatingController]),
        builder: (context, child) {
          final center = Offset(containerSize.w / 2, containerSize.w / 2);
          final progress = _confettiProgress.value;
          final floatVal = _floatingController.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Confetti Particles
              ...List.generate(_particles.length, (i) {
                final p = _particles[i];
                final ambientDrift = math.sin(
                        floatVal * math.pi * 2 * p.driftSpeed + p.driftPhase) *
                    4.0;
                final r = (p.targetRadius.w * progress) + ambientDrift;
                final x = center.dx + r * math.cos(p.angle);
                final y = center.dy + r * math.sin(p.angle);

                final opacity = progress.clamp(0.0, 1.0);

                return Positioned(
                  left: x - (p.width.w / 2),
                  top: y - (p.height.w / 2),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: p.rotation + (ambientDrift * 0.05),
                      child: Container(
                        width: p.width.w,
                        height: p.height.w,
                        decoration: BoxDecoration(
                          color: p.color,
                          borderRadius: BorderRadius.circular(9999.r),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Central Scalloped Checkmark Badge
              ScaleTransition(
                scale: _scaleAnimation,
                child: CustomPaint(
                  size: Size(78.w, 78.w),
                  painter: _ScallopBadgePainter(
                    color: const Color(0xFF05C06A),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConfettiParticle {
  final double angle;
  final double targetRadius;
  final bool isPill;
  final double width;
  final double height;
  final double rotation;
  final Color color;
  final double driftSpeed;
  final double driftPhase;

  _ConfettiParticle({
    required this.angle,
    required this.targetRadius,
    required this.isPill,
    required this.width,
    required this.height,
    required this.rotation,
    required this.color,
    required this.driftSpeed,
    required this.driftPhase,
  });
}

/// Custom painter for the scalloped green badge with a clean white checkmark
class _ScallopBadgePainter extends CustomPainter {
  final Color color;

  _ScallopBadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.86;
    const lobes = 12;
    final path = Path();
    const angleStep = (math.pi * 2) / (lobes * 2);

    for (int i = 0; i < lobes * 2; i++) {
      final isOuter = i % 2 == 0;
      final r = isOuter ? outerRadius : innerRadius;
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final midAngle = (i - 0.5) * angleStep - math.pi / 2;
        final midR = (outerRadius + innerRadius) / 2;
        final midX = center.dx + midR * math.cos(midAngle);
        final midY = center.dy + midR * math.sin(midAngle);
        path.quadraticBezierTo(midX, midY, x, y);
      }
    }
    path.close();

    // Subtle soft glow shadow
    canvas.drawShadow(path, color.withValues(alpha: 0.3), 8, true);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Crisp checkmark in the center
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.095
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    final start = Offset(
      center.dx - size.width * 0.17,
      center.dy + size.height * 0.01,
    );
    final mid = Offset(
      center.dx - size.width * 0.03,
      center.dy + size.height * 0.14,
    );
    final end = Offset(
      center.dx + size.width * 0.18,
      center.dy - size.height * 0.11,
    );

    checkPath.moveTo(start.dx, start.dy);
    checkPath.lineTo(mid.dx, mid.dy);
    checkPath.lineTo(end.dx, end.dy);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _ScallopBadgePainter oldDelegate) =>
      oldDelegate.color != color;
}
