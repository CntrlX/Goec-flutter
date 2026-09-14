import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Controller/chargePage_controller.dart';
import '../../Model/chargeTransactionModel.dart';
import '../../Singletones/app_data.dart';
import '../../Utils/routes.dart';
import '../../constants.dart';
import '../Widgets/cached_svg_badge.dart';
import '../Widgets/date_range_picker_sheet.dart';
import 'charging_summary_modal_sheet.dart';

class ChargeScreen extends StatefulWidget {
  const ChargeScreen({super.key});

  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen>
    with AutomaticKeepAliveClientMixin {
  final ChargeScreenController controller = Get.find<ChargeScreenController>();

  static const String _chargingBadgeAsset =
      'assets/svg/wallet_charging_badge.svg';

  final Map<String, String> _durationCache = {};

  ui.Image? _chargingBadgeImage;
  double _badgeSize = 44;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheBadge());
  }

  Future<void> _precacheBadge() async {
    if (!mounted) return;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    _badgeSize = 44.w;
    await SvgRasterCache.precache(
      _chargingBadgeAsset,
      logicalPx: _badgeSize,
      devicePixelRatio: dpr,
    );
    if (!mounted) return;
    setState(() {
      _chargingBadgeImage = SvgRasterCache.getSync(
        _chargingBadgeAsset,
        logicalPx: _badgeSize,
        devicePixelRatio: dpr,
      );
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _formatDuration(String startRaw, String stopRaw) {
    final cacheKey = '$startRaw|$stopRaw';
    final cached = _durationCache[cacheKey];
    if (cached != null) return cached;

    String result = '--';
    if (startRaw.isEmpty || stopRaw.isEmpty) {
      _durationCache[cacheKey] = result;
      return result;
    }
    try {
      DateTime? start = DateTime.tryParse(startRaw);
      DateTime? stop = DateTime.tryParse(stopRaw);
      final formats = [
        'dd-MM-yyyy HH:mm:ss',
        'dd-MM-yyyy hh:mma',
        'dd/MM/yyyy HH:mm:ss',
        'dd/MM/yyyy hh:mm a',
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-ddTHH:mm:ss.SSSZ',
        'yyyy-MM-ddTHH:mm:ss',
      ];
      if (start == null || stop == null) {
        for (final f in formats) {
          try {
            start ??= DateFormat(f).parseLoose(startRaw);
          } catch (_) {}
          try {
            stop ??= DateFormat(f).parseLoose(stopRaw);
          } catch (_) {}
          if (start != null && stop != null) break;
        }
      }

      if (start != null && stop != null) {
        final diff = stop.difference(start);
        final hours = diff.inHours;
        final mins = diff.inMinutes % 60;
        result = hours > 0 ? "$hours H $mins MIN" : "$mins MIN";
      }
    } catch (_) {}

    _durationCache[cacheKey] = result;
    return result;
  }

  Future<void> _pickDateRange(BuildContext context) async {
    await showDateRangePickerSheet(
      context,
      initialStartDate: controller.startDate.text,
      initialEndDate: controller.endDate.text,
      onApply: (startDate, endDate) async {
        controller.startDate.text = startDate;
        controller.endDate.text = endDate;
        await controller.getChargeTransactions();
        setState(() {});
      },
      onClear: () async {
        controller.startDate.clear();
        controller.endDate.clear();
        await controller.getChargeTransactions();
        setState(() {});
      },
    );
  }

  String get _dateFilterLabel {
    if (controller.startDate.text.isNotEmpty &&
        controller.endDate.text.isNotEmpty) {
      return "${controller.startDate.text}–${controller.endDate.text}";
    }
    return "All Time";
  }

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
                physics: const AlwaysScrollableScrollPhysics(),
                cacheExtent: 400,
                slivers: [
                  // Top Hero Section & Floating Metric Card
                  SliverToBoxAdapter(
                    child: RepaintBoundary(
                      child: _buildHeroAndMetricCard(context),
                    ),
                  ),

                  // Charging History Header & Sheet Handle
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
                                "Charging History",
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF121D31),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _pickDateRange(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F1FF),
                                    borderRadius: BorderRadius.circular(100.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 15.sp,
                                        color: kBrandPrimaryBlue,
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        _dateFilterLabel,
                                        style: TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: kBrandPrimaryBlue,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16.sp,
                                        color: kBrandPrimaryBlue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),

                  // History List / Empty State
                  Obx(() {
                    final itemCount = controller.model_list.length;
                    final isEmpty = itemCount == 0 &&
                        !controller.isInitialLoading.value;

                    if (isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final model = controller.model_list[index];
                          final isLast = index == itemCount - 1;

                          return ColoredBox(
                            key: ValueKey(model.transactionId),
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      showChargingSummaryModalSheet(
                                        context,
                                        model: model,
                                      );
                                    },
                                    child: _buildHistoryItem(model),
                                  ),
                                  if (!isLast)
                                    const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                      thickness: 1,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: itemCount,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                      ),
                    );
                  }),

                  Obx(() {
                    if (!controller.isLoadingMore.value) {
                      return SliverToBoxAdapter(
                        child: SizedBox(height: 32.h),
                      );
                    }
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: kBrandPrimaryBlue,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
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
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 10.h,
              bottom: 14.h,
            ),
            child: Row(
              children: [
                Text(
                  "History",
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
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

  Widget _buildHeroAndMetricCard(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF6F8FA),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Hero Container with Illustration & Greetings
          Container(
            width: double.infinity,
            height: 185.h,
            decoration: const BoxDecoration(
              color: Color(0xFFEBF2FF),
            ),
            child: Stack(
              children: [
                // Right 3D Charger Illustration
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/charge_hero_charger.png',
                    height: 185.h,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.low,
                    cacheHeight: 370,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),

                // Left Greetings & Subtitle
                Positioned(
                  left: 20.w,
                  top: 20.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Ready to charge?",
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Plug in, tap and get moving.",
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Metric Summary Card
          Padding(
            padding: EdgeInsets.only(top: 130.h, left: 16.w, right: 16.w, bottom: 16.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  // Top Stats Row (Line by Line: Icon -> Value -> Label)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Stat 1: Energy Charged
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.bolt_rounded,
                                color: kBrandPrimaryBlue,
                                size: 26.sp,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Obx(
                              () => Text(
                                "${appData.userModel.value.total_units.toStringAsFixed(2)} kWh",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: kBrandPrimaryBlue,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "Energy Charged",
                              textAlign: TextAlign.center,
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

                      // Vertical Divider
                      Container(
                        height: 52.h,
                        width: 1,
                        color: const Color(0xFFF1F5F9),
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                      ),

                      // Stat 2: Total Session
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDFA),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.bar_chart_rounded,
                                color: Color(0xFF00CBB4),
                                size: 24,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Obx(
                              () => Text(
                                "${appData.userModel.value.total_sessions}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF03E8BE),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "Total Session",
                              textAlign: TextAlign.center,
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

                  SizedBox(height: 18.h),

                  // Start Charging Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(Routes.qrScanPageRoute);
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
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "Start Charging",
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
            ),
          ),
        ],
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
            'assets/images/charge_empty_history.png',
            width: 216.w,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.low,
            cacheWidth: 432,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.receipt_long_rounded,
              size: 80.sp,
              color: const Color(0xFFCBD5E1),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "No charging history yet",
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121D31),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Start your first charging session to see your history here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF68768E),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ChargeTransactionModel model) {
    final stationName =
        model.stationName.isNotEmpty ? model.stationName : "Charging Station";
    final stationAddress =
        model.stationAddress.isNotEmpty ? model.stationAddress : "--";
    final duration =
        _formatDuration(model.chargingStartTime, model.chargingStopTime);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Icon badge - SVG from Figma
          SizedBox(
            width: _badgeSize,
            height: _badgeSize,
            child: CachedSvgBadge(
              image: _chargingBadgeImage,
              size: _badgeSize,
              placeholder: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: kBrandPrimaryBlue,
                  size: 24,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Details (Middle)
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
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF121D31),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  stationAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFA0AABD),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Right Column (Duration & Amount)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13.sp,
                    color: const Color(0xFFA0AABD),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    duration,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF68768E),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                "Cr. ${model.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: kBrandPrimaryBlue,
                ),
              ),
            ],
          ),

          SizedBox(width: 6.w),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFFCBD5E1),
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
