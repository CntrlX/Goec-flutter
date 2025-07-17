import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:freelancer_app/View/Widgets/apptext.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/Controller/qr_controller.dart';

class QrScreen extends GetView<QrController> {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var iskeybort = (MediaQuery.of(context).viewInsets.bottom != 0).obs;
    return Scaffold(
      backgroundColor: iskeybort.value == true
          ? Color.fromARGB(255, 110, 110, 110)
          : Colors.transparent,
      body: Obx(() {
        return SafeArea(
          child: Stack(children: [
            // if (!iskeybort.value)
            MobileScanner(
              // startDelay: true,
              errorBuilder: (context, error, child) {
                controller.cameraController.stop();
                controller.cameraController.start();
                return Container();
              },
              controller: controller.cameraController,
              // overlay: Container(
              //   decoration: ShapeDecoration(shape: QrScannerOverlayShape()),
              // ),
              overlayBuilder: (context, constraints) => Container(
                decoration: ShapeDecoration(shape: QrScannerOverlayShape()),
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  controller.onQrCodeReceived(barcode.rawValue);
                }
              },
            ),
            // if (!iskeybort.value)
            // QRView(
            //   key: controller.qrKey,
            //   onQRViewCreated: onQRViewCreated,
            //   // overlay: _overlay(),
            // ),
            Positioned(
                right: 22.w,
                left: 22.w,
                top: 15.h,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                        onTap: () {
                          controller.cameraController.dispose();
                          Get.back();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    if (!iskeybort.value)
                      SizedBox(
                        width: 203.w,
                        child: CustomBigText(
                          text: "Align the QR Code within theFrame to Scan",
                          color: Colors.white,
                          size: 14.sp,
                          align: TextAlign.center,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                )),
            Positioned(
                bottom: iskeybort == true ? 60.h : 34.h,
                left: 22.w,
                right: 22.w,
                child: _otpContainer(context, controller))
          ]),
        );
      }),
    );
  }

  // void onQRViewCreated(QRViewController qrViewController) {
  //   controller.qrViewController = qrViewController;
  //   controller.qrViewController!.scannedDataStream.listen((event) {
  //     // controller.onQrCodeReceived(event);
  //   });
  // }

  Widget _otpContainer(BuildContext context, QrController controller) {
    return Container(
      width: 347.sw,
      height: 150.h,
      padding:
          EdgeInsets.only(top: 16.h, left: 27.w, right: 27.w, bottom: 25.h),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30.r)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CustomBigText(
          text: 'Scan Qr to Charge',
          color: Color(0xff828282),
          size: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(
          height: 20.h,
        ),
        CustomBigText(
          text: 'Scan QR on charging station to start charging',
          color: Color(0xff828282),
          size: 16.sp,
          align: TextAlign.center,
          fontWeight: FontWeight.w500,
        ),
        // PinCodeTextField(
        //     appContext: context,
        //     length: 5,
        //     pinTheme: PinTheme(
        //       fieldHeight: 64.h,
        //       fieldWidth: 47.w,
        //       shape: PinCodeFieldShape.box,
        //       borderRadius: BorderRadius.circular(38.r),
        //       borderWidth: .805,
        //       selectedFillColor: Color.fromARGB(255, 65, 65, 65),
        //       inactiveColor: Color(0xffBDBDBD),
        //     ),
        //     onChanged: (valu) {
        //      valu);
        //     }),
        // SizedBox(
        //   height: 15.h,
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     CustomSmallText(
        //       text: "Time remining is ${controller.otpTimer.toString()}s",
        //       size: 12.sp,
        //       color: Color(0xff828282),
        //       ontap: () {},
        //     ),
        //     CustomSmallText(
        //       text: "Resend OTP",
        //       size: 14.sp,
        //       color: Color(0xff0047C3),
        //       ontap: () {},
        //     )
        //   ],
        // ),
        // SizedBox(
        //   height: 28.h,
        // ),
        // MainBtn(
        //   text: "Proceed",
        //   onPressed: () {
        //     /// whatever needed if code is entered.
        //     appData.qr = '444-t1-1-Q';
        //     CommonFunctions().createBookingAndCheck(appData.qr);
        //   },
        // )
      ]),
    );
  }

  // QrScannerOverlayShape? _overlay() {
  //   return QrScannerOverlayShape(
  //     borderColor: Colors.white,
  //     borderLength: 80,
  //     borderRadius: 20,
  //     borderWidth: 10,
  //     cutOutBottomOffset: 127.h,
  //     cutOutSize: 247.w,
  //     overlayColor: Color.fromARGB(183, 0, 0, 0),
  //   );
  // }
}

class QrScannerOverlayShape extends ShapeBorder {
  QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 7.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 2,
    this.borderLength = 40,
    double? cutOutSize,
    double? cutOutWidth,
    double? cutOutHeight,
    this.cutOutBottomOffset = 0,
  })  : cutOutWidth = cutOutWidth ?? cutOutSize ?? 250,
        cutOutHeight = cutOutHeight ?? cutOutSize ?? 250 {
    assert(
      borderLength <=
          min(this.cutOutWidth, this.cutOutHeight) / 2 + borderWidth * 2,
      "Border can't be larger than ${min(this.cutOutWidth, this.cutOutHeight) / 2 + borderWidth * 2}",
    );
    assert(
        (cutOutWidth == null && cutOutHeight == null) ||
            (cutOutSize == null && cutOutWidth != null && cutOutHeight != null),
        'Use only cutOutWidth and cutOutHeight or only cutOutSize');
  }

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutWidth;
  final double cutOutHeight;
  final double cutOutBottomOffset;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final mBorderLength =
        borderLength > min(cutOutHeight, cutOutHeight) / 2 + borderWidth * 2
            ? borderWidthSize / 2
            : borderLength;
    final mCutOutWidth =
        cutOutWidth < width ? cutOutWidth : width - borderOffset;
    final mCutOutHeight =
        cutOutHeight < height ? cutOutHeight : height - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - mCutOutWidth / 2 + borderOffset,
      -cutOutBottomOffset +
          rect.top +
          height / 2 -
          mCutOutHeight / 2 +
          borderOffset,
      mCutOutWidth - borderOffset * 2,
      mCutOutHeight - borderOffset * 2,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      // Draw top right corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - mBorderLength,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + mBorderLength,
          topRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw top left corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.top,
          cutOutRect.left + mBorderLength,
          cutOutRect.top + mBorderLength,
          topLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw bottom right corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - mBorderLength,
          cutOutRect.bottom - mBorderLength,
          cutOutRect.right,
          cutOutRect.bottom,
          bottomRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw bottom left corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.bottom - mBorderLength,
          cutOutRect.left + mBorderLength,
          cutOutRect.bottom,
          bottomLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      ..restore();
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
