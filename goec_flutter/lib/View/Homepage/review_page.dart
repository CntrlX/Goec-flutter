import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freelancer_app/Controller/review_page_controller.dart';
import 'package:freelancer_app/Model/chargeStationDetailsModel.dart';
import 'package:freelancer_app/Model/reviewMode.dart';
import 'package:freelancer_app/Utils/routes.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/View/Widgets/cached_network_image.dart';
import 'package:freelancer_app/View/Widgets/customText.dart';
import 'package:freelancer_app/View/Widgets/glass_circle_icon_button.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';

/// Reviews & Ratings — Figma frame 162:4267.
class ReviewPage extends GetView<ReviewPageController> {
  const ReviewPage({super.key});

  static const _pageBg = Color(0xFFF6F8FA);
  static const _stationBarBg = Color(0xFFEAF2FE);
  static const _muted = Color(0xFF64748B);
  static const _bodyMuted = Color(0xFF68768E);
  static const _slate = Color(0xFF475569);
  static const _barTrack = Color(0xFFF1F5F9);
  static const _cardBorder = Color(0xFFE6EAEF);
  static const _starGold = Color(0xFFFBBF24);
  static const _verifiedBg = Color(0xFFD1FAE5);
  static const _verifiedFg = Color(0xFF059669);
  static const _updated = Color(0xFF94A3B8);

