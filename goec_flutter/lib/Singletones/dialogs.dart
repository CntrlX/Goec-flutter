import 'dart:async';
import 'dart:ui';
import 'app_data.dart';
import '../constants.dart';
import 'package:get/get.dart';
import '../Utils/routes.dart';
import '../Utils/toastUtils.dart';
import '../View/Widgets/apptext.dart';
import 'package:flutter/material.dart';
import '../Controller/qr_controller.dart';
import '../Model/activeSessionModel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Model/chargeTransactionModel.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/homepage_controller.dart';
// import 'package:freelancer_app/Utils/utils.dart';
import 'package:freelancer_app/Model/orderModel.dart';
import '../Controller/calista_cafePage_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freelancer_app/View/Widgets/customText.dart';
// import 'package:freelancer_app/Controller/qr_controller.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';
import 'package:freelancer_app/Singletones/map_functions.dart';
import 'package:freelancer_app/Utils/app_datetime.dart';
import 'package:freelancer_app/Utils/firebase_notifications.dart';
import 'package:freelancer_app/View/Charge/charge_transaction_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class Dialogs {
  //make it singleTone class
  static final Dialogs _singleton = Dialogs._internal();
  factory Dialogs() {
    return _singleton;
  }
  Dialogs._internal();

  /// Prevents permission sheets from re-opening while OS Settings is launching.
  bool suppressPermissionReprompt = false;

  tariffPopUp(ActiveSessionModel charger, String? stationName) {
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;

    RxInt second = 60.obs;
    Timer? timer;
    bool isClosed = false;

    void cleanupAndClose() {
      if (isClosed) return;
      isClosed = true;
      timer?.cancel();
      if (Get.currentRoute == Routes.qrScanPageRoute) {
        try {
          QrController qrController = Get.find();
          qrController.cameraController?.start();
        } catch (_) {}
      }
    }

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (second.value > 0) {
        second.value--;
      }
      if (second.value <= 0) {
        t.cancel();
        if (!isClosed) {
          Navigator.of(context, rootNavigator: true).maybePop();
          cleanupAndClose();
        }
      }
    });

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Initiate Charging Modal',
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
            Positioned.fill(
              child: FadeTransition(
                opacity: curved,
                child: GestureDetector(
                  onTap: () {
                    cleanupAndClose();
                    Navigator.of(ctx).maybePop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
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
                  child: _InitiateChargingSheetContent(
                    charger: charger,
                    stationName: stationName,
                    second: second,
                    onClose: () {
                      cleanupAndClose();
                      Navigator.of(ctx).maybePop();
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      cleanupAndClose();
    });
  }

  notEnoughCreditPopUp({double? balance}) {
    Get.dialog(
        AlertDialog(
            backgroundColor: kwhite,
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.w)),
            content: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
                height: 370.h,
                width: 360.w,
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                            text: 'Payments',
                            color: Color(0xff828282),
                            size: 15,
                            fontWeight: FontWeight.bold),
                        IconButton(
                          onPressed: () {
                            Get.back();
                            if (Get.currentRoute == Routes.qrScanPageRoute) {
                              // QrController _controller = Get.find();
                              // _controller.qrViewController?.resumeCamera();
                            }
                          },
                          icon: Icon(Icons.close),
                          splashRadius: 20,
                        )
                      ],
                    ),
                    Divider(),
                    Container(
                      height: 80.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffFFEBEB),
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/info-circle.png",
                          // height: 17,
                          width: 50.sp,
                        ),
                      ),
                    ),
                    height(10.h),
                    CustomBigText(
                      text: balance != null
                          ? "Balance is getting low!\nLess than ${appData.gettingLowAllertValue} Coins left"
                          : "Not Enough Credit\nto Charge",
                      size: 20.sp,
                      align: TextAlign.center,
                      color: Color(0xff4F4F4F),
                    ),
                    height(10.h),
                    CustomSmallText(
                      text: "Recharge for a minimum of 100 Coins",
                      size: 13.sp,
                      textAlign: TextAlign.center,
                    ),
                    height(10.h),
                    InkWell(
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.popupPageRoute);
                      },
                      child: Container(
                        height: 56.h,
                        width: 156.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          color: Color(0xff0047C3),
                        ),
                        child: Center(
                          child: CustomBigText(
                            text: "Recharge Now",
                            size: 15.sp,
                            color: Color(0xffF2F2F2),
                          ),
                        ),
                      ),
                    )
                  ],
                ))),
        barrierDismissible: false);
  }

  rechargePopUp({required bool isSuccess}) {
    Get.dialog(
        AlertDialog(
            backgroundColor: kwhite,
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.w)),
            content: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
                height: 370.h,
                width: 360.w,
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                            text: 'Payments',
                            color: Color(0xff828282),
                            size: 15,
                            fontWeight: FontWeight.bold),
                        IconButton(
                          onPressed: () {
                            Get.back();
                            if (Get.currentRoute == Routes.qrScanPageRoute) {
                              // QrController _controller = Get.find();
                              // _controller.qrViewController?.resumeCamera();
                            }
                          },
                          icon: Icon(Icons.close),
                          splashRadius: 20,
                        )
                      ],
                    ),
                    Divider(),
                    Container(
                      height: 80.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSuccess ? Color(0xffEBF8F1) : Color(0xffFFEBEB),
                      ),
                      child: Center(
                        child: Image.asset(
                          isSuccess
                              ? "assets/images/tick-circle.png"
                              : "assets/images/close-circle.png",
                          // height: 17,
                          width: 50.sp,
                        ),
                      ),
                    ),
                    height(10.h),
                    CustomBigText(
                      text: isSuccess
                          ? "Recharge is successful"
                          : "Recharge Failed",
                      size: 20.sp,
                      align: TextAlign.center,
                      color: Color(0xff4F4F4F),
                    ),
                    height(10.h),
                    CustomSmallText(
                        text: isSuccess ? 'Amount credited' : 'Amount'),
                    CustomText(
                        text: '${appData.rechargeAmount} Coins',
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4f4f4f)),
                    height(5.h),
                    CustomSmallText(
                      text: isSuccess
                          ? "Coins Successfully credited to your wallet"
                          : "Sorry for the inconvenience , Please try again",
                      size: 13.sp,
                      textAlign: TextAlign.center,
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () async {
                        if (isSuccess) {
                          Get.back();
                          Get.back();
                          HomePageController homeController = Get.find();
                          homeController.goToTab(0);
                          // CommonFunctions().createBookingAndCheck(
                          //     appData.qr, appData.tempActiveSessionModel);
                        } else {
                          Get.back();
                        }
                      },
                      child: Container(
                        height: 56.h,
                        width: 156.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          color: Color(0xff0047C3),
                        ),
                        child: Center(
                          child: CustomBigText(
                            text: isSuccess ? "Start Charging" : "Retry",
                            size: 15.sp,
                            color: Color(0xffF2F2F2),
                          ),
                        ),
                      ),
                    ),
                    height(5.h),
                  ],
                ))),
        barrierDismissible: false);
  }

  gunStatusAlert(String title, String subtitle) {
    Get.dialog(
        AlertDialog(
          backgroundColor: kwhite,
          elevation: 8,
          contentPadding: EdgeInsets.all(0),
          alignment: Alignment.topCenter,
          shadowColor: kblack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.w),
          ),
          content: Container(
            padding: EdgeInsets.all(10.w),
            height: 100.h,
            // width: 348.w,
            decoration: BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/gun.png',
                        height: 40,
                        width: 40,
                      ),
                      width(10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.montserrat(
                                  color: Color(0xff333333),
                                  fontWeight: FontWeight.w700),
                            ),
                            height(5.h),
                            Text(
                              subtitle,
                              style: GoogleFonts.montserrat(
                                  color: Color(0xff4f4f4f),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            child: Icon(Icons.close),
                            onTap: () {
                              Get.back();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        name: title);
  }

  wallet_transaction_popup({required OrderModel model, required int index}) {
    kLog(model.status);
    String title = '';
    Color color = Colors.transparent;
    if (model.status == 'success') {
      title = 'Success';
      color = Color(0xff219653);
    } else if (model.status == 'pending') {
      title = 'Pending';
      color = Color(0xffDF8600);
    } else {
      title = 'Failed';
      color = Color(0xffDC2525);
    }
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        // height: size.height * 0.63,
        width: size.width * 0.9,
        decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(20),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: size.width * 0.04,
                  right: size.width * 0.04,
                  top: size.height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBigText(
                    text: "Payments",
                    size: 14,
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset("assets/svg/close.svg"),
                    ),
                  ),
                ],
              ),
            ),
            height(size.height * 0.01),
            Divider(
              thickness: size.height * 0.002,
              color: Color(0xffE0E0E0),
            ),
            height(size.height * 0.02),
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.04,
                right: size.width * 0.04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/wallet_topup.svg',
                        width: size.width * 0.1,
                      ),
                      width(size.width * 0.04),
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.00),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSmallText(
                              text: model.type == 'wallet top-up'
                                  ? 'Wallet Topup'
                                  : model.type == 'charging deduction'
                                      ? 'Charging Deduction'
                                      : 'Admin topup',
                              letterspacing: -0.408,
                              size: 16,
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/calendar_month.svg",
                                  width: size.width * 0.045,
                                ),
                                width(size.width * 0.01),
                                CustomSmallText(
                                  text: AppDateTime.format(
                                    model.createdAt,
                                    useRawIfUnparsed: true,
                                  ),
                                  size: 12,
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  if (model.pgOrderId.isNotEmpty) ...[
                    height(size.height * .04),
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSmallText(text: 'Order ID'),
                          CustomBigText(text: model.pgOrderId),
                        ],
                      ),
                    ),
                  ],
                  height(size.height * .04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSmallText(text: 'Payment Type'),
                          height(size.height * 0.01),
                          CustomBigText(
                            text: model.type,
                            color: Color(0xff5C5C5C),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSmallText(text: 'Payment Status'),
                          height(size.height * 0.01),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * .03,
                                  vertical: size.width * 0.01),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: color.withValues(alpha: 0.3)),
                              child: CustomSmallText(
                                text: title,
                                color: color,
                                fontWeight: FontWeight.bold,
                                size: 12,
                              )),
                        ],
                      ),
                    ],
                  ),
                  height(size.height * .045),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.008,
                        horizontal: size.width * 0.04),
                    height: size.height * 0.095,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kwhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xff219653),
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomSmallText(
                          text: "Topup Added",
                          size: 12,
                        ),
                        height(size.height * 0.004),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomBigText(
                              text: "${model.amount.toStringAsFixed(2)}",
                              color: color,
                              size: 24,
                              fontWeight: FontWeight.w500,
                            ),
                            CustomSmallText(
                              text: " Coins",
                              size: 12,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  height(size.height * 0.04),
                  Visibility(
                    //HACK
                    // visible: title == 'Success' || title == 'Pending',
                    visible: false,
                    child: InkWell(
                      onTap: () {
                        /// on download invoice
                        // if (title == 'Success') {
                        //   CommonFunctions()
                        //       .downloadWalletInvoice(model.transactionId);
                        //   // kLog(model.bookingId.toString());
                        // } else if (title == 'Pending') {
                        //   WalletPageController _controller = Get.find();
                        //   _controller.verifyPayment(
                        //       model.transactionId, model.pgOrderId, index);
                        // }
                      },
                      child: title == 'Success'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/svg/download.svg'),
                                width(size.width * .02),
                                CustomBigText(
                                  text: 'Download invoice',
                                  color: Color(0xff0047C3),
                                  size: 15,
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  color: Color(0xffDF8600),
                                ),
                                width(size.width * .02),
                                CustomBigText(
                                  text: 'Verify Payment',
                                  color: Color(0xffDF8600),
                                  size: 15,
                                )
                              ],
                            ),
                    ),
                  ),
                  height(25.h),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  charge_transaction_popup({
    required ChargeTransactionModel model,
  }) {
    Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: EdgeInsets.all(0),
        content: ChargeTransactionDialog(model: model)));
  }

  connectPortTipDialog() {
    Get.dialog(
        Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: CustomText(text: 'Connect port please')),
        barrierDismissible: true);
  }

  Widget writeReviewDialog(CalistaCafePageController controller) {
    return AlertDialog(
      backgroundColor: kwhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.all(0),
      content: Container(
          padding: EdgeInsets.all(20.w),
          height: 460.h,
          width: 348.w,
          decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 32,
                  color: Color(0xff000000).withValues(alpha: 0.06),
                )
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomSmallText(
                text: "How is your Experience?",
                size: 16.sp,
                letterspacing: -0.41,
              ),
              height(20.h),
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                        5,
                        (index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectedRating.value = index + 1;
                                },
                                child: Image.asset(
                                  controller.selectedRating.value == 0 ||
                                          controller.selectedRating.value - 1 <
                                              index
                                      ? "assets/images/emojis/gray${index + 1}.png"
                                      : "assets/images/emojis/yellow${index + 1}.png",
                                  height: 35.w,
                                  // width: 40.w,
                                ),
                              ),
                            )),
                  ),
                ),
              ),
              height(20.h),
              TextFormField(
                minLines: 7,
                maxLines: 7,
                controller: controller.reviewController,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    hintText: "Leave Your Feedback here",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Color(0xff908484),
                        )),
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.41,
                        color: Color(0xffBDBDBD)),
                    contentPadding: EdgeInsets.only(left: 20.w, top: 25.h)),
              ),
              height(20.h),
              _button(
                  button: "Leave feedback",
                  onTap: () async {
                    bool status = await controller.postReviewForChargeStation();
                    if (status) Get.dialog(_responseDialougebox());
                  }),
              height(20.h),
              CustomBigText(
                ontap: () {
                  Get.back();
                },
                text: "Cancel",
                size: 15.sp,
                color: Color(0xff0047C3),
              )
            ],
          )),
    );
  }

  Widget _button({required String button, required void Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 55.h,
        width: 237.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.r),
          color: Color(0xff0047C3),
        ),
        child: Center(
          child: CustomBigText(
            text: button,
            size: 14.sp,
            color: Color(0xffF2F2F2),
          ),
        ),
      ),
    );
  }

  Widget _responseDialougebox() {
    return AlertDialog(
      backgroundColor: kwhite,
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
      content: Container(
        padding: EdgeInsets.all(20.w),
        // height: 265.h,
        width: 348.w,
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80.h,
              width: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffEBF8F1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2.w,
                          color: Color(0xff05A660),
                        )),
                    child: Center(
                      child: Image.asset(
                        "assets/images/vector1.png",
                        height: 17,
                        width: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            height(15.h),
            CustomBigText(
              text: "Thank you for your response",
              size: 20.sp,
              align: TextAlign.center,
              color: Color(0xff4F4F4F),
            ),
            height(10.h),
            CustomSmallText(
              text: "Your response has been added",
              size: 13.sp,
            ),
            height(10.h),
            InkWell(
              onTap: () {
                Get.offAllNamed(Routes.homePageRoute);
              },
              child: Container(
                height: 56.h,
                width: 156.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40.r),
                  color: Color(0xff0047C3),
                ),
                child: Center(
                  child: CustomBigText(
                    text: "Back to Maps",
                    size: 15.sp,
                    color: Color(0xffF2F2F2),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// App location permission sheet (OS permission for GOEC).
  Future<void> showLocationPermissionSheet({
    VoidCallback? onEnabled,
    bool permanentlyDenied = false,
  }) {
    return _showPermissionPromptSheet(
      accentLabel: 'Location Access',
      body:
          'Allow GOEC to use your location to find nearby charging stations, check availability, and get accurate directions.',
      ctaLabel: permanentlyDenied ? 'Open Settings' : 'Allow Location',
      artAsset: 'assets/images/location_permission_art.png',
      onCta: () async {
        final maps = MapFunctions();
        final state = await maps.getLocationAccessState();
        if (state == LocationAccessState.granted) {
          Get.back();
          onEnabled?.call();
          return;
        }
        if (state == LocationAccessState.serviceDisabled) {
          Get.back();
          await showDeviceLocationSheet(onEnabled: onEnabled);
          return;
        }

        // Permanent deny (or sheet already marked as such): app settings only.
        if (state == LocationAccessState.permissionDeniedForever ||
            permanentlyDenied) {
          await _openAppSettingsFromSheet();
          return;
        }

        // Soft deny: try the system prompt once.
        final granted = await maps.checkLocationPermission();
        if (granted) {
          Get.back();
          onEnabled?.call();
          return;
        }

        // Still denied (or OS won't show the prompt again) → Settings.
        await _openAppSettingsFromSheet();
      },
    );
  }

  /// Device GPS / Location Services sheet (system location toggle).
  Future<void> showDeviceLocationSheet({
    VoidCallback? onEnabled,
  }) {
    return _showPermissionPromptSheet(
      accentLabel: 'Device Location',
      body:
          'Location services are turned off on your phone. Enable them in system settings so we can show nearby chargers and directions.',
      ctaLabel: 'Turn On Location',
      artAsset: 'assets/images/location_permission_art.png',
      onCta: () async {
        if (await Geolocator.isLocationServiceEnabled()) {
          Get.back();
          onEnabled?.call();
          return;
        }
        await _openDeviceLocationSettingsFromSheet();
      },
    );
  }

  /// Opens app settings without dismissing/re-showing the permission sheet.
  Future<void> _openAppSettingsFromSheet() async {
    suppressPermissionReprompt = true;
    final opened = await openAppSettings();
    if (!opened) {
      await Geolocator.openAppSettings();
    }
  }

  /// Opens device location settings without sheet churn.
  Future<void> _openDeviceLocationSettingsFromSheet() async {
    suppressPermissionReprompt = true;
    await Geolocator.openLocationSettings();
  }

  /// Camera permission for QR scanning.
  Future<void> showCameraPermissionSheet({
    VoidCallback? onEnabled,
    bool permanentlyDenied = false,
  }) {
    return _showPermissionPromptSheet(
      accentLabel: 'Camera Access',
      body: permanentlyDenied
          ? 'Camera access is blocked. Open Settings and allow Camera for GOEC to scan charger QR codes.'
          : 'Allow camera access to scan QR codes on charging stations and start charging quickly.',
      ctaLabel: permanentlyDenied ? 'Open Settings' : 'Allow Camera',
      artIcon: Icons.qr_code_scanner_rounded,
      onCta: () async {
        if (permanentlyDenied) {
          await _openAppSettingsFromSheet();
          return;
        }
        final status = await Permission.camera.request();
        if (status.isGranted) {
          Get.back();
          onEnabled?.call();
        } else {
          await _openAppSettingsFromSheet();
        }
      },
    );
  }

  /// Push notification permission.
  Future<void> showNotificationPermissionSheet({
    VoidCallback? onEnabled,
    bool permanentlyDenied = false,
  }) {
    return _showPermissionPromptSheet(
      accentLabel: 'Notifications',
      body: permanentlyDenied
          ? 'Notifications are blocked. Open Settings and allow notifications so you don’t miss charging updates.'
          : 'Stay updated on charging sessions, payments, and important alerts from GOEC.',
      ctaLabel: permanentlyDenied ? 'Open Settings' : 'Enable Notifications',
      artAsset: 'assets/images/notif_empty_img.png',
      onCta: () async {
        // Always try the system prompt first unless OS says it's permanent.
        final forever = permanentlyDenied ||
            await FireBaseNotification().isPermanentlyDenied();
        if (forever) {
          await _openAppSettingsFromSheet();
          return;
        }
        final ok = await FireBaseNotification().requestPermission();
        if (ok) {
          Get.back();
          onEnabled?.call();
          return;
        }
        // Soft deny: keep sheet. Only jump to Settings if now permanent.
        if (await FireBaseNotification().isPermanentlyDenied()) {
          await _openAppSettingsFromSheet();
        }
      },
    );
  }

  Future<void> _showPermissionPromptSheet({
    required String accentLabel,
    required String body,
    required String ctaLabel,
    required Future<void> Function() onCta,
    String? artAsset,
    IconData? artIcon,
  }) async {
    if (Get.isBottomSheetOpen == true) return;
    if (suppressPermissionReprompt) return;

    final context = Get.context;
    if (context == null) return;

    final artSize = 184.w;
    final artOverhang = 109.h;
    final sheetTopInset = 75.h;
    final bottomInset = systemBottomInset(context);

    Widget buildArt() {
      if (artAsset != null) {
        return Image.asset(
          artAsset,
          width: artSize,
          height: artSize,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => SizedBox(
            width: artSize,
            height: artSize,
          ),
        );
      }
      // Brand icon badge when no illustration asset (camera, etc.).
      return Container(
        width: artSize,
        height: artSize,
        alignment: Alignment.center,
        child: Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: kOnboardingGradient,
            boxShadow: [
              BoxShadow(
                color: kBrandPrimaryBlue.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            artIcon ?? Icons.lock_outline_rounded,
            size: 52.sp,
            color: Colors.white,
          ),
        ),
      );
    }

    await Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(top: artOverhang),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36.r),
                    topRight: Radius.circular(36.r),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  sheetTopInset,
                  16.w,
                  16.h + bottomInset,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: kNeutralPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'Enable '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) =>
                                  kOnboardingGradient.createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                              child: Text(
                                accentLabel,
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  height: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    height(16.h),
                    CustomText(
                      text: body,
                      size: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: kNeutralSecondary,
                      textAlign: TextAlign.center,
                      height: 1.2,
                    ),
                    height(24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          await onCta();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandPrimaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                        ),
                        child: CustomText(
                          text: ctaLabel,
                          size: 16.sp,
                          fontWeight: FontWeight.w700,
                          height: 24 / 16,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildArt(),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.21),
      isDismissible: true,
      enableDrag: true,
    );
  }
}

saveSnack(String message) {
  return Get.snackbar("", "",
      padding: EdgeInsets.all(0),
      titleText: Container(),
      messageText: Center(
          child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SvgPicture.asset("assets/svg/successful.svg"),
                  ),
                  width(15),
                  CustomBigText(
                    text: message,
                    color: Colors.white,
                  ),
                ],
              ))),
      backgroundColor: Color(0xff6fcf97));
}

