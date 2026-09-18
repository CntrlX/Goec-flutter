import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_shimmer.dart';

/// Skeleton for the "Choose a connector" block on Station Detail.
/// Mirrors live connector card geometry so the swap-in feels seamless.
class StationDetailConnectorsShimmer extends StatelessWidget {
  final int itemCount;

  const StationDetailConnectorsShimmer({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            if (i > 0) SizedBox(height: 12.h),
            const _ConnectorCardBone(),
          ],
        ],
      ),
    );
  }
}

class _ConnectorCardBone extends StatelessWidget {
  const _ConnectorCardBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE6EAEF)),
      ),
      child: Row(
        children: [
          ShimmerCircle(size: 44.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140.w, height: 14.h, radius: 6),
                SizedBox(height: 8.h),
                ShimmerBox(width: 88.w, height: 12.h, radius: 6),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 64.w, height: 22.h, radius: 999),
              SizedBox(height: 8.h),
              ShimmerBox(width: 52.w, height: 12.h, radius: 6),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact amenity-chip row skeleton (optional secondary use).
class StationDetailAmenitiesShimmer extends StatelessWidget {
  const StationDetailAmenitiesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) SizedBox(width: 8.w),
              ShimmerBox(width: 72.w + (i % 2) * 16.w, height: 28.h, radius: 999),
            ],
          ],
        ),
      ),
    );
  }
}