  static const _avatarPalettes = <(Color, Color)>[
    (Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
    (Color(0xFFF3E8FF), Color(0xFF7C3AED)),
    (Color(0xFFDCFCE7), Color(0xFF15803D)),
    (Color(0xFFFFE4E6), Color(0xFFBE123C)),
    (Color(0xFFFFF7ED), Color(0xFFC2410C)),
  ];

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    final bottomInset = systemBottomInset(context);
    final station = controller.calistaCafePageController.model.value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        body: Column(
          children: [
            // App bar + station strip flush (no page-bg gap between them).
            _appBar(context),
            Obx(() => _stationInfoBar(
                  controller.calistaCafePageController.model.value,
                )),
            Expanded(
              child: RefreshIndicator(
                color: kBrandPrimaryBlue,
                onRefresh: () async {
                  final id = station.id.toString();
                  if (id.isNotEmpty) await controller.getReview(id);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    Obx(() => SliverToBoxAdapter(child: _ratingSummary())),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 24.h),
                      sliver: Obx(() {
                        if (controller.modelList.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 48.h),
                              child: Center(
                                child: CustomText(
                                  text: 'No reviews yet',
                                  size: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _muted,
                                ),
                              ),
                            ),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index == controller.modelList.length - 1
                                          ? 0
                                          : 12.h,
                                ),
                                child: _reviewCard(
                                  controller.modelList[index],
                                  index,
                                ),
                              );
                            },
                            childCount: controller.modelList.length,
                          ),
                        );
                      }),
                    ),
                    SliverToBoxAdapter(child: height(100.h + bottomInset)),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _writeReviewFooter(context, bottomInset),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kBrandPrimaryBlue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: Row(
            children: [
              const GlassBackButton(),
              width(12.w),
              Expanded(
                child: CustomText(
                  text: 'Reviews & Ratings',
                  size: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              GlassCircleIconButton(
                onTap: () => controller.calistaCafePageController
                    .shareStationLocation(),
                child: SvgPicture.asset(
                  'assets/svg/basil_share_solid.svg',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stationInfoBar(ChargeStationDetailsModel station) {
    final rating = double.tryParse(controller.totalRating.value) ??
        station.rating.toDouble();
    final showRating = rating > 1.0;
    return Container(
      width: double.infinity,
      color: _stationBarBg,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: cachedNetworkImage(
              station.image,
              width: 44.w,
              height: 44.w,
              fit: BoxFit.cover,
            ),
          ),
          width(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: station.name,
                  size: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  height: 20 / 16,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  text: station.address,
                  size: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: _muted,
                  height: 16 / 13,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showRating) ...[
            width(8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE2FCF8),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  width: 0.6,
                  color: const Color(0xFF03E8BE),
                ),
              ),
              child: CustomText(
                text: '★ ${rating.toStringAsFixed(1)}',
                size: 12.sp,
                fontWeight: FontWeight.w700,
                color: kBrandPrimaryBlue,
                height: 16 / 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ratingSummary() {
    final avg = controller.averageRating;
    final count = controller.totalElements.value;
    final updated = controller.updatedLabel;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      text: avg > 0 ? avg.toStringAsFixed(1) : '—',
                      size: 40.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      height: 1,
                      textAlign: TextAlign.center,
                    ),
                    height(8.h),
                    _starsRow(avg, size: 16.sp),
                    height(8.h),
                    CustomText(
                      text: count == 1
                          ? '1 rating & review'
                          : '$count ratings & reviews',
                      size: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _muted,
                      textAlign: TextAlign.center,
                      height: 17 / 12,
                    ),
                  ],
                ),
              ),
              width(12.w),
              Expanded(
                child: Column(
                  children: [
                    for (var star = 5; star >= 1; star--) ...[
                      if (star < 5) height(6.h),
                      _distributionRow(star),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Figma 156:4148 — top stroke #F1F5F9 above verified row.
          height(16.h),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            padding: EdgeInsets.only(top: 14.h),
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: const BoxDecoration(
                    color: _verifiedBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 12.sp,
                    color: _verifiedFg,
                  ),
                ),
                width(8.w),
                Expanded(
                  child: CustomText(
                    text: 'Verified EV Community Reviews',
                    size: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                    height: 16 / 14,
                  ),
                ),
                if (updated.isNotEmpty)
                  CustomText(
                    text: updated,
                    size: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: _updated,
                    height: 16 / 12,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _distributionRow(int star) {
    final pct = controller.percentForStar(star);
    final pctLabel = '${(pct * 100).round()}%';
    return Row(
      children: [
        SizedBox(
          width: 12.w,
          child: CustomText(
            text: '$star',
            size: 11.sp,
            fontWeight: FontWeight.w600,
            color: _slate,
            height: 16 / 11,
          ),
        ),
        width(8.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8.h,
              child: Stack(
                children: [
                  Container(color: _barTrack),
                  FractionallySizedBox(
                    widthFactor: pct.clamp(0.0, 1.0),
                    child: Container(color: _starGold),
                  ),
                ],
              ),
            ),
          ),
        ),
        width(8.w),
        SizedBox(
          width: 36.w,
          child: CustomText(
            text: pctLabel,
            size: 10.sp,
            fontWeight: FontWeight.w500,
            color: _updated,
            textAlign: TextAlign.right,
            height: 16 / 10,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _starsRow(double rating, {required double size}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i && rating < i + 1;
        return Padding(
          padding: EdgeInsets.only(right: i == 4 ? 0 : 2.w),
          child: Icon(
            half
                ? Icons.star_half_rounded
                : filled
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: filled || half ? _starGold : const Color(0xFFCBD5E1),
          ),
        );
      }),
    );
  }

  Widget _reviewCard(ReviewModel model, int index) {
    final initials = _initials(model.userName);
    final palette = _avatarPalettes[index % _avatarPalettes.length];
    final time = controller.timeAgoFor(model);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.$1,
                  shape: BoxShape.circle,
                ),
                child: CustomText(
                  text: initials,
                  size: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: palette.$2,
                  height: 20 / 14,
                ),
              ),
              width(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: model.userName.trim().isEmpty
                          ? 'EV Driver'
                          : model.userName.trim(),
                      size: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: kNeutralPrimary,
                      height: 18 / 16,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (time.isNotEmpty)
                      CustomText(
                        text: time,
                        size: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: _bodyMuted,
                        height: 16 / 14,
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: model.rating.toDouble().toStringAsFixed(1),
                    size: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: kNeutralPrimary,
                    height: 16 / 12,
                  ),
                  width(4.w),
                  Icon(Icons.star_rounded, size: 14.sp, color: _starGold),
                ],
              ),
            ],
          ),
          if (model.review.trim().isNotEmpty) ...[
            height(12.h),
            CustomText(
              text: model.review.trim(),
              size: 14.sp,
              fontWeight: FontWeight.w400,
              color: _bodyMuted,
              height: 19.5 / 14,
            ),
          ],
        ],
      ),
    );
  }

  Widget _writeReviewFooter(BuildContext context, double bottomInset) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: Color(0xFFEBEFEA)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h + bottomInset),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: () {
            controller.calistaCafePageController.selectedRating.value = 0;
            controller.calistaCafePageController.reviewController.text = '';
            Get.toNamed(Routes.paymentfeedbackPageRoute, arguments: [
              controller.calistaCafePageController.model.value.id.toString(),
              kChargingStatusModel,
            ]);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrandPrimaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/write_review_pen.svg',
                width: 16.w,
                height: 16.w,
                fit: BoxFit.contain,
                clipBehavior: Clip.none,
                allowDrawingOutsideViewBox: true,
              ),
              width(10.w),
              CustomText(
                text: 'Write a Review',
                size: 16.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: Colors.white,
                height: 24 / 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'EV';
    if (parts.length == 1) {
      final s = parts.first;
      return (s.length >= 2 ? s.substring(0, 2) : s).toUpperCase();
    }
    return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
  }
}
