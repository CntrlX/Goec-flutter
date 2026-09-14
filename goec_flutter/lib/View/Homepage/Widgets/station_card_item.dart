import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../../../Model/stationMarkerModel.dart';
import '../../../Singletones/map_functions.dart';
import '../../../Utils/utils.dart';
import '../../../constants.dart';

class StationCardItem extends StatelessWidget {
  final StationMarkerModel station;
  final VoidCallback onTap;

  const StationCardItem({
    super.key,
    required this.station,
    required this.onTap,
  });

  double _calculateAccurateDistanceKm() {
    try {
      final userLat = MapFunctions().curPos.latitude;
      final userLng = MapFunctions().curPos.longitude;
      if (userLat != 0 &&
          userLng != 0 &&
          station.latitude != 0 &&
          station.longitude != 0) {
        final meters = Geolocator.distanceBetween(
          userLat,
          userLng,
          station.latitude,
          station.longitude,
        );
        return meters / 1000.0;
      }
    } catch (_) {}
    return 0.0;
  }

  int _estimateDriveTimeMinutes(double distanceKm) {
    if (distanceKm <= 0) return 1;
    // Average urban driving speed of 35 km/h
    final minutes = (distanceKm / 35.0 * 60).round();
    return minutes < 1 ? 1 : minutes;
  }

  bool _isOpen24Hours() {
    final start = station.startTime.trim();
    final stop = station.stopTime.trim();
    if (start.isEmpty || stop.isEmpty) return true;
    return (start == '00:00' && (stop == '23:59' || stop == '24:00')) ||
        start.toLowerCase().contains('24') ||
        start == stop;
  }

  String _connectorLabel(dynamic connector) {
    final type = connector.toString().trim();
    if (type.isEmpty) return 'Connector';

    final cap = station.charger_capacity.trim();
    if (cap.isEmpty) return type;

    final lower = type.toLowerCase();
    if (lower.contains(cap.toLowerCase()) || lower.contains('kw')) {
      return type;
    }
    final capLabel = cap.toLowerCase().contains('kw') ? cap : '$cap kW';
    return '$type $capLabel';
  }

  Widget _connectorChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          color: const Color(0xFF68768E),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distanceKm = _calculateAccurateDistanceKm();
    final etaMins = _estimateDriveTimeMinutes(distanceKm);
    final isAvailable = station.charger_status.toLowerCase() == 'available' ||
        station.charger_status.toLowerCase() == 'online';

    final ratingStr = station.rating > 0
        ? station.rating.toStringAsFixed(1)
        : '4.8';

    final distanceStr =
        distanceKm > 0 ? '${distanceKm.toStringAsFixed(1)} km' : '-- km';

    final connectors = <String>[
      ...station.charger_type
          .map(_connectorLabel)
          .where((e) => e.trim().isNotEmpty),
    ];
    if (connectors.isEmpty) {
      connectors.add(_connectorLabel(
        station.charger_capacity.isNotEmpty ? 'CCS2' : 'Connector',
      ));
    }

    final open24h = _isOpen24Hours();
    final hoursLine = open24h
        ? 'Open 24/7'
        : '${convertToPmFormat(station.startTime)} – ${convertToPmFormat(station.stopTime)}';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Station Title & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    station.name.isNotEmpty
                        ? station.name
                        : 'Charging Station',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      height: 19.25 / 16,
                      color: const Color(0xFF121D31),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(
                      color: isAvailable
                          ? const Color(0xFFA7F3D0).withValues(alpha: 0.5)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFF059669)
                              : const Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          height: 16 / 12,
                          color: isAvailable
                              ? const Color(0xFF059669)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),

            // Row 2: Star Rating • Distance • Travel Time
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 17.sp,
                  color: const Color(0xFFF59E0B),
                ),
                SizedBox(width: 3.w),
                Text(
                  ratingStr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    height: 16 / 14,
                    color: const Color(0xFF121D31),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 16 / 12,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  distanceStr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 16 / 14,
                    color: const Color(0xFFA0AABD),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 16 / 12,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 14.sp,
                  color: kBrandPrimaryBlue,
                ),
                SizedBox(width: 3.w),
                Text(
                  '$etaMins mins',
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 16 / 14,
                    color: kBrandPrimaryBlue,
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF1F5F9),
              ),
            ),

            // Row 3: connectors stacked (Figma), tariff + hours on the right
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < connectors.length; i++) ...[
                        if (i > 0) SizedBox(height: 6.h),
                        _connectorChip(connectors[i]),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${kCurrency}18.50/kWh',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        color: const Color(0xFF68768E),
                      ),
                    ),
                    Text(
                      hoursLine,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        color: const Color(0xFF68768E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
