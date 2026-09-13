import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class GlassCircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double? size;

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
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Material(
          color: Colors.white.withValues(alpha: 0.15),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.2,
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

/// Standard chevron back control used on Profile / Edit Profile headers.
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
      child: Icon(
        Icons.chevron_left_rounded,
        color: Colors.white,
        size: (s * 0.64).clamp(28.0, 34.0),
      ),
    );
  }
}
