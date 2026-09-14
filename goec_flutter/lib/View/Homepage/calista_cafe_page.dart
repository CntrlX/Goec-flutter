import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:freelancer_app/Controller/calista_cafePage_controller.dart';
import 'package:freelancer_app/Model/chargerModel.dart';
import 'package:freelancer_app/Model/evPortsModel.dart';
import 'package:freelancer_app/Singletones/app_data.dart';
import 'package:freelancer_app/Utils/routes.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/Utils/utils.dart';
import 'package:freelancer_app/View/Widgets/cached_network_image.dart';
import 'package:freelancer_app/View/Widgets/customText.dart';
import 'package:freelancer_app/View/Widgets/glass_circle_icon_button.dart';
import 'package:freelancer_app/constants.dart';

/// Station detail — Figma states 27 (idle), 28 (connector selected), 29 (confirm sheet).
class CalistaCafeScreen extends GetView<CalistaCafePageController> {
  const CalistaCafeScreen({super.key});

  static const _muted = Color(0xFFA0AABD);
  static const _bodyGrey = Color(0xFF5C6E84);
  static const _chipBg = Color(0xFFF4F7FA);
  static const _chipFg = Color(0xFF485B73);
  static const _cardBorder = Color(0xFFE6EAEF);
  static const _cardBorderAlt = Color(0xFFE2E8F0);
  static const _selectedBg = Color(0xFFE2FDF8);
  static const _selectedBorder = Color(0xFF03E8BE);
  static const _iconBadge = Color(0xFFF1F5F9);
  static const _iconBadgeSelected = Color(0xFFB1F8EA);
  static const _iconSelected = Color(0xFF089279);
  static const _dirBlue = Color(0xFF01B1E1);
  static const _shareBg = Color(0xFFEAF3FD);
  static const _confirmCardBg = Color(0xFFEAF2FD);
  static const _confirmCardBorder = Color(0xFFC0D6FD);
  static const _ratingBg = Color(0xFFFEF3D6);
  static const _ratingFg = Color(0xFF7A5303);
  static const _star = Color(0xFFD99706);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    final bottomInset = systemBottomInset(context);
    final topPad = MediaQuery.paddingOf(context).top;
    // Figma: banner 224, sheet @190 (34 overlap). Pill @150 h=30 → 10px gap above sheet.
    final bannerH = 224.h + topPad * 0.2;
    final sheetOverlap = 34.h;
    final sheetTop = bannerH - sheetOverlap;
    const pillGap = 10.0; // Figma: sheetTop(190) - pillBottom(180)
    final pillH = 30.h;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Scrollable page ──────────────────────────────────────────
            Positioned.fill(
              child: RefreshIndicator(
                displacement: 80,
                backgroundColor: Colors.white,
                color: kBrandPrimaryBlue,
                onRefresh: () async {
                  await controller.getChargeStationDetails(
                    controller.model.value.id.toString(),
                  );
                },
                child: SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: bannerH,
                        child: _bannerHeader(context),
                      ),
                      // Open/closed pill — attached just above white sheet (10px gap)
                      Positioned(
                        top: sheetTop - pillGap.h - pillH,
                        left: 24.w,
                        child: Obx(() => _openStatusPill()),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: sheetTop),
                        // Shadow outside the clipped white fill so it sits on the image, not on the sheet.
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.sizeOf(context).height - sheetTop,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.r),
                              topRight: Radius.circular(28.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.r),
                              topRight: Radius.circular(28.r),
                            ),
                            child: ColoredBox(
                              color: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _mainSheet(context),
                                  Obx(() {
                                    final h = controller.hasConnectorSelected
                                        ? 140.h + bottomInset
                                        : 70.h + bottomInset;
                                    return height(h);
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Fixed bottom footer (reviews always; CTA when selected) ─
            Obx(() => _bottomFooter(context, bottomInset)),
          ],
        ),
      ),
    );
  }

  // ─── Banner (network image — never from Figma export) ───────────────────

  Widget _bannerHeader(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Obx(
            () => cachedNetworkImage(
              controller.model.value.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0),
                    Colors.black.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: topPad + 8.h,
            left: 17.w,
            right: 17.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const GlassBackButton(),
                Obx(
                  () {
                    final isFavorite = controller.model.value.isFavorite;
                    return GlassCircleIconButton(
                      onTap: controller.changeFavoriteStatus,
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? const Color(0xFFAF2727)
                            : Colors.white,
                        size: 18.sp,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Status pill moved to page Stack (attached above white sheet)
        ],
      ),
    );
  }

  Widget _openStatusPill() {
    final open = controller.isOpen.value;
    final closeText = convertToPmFormat(controller.model.value.stopTime);
    final openText = convertToPmFormat(controller.model.value.startTime);
    final label = open
        ? 'Open now · closes $closeText'
        : 'Closed now · opens $openText';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: open
                  ? kOnboardingGradient
                  : const LinearGradient(
                      colors: [Color(0xFFC33838), Color(0xFFE57373)],
                    ),
            ),
          ),
          width(8.w),
          CustomText(
            text: label,
            size: 14.sp,
            fontWeight: FontWeight.w600,
            color: kNeutralPrimary,
            height: 16 / 14,
          ),
        ],
      ),
    );
  }

  // ─── White content sheet ────────────────────────────────────────────────

  Widget _mainSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleAndRating(),
          height(10.h),
          _distanceRow(),
          height(10.h),
          _amenityChips(),
          height(16.h),
          _addressAndActions(),
          height(24.h),
          _connectorSectionHeader(),
          height(12.h),
          Obx(() => _connectorList()),
        ],
      ),
    );
  }

  /// Backend uses `rating || 1` when there are no reviews — treat 0 and 1 as empty.
  bool get _hasRealRating {
    final r = controller.model.value.rating;
    return r > 1.0;
  }

  Widget _titleAndRating() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Obx(
            () => CustomText(
              text: controller.model.value.name,
              size: 24.sp,
              fontWeight: FontWeight.w800,
              color: kNeutralPrimary,
              height: 26.84 / 24,
              maxLines: 2,
            ),
          ),
        ),
        width(12.w),
        Obx(() {
          if (!_hasRealRating) {
            return Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: CustomText(
                text: 'No ratings yet',
                size: 12.sp,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            );
          }
          return Container(
            margin: EdgeInsets.only(top: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _ratingBg,
              borderRadius: BorderRadius.circular(6.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 14.sp, color: _star),
                width(4.w),
                CustomText(
                  text: controller.model.value.rating.toStringAsFixed(1),
                  size: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: _ratingFg,
                  height: 16 / 12,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _distanceRow() {
    return Obx(() {
      final short = _shortAddress(controller.model.value.address);
      final text =
          '${controller.distance.value.toStringAsFixed(2)} km away · $short';
      return Row(
        children: [
          SvgPicture.asset(
            'assets/svg/location_on_red.svg',
            width: 14.w,
            height: 14.w,
          ),
          width(6.w),
          Expanded(
            child: CustomText(
              text: text,
              size: 14.sp,
              fontWeight: FontWeight.w500,
              color: _muted,
              height: 19.5 / 14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    });
  }

  String _shortAddress(String address) {
    final parts = address
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;
    return '${parts[0]}, ${parts[1]}';
  }

  /// Figma amenity chips use emoji glyphs (not separate SVG assets).
  static const Map<String, String> _amenityEmoji = {
    'restaurant': '🍴',
    'cafe': '☕',
    'coffee': '☕',
    'hotel': '🏨',
    'mall': '🏬',
    'shopping': '🛍️',
    'shop': '🛍️',
    'parking': '🅿️',
    'park': '🅿️',
    'wifi': '📶',
    'wi-fi': '📶',
    'toilet': '🚻',
    'restroom': '🚻',
    'washroom': '🚻',
    'bathroom': '🚻',
    'church': '⛪',
    'church nearby': '⛪',
    'atm': '🏧',
    'lounge': '🛋️',
  };

  String _emojiForAmenity(String label) {
    final key = label.trim().toLowerCase();
    return _amenityEmoji[key] ??
        _amenityEmoji[key.replaceAll('_', ' ')] ??
        '📍';
  }

  Widget _amenityChips() {
    return Obx(() {
      final amenities = controller.amenities
          .where((e) => e.toString().trim().isNotEmpty)
          .toList();
      if (amenities.isEmpty) return const SizedBox.shrink();
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < amenities.length; i++) ...[
              if (i > 0) width(8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _chipBg,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _emojiForAmenity(amenities[i].toString()),
                      style: TextStyle(fontSize: 12.sp, height: 1),
                    ),
                    width(6.w),
                    CustomText(
                      text: amenities[i].toString(),
                      size: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _chipFg,
                      height: 16 / 12,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _addressAndActions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Obx(
            () => CustomText(
              text: controller.model.value.address,
              size: 14.sp,
              fontWeight: FontWeight.w500,
              color: _bodyGrey,
              height: 21.13 / 14,
            ),
          ),
        ),
        width(16.w),
        _roundAction(
          color: _dirBlue,
          onTap: controller.launchOnGoogleMap,
          child: SvgPicture.asset(
            'assets/svg/direction.svg',
            width: 20.w,
            height: 20.w,
            colorFilter:
                const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        width(12.w),
        _roundAction(
          color: _shareBg,
          onTap: controller.shareStationLocation,
          child: SvgPicture.asset(
            'assets/svg/share.svg',
            width: 20.w,
            height: 20.w,
            colorFilter:
                const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  Widget _roundAction({
    required Color color,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _connectorSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Choose a connector',
          size: 18.sp,
          fontWeight: FontWeight.w700,
          color: kNeutralPrimary,
        ),
        height(4.h),
        CustomText(
          text: 'Tap one to see live availability & pricing',
          size: 13.sp,
          fontWeight: FontWeight.w500,
          color: _muted,
        ),
      ],
    );
  }

  Widget _connectorList() {
    final chargers = controller.model.value.chargers;
    if (chargers.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: CustomText(
          text: 'No connectors available at this station',
          size: 14.sp,
          color: _muted,
          textAlign: TextAlign.center,
        ),
      );
    }

    final items = <_ConnectorItem>[];
    for (var ci = 0; ci < chargers.length; ci++) {
      final charger = chargers[ci];
      final chargerAvailable = charger.ocppStatus == kAvailable ||
          charger.ocppStatus.isEmpty;
      for (var pi = 0; pi < charger.evports.length; pi++) {
        items.add(_ConnectorItem(
          chargerIndex: ci,
          portIndex: pi,
          charger: charger,
          port: charger.evports[pi],
          chargerAvailable: chargerAvailable,
          displayIndex: items.length + 1,
        ));
      }
    }

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) height(12.h),
          _connectorCard(items[i]),
        ],
      ],
    );
  }

  String _statusFor(_ConnectorItem item) {
    final evport = item.port;
    if (!item.chargerAvailable) return kUnavailable;
    if (evport.ocppStatus == kAvailable || evport.ocppStatus.isEmpty) {
      return kAvailable;
    }
    if (evport.ocppStatus == kPreparing) return kPreparing;
    if (evport.ocppStatus == kFinishing) return kFinishing;
    if (evport.ocppStatus == kCharging) return kBusy;
    if (evport.ocppStatus == kFaulted) return kFaulted;
    return kUnavailable;
  }

  bool _canSelect(String status) =>
      status == kAvailable || status == kPreparing || status == kFinishing;

  Color _statusColor(String status) {
    if (status == kAvailable ||
        status == kPreparing ||
        status == kFinishing) {
      return kBrandPrimaryBlue;
    }
    if (status == kBusy) return const Color(0xFFE37A2D);
    if (status == kFaulted) return const Color(0xFFF93B2D);
    return _muted;
  }

  String _statusLabel(String status, EvPortModel port) {
    // Same as pre-revamp: show real OCPP status; only Busy appends SoC.
    if (status == kBusy) {
      return port.currentSoc.isNotEmpty
          ? '$kBusy (${port.currentSoc}%)'
          : kBusy;
    }
    return status;
  }

  Widget _connectorCard(_ConnectorItem item) {
    final status = _statusFor(item);
    final selectable = _canSelect(status);
    final selected = controller.selectedCharger.value == item.chargerIndex &&
        controller.selectedType.value == item.portIndex;
    final tariff =
        double.tryParse(item.charger.tariff) ?? 0;
    final title = item.charger.chargerName.trim().isNotEmpty
        ? item.charger.chargerName.trim()
        : '${item.port.connectorType.trim().isEmpty ? 'Connector' : item.port.connectorType.trim()} · ${item.charger.capacity} kW';
    final subtitle = item.port.connectorType.trim().isNotEmpty &&
            item.charger.chargerName.trim().isNotEmpty
        ? 'Connector ${item.displayIndex}'
        : 'Connector ${item.displayIndex}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: selectable
            ? () => controller.selectConnector(
                  item.chargerIndex,
                  item.portIndex,
                )
            : null,
        child: Ink(
          // Figma selected: fill #E2FDF8, stroke #03E8BE
          decoration: BoxDecoration(
            color: selected ? _selectedBg : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: selected
                  ? _selectedBorder
                  : (selectable ? _cardBorder : _cardBorderAlt),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                _radio(selected: selected, enabled: selectable),
                width(12.w),
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: selected ? _iconBadgeSelected : _iconBadge,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    connectorTypeSvgAsset(item.port.connectorType),
                    width: 20.w,
                    height: 20.w,
                    colorFilter: ColorFilter.mode(
                      selected ? _iconSelected : kNeutralSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                width(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: title,
                        size: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: kNeutralPrimary,
                        height: 20 / 16,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      CustomText(
                        text: subtitle,
                        size: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: _muted,
                        height: 18 / 14,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusColor(status),
                          ),
                        ),
                        width(4.w),
                        CustomText(
                          text: _statusLabel(status, item.port),
                          size: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(status),
                          height: 18 / 13,
                        ),
                      ],
                    ),
                    height(3.h),
                    CustomText(
                      text: '$kCurrency${tariff.toStringAsFixed(2)}/kWh',
                      size: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: _muted,
                      height: 18 / 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _radio({required bool selected, required bool enabled}) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 2,
          color: selected
              ? kBrandPrimaryBlue
              : (enabled ? const Color(0xFFCBD5E1) : _muted),
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBrandPrimaryBlue,
              ),
            )
          : null,
    );
  }

  // ─── Bottom footer (state 27 vs 28) ─────────────────────────────────────

  Widget _bottomFooter(BuildContext context, double bottomInset) {
    final selected = controller.hasConnectorSelected;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
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
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.white.withValues(alpha: 0.95),
              padding: EdgeInsets.fromLTRB(
                20.w,
                selected ? 20.h : 16.h,
                20.w,
                (selected ? 24.h : 16.h) + bottomInset,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () => _showConfirmSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandPrimaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                        ),
                        child: CustomText(
                          text: controller.selectedChargerCtaLabel,
                          size: 16.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    height(8.h),
                  ],
                  _reviewsRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewsRow() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          CustomText(
            text: 'Station reviews · ',
            size: 13.sp,
            fontWeight: FontWeight.w500,
            color: _muted,
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.reviewPageRoute, arguments: [
                controller.model.value.rating.toStringAsFixed(2),
                controller.model.value.id,
              ]);
            },
            child: CustomText(
              text: 'See reviews >',
              size: 13.sp,
              fontWeight: FontWeight.w700,
              color: kBrandPrimaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Confirm sheet (state 29) ───────────────────────────────────────────

  void _showConfirmSheet(BuildContext context) {
    final bottomInset = systemBottomInset(context);
    final sheet = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36.r),
          topRight: Radius.circular(36.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF01B1E1).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(32.w, 24.h, 32.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: 'Confirm your session',
                    size: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: kNeutralPrimary,
                    height: 32 / 18,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Icon(Icons.close, size: 20.sp, color: _muted),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _confirmCardBg,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: _confirmCardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Connector',
                              size: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _muted,
                              height: 16 / 12,
                            ),
                            height(4.h),
                            CustomText(
                              text: controller.selectedConnectorLabel,
                              size: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: kNeutralPrimary,
                              height: 24 / 16,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(
                            text: 'Rate',
                            size: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _muted,
                            height: 16 / 12,
                          ),
                          height(4.h),
                          CustomText(
                            text: controller.selectedTariffLabel,
                            size: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: kNeutralPrimary,
                            height: 24 / 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                height(20.h),
                _confirmRow(
                  label: 'Vehicle',
                  value: _vehicleLabel(),
                  showChevron: true,
                  onTap: () {
                    Navigator.of(context).maybePop();
                    Get.toNamed(Routes.myvehicleRoute);
                  },
                ),
                height(16.h),
                Obx(
                  () => _confirmRow(
                    label: 'Payment method',
                    value:
                        'Wallet · $kCurrency${appData.userModel.value.balanceAmount.toStringAsFixed(0)}',
                    showChevron: true,
                    onTap: () {
                      Navigator.of(context).maybePop();
                      Get.toNamed(Routes.walletPageRoute);
                    },
                  ),
                ),
                height(16.h),
                _confirmRow(
                  label: 'Estimated full charge',
                  // Placeholder — vehicle battery capacity is not on VehicleModel yet.
                  value: '—',
                  showChevron: false,
                ),
                height(28.h),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              border: const Border(
                top: BorderSide(color: Color(0xFFEBEFEA)),
              ),
            ),
            child: SizedBox(
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                  controller.startCharging();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandPrimaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
                child: CustomText(
                  text: 'Start Charging',
                  size: 16.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Custom route so dim+blur fade in place while only the sheet slides up.
    // (Putting the overlay inside Get.bottomSheet made the black layer slide.)
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss confirm sheet',
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
            // Figma 152:3703 — stays full-screen; fades with the route.
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
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: Material(
                  color: Colors.transparent,
                  child: sheet,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _vehicleLabel() {
    final v = appData.userModel.value.defaultVehicle;
    final brand = v.brand.trim();
    final model = v.modelName.trim();
    if (brand.isEmpty && model.isEmpty) return 'Add vehicle';
    if (brand.isEmpty) return model;
    if (model.isEmpty) return brand;
    return '$brand $model';
  }

  Widget _confirmRow({
    required String label,
    required String value,
    required bool showChevron,
    VoidCallback? onTap,
  }) {
    // Fixed trailing slot so values (and optional '>') share the same right edge.
    final chevronSlot = 14.w;
    final row = Row(
      children: [
        CustomText(
          text: label,
          size: 16.sp,
          fontWeight: FontWeight.w600,
          color: _muted,
          height: 22.5 / 16,
        ),
        width(12.w),
        Expanded(
          child: CustomText(
            text: value,
            size: 16.sp,
            fontWeight: FontWeight.w800,
            color: kNeutralPrimary,
            height: 22.5 / 16,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: chevronSlot,
          child: showChevron
              ? Align(
                  alignment: Alignment.centerRight,
                  child: CustomText(
                    text: '>',
                    size: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: kNeutralPrimary,
                  ),
                )
              : null,
        ),
      ],
    );
    if (onTap == null) return row;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}

class _ConnectorItem {
  final int chargerIndex;
  final int portIndex;
  final ChargerModel charger;
  final EvPortModel port;
  final bool chargerAvailable;
  final int displayIndex;

  _ConnectorItem({
    required this.chargerIndex,
    required this.portIndex,
    required this.charger,
    required this.port,
    required this.chargerAvailable,
    required this.displayIndex,
  });
}
