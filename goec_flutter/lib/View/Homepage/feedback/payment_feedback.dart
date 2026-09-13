import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/Controller/feedback_page_controller.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/View/Widgets/customText.dart';
import 'package:freelancer_app/View/Widgets/glass_circle_icon_button.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';

/// Write a Review — Figma frames 162:4959 (invalid) / 162:5165 (valid).
/// Submit footer appears only when a rating is selected and review text is typed.
class PaymentFeedbackScreen extends GetView<FeedBackPageController> {
  const PaymentFeedbackScreen({super.key});

  static const _pageBg = Color(0xFFF6F8FA);
  static const _cardBorder = Color(0xFFE6EAEF);
  static const _muted = Color(0xFF68768E);
  static const _hint = Color(0xFFA0AABD);
  static const _starEmpty = Color(0xFFE2E8F0);
  static const _starFilled = Color(0xFFFBBF24);
  static const _footerBorder = Color(0xFFEBEFEA);

  @override
  Widget build(BuildContext context) {
    final bottomInset = systemBottomInset(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        body: Column(
          children: [
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(22.w, 25.h, 22.w, 24.h),
                child: Column(
                  children: [
                    _ratingCard(),
                    height(24.h),
                    _reviewSection(),
                  ],
                ),
              ),
            ),
            Obx(() {
              // Rebuild when rating or text length changes.
              final _ = controller.selectedRating.value;
              final __ = controller.reviewLength.value;
              if (!controller.canSubmit) return const SizedBox.shrink();
              return _submitFooter(context, bottomInset);
            }),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return Container(
      width: double.infinity,
      color: kBrandPrimaryBlue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(17.w, 6.h, 17.w, 14.h),
          child: Row(
            children: [
              const GlassBackButton(),
              width(12.w),
              CustomText(
                text: 'Write a Review',
                size: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 28.5 / 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          CustomText(
            text: 'How was your charging experience?',
            size: 16.sp,
            fontWeight: FontWeight.w700,
            color: kNeutralPrimary,
            textAlign: TextAlign.center,
            height: 24 / 16,
          ),
          height(4.h),
          CustomText(
            text: 'Tap a star to rate',
            size: 12.sp,
            fontWeight: FontWeight.w500,
            color: _muted,
            textAlign: TextAlign.center,
            height: 16 / 12,
          ),
          height(12.h),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                final filled = controller.selectedRating.value >= star;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: GestureDetector(
                    onTap: () => controller.setRating(star),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        Icons.star_rounded,
                        size: 36.sp,
                        color: filled ? _starFilled : _starEmpty,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomText(
                text: 'Your Review',
                size: 14.sp,
                fontWeight: FontWeight.w600,
                color: kNeutralPrimary,
                letterSpacing: 0.6,
                height: 16 / 14,
              ),
            ),
            Obx(
              () => CustomText(
                text:
                    '${controller.reviewLength.value} / ${FeedBackPageController.maxReviewLength}',
                size: 12.sp,
                fontWeight: FontWeight.w500,
                color: _muted,
                height: 16.5 / 12,
              ),
            ),
          ],
        ),
        height(8.h),
        Container(
          width: double.infinity,
          height: 164.h,
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 19.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _cardBorder),
          ),
          child: TextField(
            controller: controller.feedbackController,
            maxLength: FeedBackPageController.maxReviewLength,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: kNeutralPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              border: InputBorder.none,
              hintText:
                  'Describe charging speed, connector condition, parking access, or nearby amenities...',
              hintStyle: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: _hint,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitFooter(BuildContext context, double bottomInset) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: _footerBorder),
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
            FocusScope.of(context).unfocus();
            controller.postReviewForChargeStation(context);
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
            text: 'Submit Review',
            size: 16.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: Colors.white,
            height: 24 / 16,
          ),
        ),
      ),
    );
  }
}
