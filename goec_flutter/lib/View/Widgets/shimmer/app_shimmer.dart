import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Brand-aligned shimmer surface used across skeleton loaders.
///
/// Base / highlight colours match GOEC neutrals so skeletons feel native
/// on white sheets (station detail, lists, cards).
class AppShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;

  static const Color baseColor = Color(0xFFE8EEF5);
  static const Color highlightColor = Color(0xFFF7FAFC);

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// Rounded rectangle bone.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

/// Circular bone (avatars / icon badges).
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Text-line bone with optional fraction of parent width.
class ShimmerLine extends StatelessWidget {
  final double height;
  final double widthFactor;
  final double radius;

  const ShimmerLine({
    super.key,
    this.height = 12,
    this.widthFactor = 1,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor.clamp(0.05, 1.0),
      alignment: Alignment.centerLeft,
      child: ShimmerBox(height: height.h, radius: radius),
    );
  }
}
