import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Circular glassmorphism icon button matching Figma:
/// fill #FFFFFF @ 15%, stroke 1.13px #FFFFFF @ 6% (inner), background blur 7.42.
class GlassCircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double? size;

  static const double _blurSigma = 7.42;
  static const double _borderWidth = 1.13;
  static const Color _fill = Color(0x26FFFFFF); // #FFFFFF @ 15%
  static const Color _stroke = Color(0x0FFFFFFF); // #FFFFFF @ 6%

  const GlassCircleIconButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? 44.w;
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: Material(
          color: _fill,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _stroke,
                  width: _borderWidth,
                ),
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard chevron back control used on Profile / Edit Profile / Station Detail headers.
class GlassBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double? size;

  const GlassBackButton({
    super.key,
    this.onTap,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? 44.w;
    return GlassCircleIconButton(
      onTap: onTap ?? Get.back,
      size: s,
      child: Transform.translate(
        offset: Offset(-1.w, 0),
        child: Icon(
          Icons.chevron_left_rounded,
          color: Colors.white,
          size: s * 0.82,
        ),
      ),
    );
  }
}