class _InitiateChargingSheetContent extends StatelessWidget {
  final ActiveSessionModel charger;
  final String? stationName;
  final RxInt second;
  final VoidCallback onClose;

  const _InitiateChargingSheetContent({
    required this.charger,
    required this.stationName,
    required this.second,
    required this.onClose,
  });

  String _vehicleLabel() {
    final v = appData.userModel.value.defaultVehicle;
    final brand = v.brand.trim();
    final model = v.modelName.trim();
    if (brand.isEmpty && model.isEmpty) return 'Add vehicle';
    if (brand.isEmpty) return model;
    if (model.isEmpty) return brand;
    return '$brand $model';
  }

  Widget _infoRow({
    required String label,
    required String value,
    bool showChevron = false,
    VoidCallback? onTap,
    Widget? leading,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading,
              width(8.w),
            ],
            Expanded(
              child: CustomText(
                text: label,
                size: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 20 / 14,
              ),
            ),
            width(12.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: value,
                  size: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  height: 20 / 14,
                ),
                if (showChevron) ...[
                  width(4.w),
                  Icon(
                    Icons.chevron_right,
                    size: 18.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = systemBottomInset(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF011631).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle bar
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 20.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: 'Initiate Charging',
                    size: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    height: 28 / 18,
                  ),
                ),
                Obx(
                  () => Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14.sp,
                          color: const Color(0xFF0049C2),
                        ),
                        width(4.w),
                        Text(
                          '${second.value}s',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0049C2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                width(10.w),
                Material(
                  color: const Color(0xFFF1F5F9),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onClose,
                    child: SizedBox(
                      width: 32.w,
                      height: 32.w,
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                // Highlight Card: Connector & Rate
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'CONNECTOR & POWER',
                              size: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                            height(4.h),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/css.svg',
                                  width: 14.w,
                                  height: 14.w,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF0049C2),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                width(6.w),
                                Expanded(
                                  child: CustomText(
                                    text: charger.connectorType.isNotEmpty
                                        ? charger.connectorType
                                        : 'Connector',
                                    size: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            height(2.h),
                            CustomText(
                              text:
                                  '${charger.outputType.isNotEmpty ? charger.outputType : "DC"} · ${charger.capacity} kW',
                              size: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                      width(12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(
                            text: 'TARIFF',
                            size: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                          height(4.h),
                          CustomText(
                            text:
                                '$kCurrency ${charger.tariff.toStringAsFixed(2)} /kWh',
                            size: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0049C2),
                          ),
                          height(2.h),
                          CustomText(
                            text: 'Base rate',
                            size: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                height(16.h),

                // Station name (if provided)
                if (stationName != null && stationName!.trim().isNotEmpty) ...[
                  _infoRow(
                    label: 'Station',
                    value: stationName!.trim(),
                  ),
                  height(4.h),
                ],

                // Charger Name
                _infoRow(
                  label: 'Charger',
                  value: charger.chargerName,
                ),
                height(4.h),

                // Vehicle
                Obx(
                  () => _infoRow(
                    label: 'Vehicle',
                    value: _vehicleLabel(),
                    showChevron: true,
                    onTap: () {
                      onClose();
                      Get.toNamed(Routes.myvehicleRoute);
                    },
                  ),
                ),
                height(4.h),

                // Payment / Wallet
                Obx(
                  () => _infoRow(
                    label: 'Wallet Balance',
                    value:
                        '$kCurrency${appData.userModel.value.balanceAmount.toStringAsFixed(0)}',
                    showChevron: true,
                    onTap: () {
                      onClose();
                      Get.toNamed(Routes.walletPageRoute);
                    },
                  ),
                ),

                height(20.h),
              ],
            ),
          ),

          // Bottom Button Container
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: SizedBox(
              height: 54.h,
              child: ElevatedButton(
                onPressed: () async {
                  onClose();
                  showLoading('Connecting to charger...');
                  bool success = await CommonFunctions().startCharging(
                    connectorId: charger.connectorId,
                    cpid: charger.cpid,
                  );
                  hideLoading();
                  if (success) {
                    Get.offNamedUntil(
                      Routes.chargingPageRoute,
                      ModalRoute.withName(Routes.homePageRoute),
                    );
                  } else {
                    showError(
                      'Failed to connect with charger. Please try again later!',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0049C2),
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
                  letterSpacing: 0.3,
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

