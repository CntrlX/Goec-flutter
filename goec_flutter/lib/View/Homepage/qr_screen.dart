import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants.dart';
import '../../Controller/qr_controller.dart';
import '../Widgets/customText.dart';
import '../Widgets/glass_circle_icon_button.dart';

class QrScreen extends GetView<QrController> {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Obx(() {
          final ready = controller.hasCameraPermission.value;
          final checking = controller.checkingPermission.value;
          final deniedForever = controller.permanentlyDenied.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              if (ready && controller.cameraController != null)
                MobileScanner(
                  controller: controller.cameraController!,
                  errorBuilder: (context, error, child) {
                    return _CameraBlockedPanel(
                      permanentlyDenied: deniedForever,
                      onAllow: () => controller.ensureCameraPermission(),
                      onOpenSettings: controller.openCameraSettings,
                    );
                  },
                  overlayBuilder: (context, constraints) => Container(
                    decoration: ShapeDecoration(
                      shape: QrScannerOverlayShape(
                        borderColor: Colors.white,
                        borderWidth: 4,
                        borderRadius: 16,
                        borderLength: 36,
                        cutOutSize: 260.w,
                        cutOutBottomOffset: 40.h,
                        overlayColor: const Color(0x990B1220),
                      ),
                    ),
                  ),
                  onDetect: (capture) {
                    for (final barcode in capture.barcodes) {
                      controller.onQrCodeReceived(barcode.rawValue);
                    }
                  },
                )
              else
                _CameraBlockedPanel(
                  permanentlyDenied: deniedForever,
                  checking: checking,
                  onAllow: () => controller.ensureCameraPermission(),
                  onOpenSettings: controller.openCameraSettings,
                ),

              // Top chrome
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GlassCircleIconButton(
                            onTap: () => Get.back(),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CustomText(
                              text: 'Scan QR',
                              fontFamily: kFontFamily,
                              size: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      if (ready)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28.w),
                          child: CustomText(
                            text:
                                'Align the QR code inside the frame to start charging',
                            fontFamily: kFontFamily,
                            size: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                            textAlign: TextAlign.center,
                            height: 1.35,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom info card
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 16.h + bottomInset,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: kNeutralPrimary,
                          ),
                          children: [
                            const TextSpan(text: 'Scan to '),
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
                                  'Charge',
                                  style: TextStyle(
                                    fontFamily: kFontFamily,
                                    fontSize: 20.sp,
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
                      SizedBox(height: 10.h),
                      CustomText(
                        text:
                            'Scan the QR on the charging station to begin your session instantly.',
                        fontFamily: kFontFamily,
                        size: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: kNeutralSecondary,
                        textAlign: TextAlign.center,
                        height: 1.35,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CameraBlockedPanel extends StatelessWidget {
  final bool permanentlyDenied;
  final bool checking;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;

  const _CameraBlockedPanel({
    required this.permanentlyDenied,
    required this.onAllow,
    required this.onOpenSettings,
    this.checking = false,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1220),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: checking
              ? CircularProgressIndicator(
                  color: kBrandPrimaryBlue,
                  strokeWidth: 2.5,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88.w,
                      height: 88.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 40.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomText(
                      text: permanentlyDenied
                          ? 'Camera access is blocked'
                          : 'Camera access needed',
                      fontFamily: kFontFamily,
                      size: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    CustomText(
                      text: permanentlyDenied
                          ? 'Open Settings and allow Camera for GOEC to scan charger QR codes.'
                          : 'Allow camera access to scan QR codes on charging stations.',
                      fontFamily: kFontFamily,
                      size: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
                      textAlign: TextAlign.center,
                      height: 1.4,
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed:
                            permanentlyDenied ? onOpenSettings : onAllow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandPrimaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                        ),
                        child: CustomText(
                          text: permanentlyDenied
                              ? 'Open Settings'
                              : 'Allow Camera',
                          size: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
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
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
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
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
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
