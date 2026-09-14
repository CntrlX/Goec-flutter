import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants.dart';
import '../../Utils/routes.dart';
import '../../Singletones/app_data.dart';
import '../../Singletones/map_functions.dart';
import '../../Controller/homepage_controller.dart';
import 'Widgets/station_card_item.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  final HomePageController controller = Get.find<HomePageController>();
  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  final RxDouble sheetExtent = 0.44.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sheetController.addListener(_onSheetScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.station_marker_list.isEmpty) {
        controller.onReload();
      }
    });
  }

  void _onSheetScroll() {
    if (sheetController.isAttached) {
      sheetExtent.value = sheetController.size;
    }
  }

  @override
  void dispose() {
    sheetController.removeListener(_onSheetScroll);
    sheetController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Google Map
          Positioned.fill(
            child: Obx(
              () => Container(
                padding: EdgeInsets.all(controller.reload.value * 0 +
                    MapFunctions().reload.value * 0),
                child: GoogleMap(
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  trafficEnabled: false,
                  initialCameraPosition: MapFunctions().initialPosition.value,
                  markers: MapFunctions().markers_homepage,
                  onCameraMoveStarted: () {
                    if (MapFunctions().isIdle) {
                      MapFunctions().isFocused = false;
                    }
                  },
                  onCameraIdle: () {
                    if (!MapFunctions().isIdle) {
                      controller.debouncer.run(() {
                        MapFunctions().isIdle = true;
                      });
                    }
                  },
                  onMapCreated: (mapCtrl) {
                    MapFunctions().controller = mapCtrl;
                    if (controller.station_marker_list.isNotEmpty) {
                      controller.focusOnNearestStation();
                    }
                  },
                ),
              ),
            ),
          ),

          // 2. Top Floating Area (Search Capsule + Wallet Card + Quick Filter Pills)
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                // Row: Search Capsule & Wallet Balance Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      // Search Capsule
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.toNamed(Routes.searchPageRoute),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 48.h,
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/search-zoom-in.svg',
                                  width: 18.w,
                                  height: 18.w,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF68768E),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    'Search for stations..',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF68768E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // Wallet Balance Card
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.walletPageRoute),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 48.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: const Color(0xFFDBEAFE),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A)
                                    .withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0049C2),
                                  borderRadius: BorderRadius.circular(8.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/svg/figma_wallet.svg',
                                  width: 16.w,
                                  height: 16.w,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'BALANCE',
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFA0AABD),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      '₹${appData.userModel.value.balanceAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontFamily: kFontFamily,
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF121D31),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),

                // Horizontal Quick Filter Pills
                _buildQuickFilterPills(),
              ],
            ),
          ),

          // 3. Floating Action Buttons (Attached directly above the bottom sheet top edge)
          Obx(() {
            final bottomOffset = (sheetExtent.value * screenHeight) + 14.h;
            return Positioned(
              right: 16.w,
              bottom: bottomOffset,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // GPS Recenter Button
                  GestureDetector(
                    onTap: controller.onLocationTap,
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF3F4F6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/svg/location_searching.svg',
                        width: 20.w,
                        height: 20.w,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF121D31),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // QR Scanner Blue FAB
                  GestureDetector(
                    onTap: controller.onQrScan,
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0049C2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/svg/qr_scan.svg',
                        width: 22.w,
                        height: 22.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // 4. Draggable Bottom Sheet with Full Header Draggability
          _buildDraggableBottomSheet(),
        ],
      ),
    );
  }

  // Quick Filter Horizontal Scroll Row matching Figma
  Widget _buildQuickFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final currentFilter = controller.selectedQuickFilter.value;

        return Row(
          children: [
            // Filter 0: Fast Chargers (>50kW)
            _buildFilterPill(
              index: 0,
              label: 'Fast Chargers (>50kW)',
              isSelected: currentFilter == 0,
              prefixWidget: Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: currentFilter == 0 ? Colors.white : const Color(0xFF03E8BE),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Filter 1: Available Now (with exact 4-point Sparkle SVG)
            _buildFilterPill(
              index: 1,
              label: 'Available Now',
              isSelected: currentFilter == 1,
              prefixWidget: SvgPicture.asset(
                'assets/svg/figma_sparkle.svg',
                width: 12.w,
                height: 12.w,
                colorFilter: ColorFilter.mode(
                  currentFilter == 1 ? Colors.white : const Color(0xFF01B1E1),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Filter 2: CCS2 / Type 2
            _buildFilterPill(
              index: 2,
              label: 'CCS2 / Type 2',
              isSelected: currentFilter == 2,
            ),
            SizedBox(width: 8.w),

            // Filter 3: 24/7 Open
            _buildFilterPill(
              index: 3,
              label: '24/7 Open',
              isSelected: currentFilter == 3,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterPill({
    required int index,
    required String label,
    required bool isSelected,
    Widget? prefixWidget,
  }) {
    return GestureDetector(
      onTap: () => controller.toggleQuickFilter(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0049C2)
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0049C2)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF0049C2).withValues(alpha: 0.25)
                  : const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixWidget != null) ...[
              prefixWidget,
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF121D31),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Instagram Comment-Section Style Draggable Bottom Sheet with Full Header Draggability
  Widget _buildDraggableBottomSheet() {
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.44,
      minChildSize: 0.18,
      maxChildSize: 0.88,
      snap: true,
      snapSizes: const [0.18, 0.44, 0.88],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(36.r),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF01B1E1).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              // Pinned/Draggable Header area inside CustomScrollView
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.5.h,
                        margin: EdgeInsets.only(top: 10.h, bottom: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),
                    ),

                    // Sheet Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 4.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Obx(
                                        () => Text(
                                          '${controller.displayStations.length} stations nearby',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: kFontFamily,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    // Dynamic Location / City Pill
                                    Obx(() {
                                      final city = MapFunctions()
                                              .curPosName
                                              .value
                                              .isNotEmpty
                                          ? MapFunctions().curPosName.value
                                          : (controller.displayStations.isNotEmpty &&
                                                  controller.displayStations.first
                                                      .address.isNotEmpty
                                              ? controller
                                                  .displayStations.first.address
                                                  .split(',')
                                                  .first
                                                  .trim()
                                              : 'Kochi');
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDBEAFE),
                                          borderRadius:
                                              BorderRadius.circular(100.r),
                                        ),
                                        child: Text(
                                          city,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: kFontFamily,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1D4ED8),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Sorted by fastest charging & distance',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: kFontFamily,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Filter & Refresh Action Circle Buttons (matching Figma)
                          Row(
                            children: [
                              GestureDetector(
                                onTap: controller.onFilterTap,
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black.withValues(alpha: 0.05),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    'assets/svg/tune.svg',
                                    width: 16.w,
                                    height: 16.w,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF334155),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: controller.onReload,
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black.withValues(alpha: 0.05),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    'assets/svg/refresh-ccw.svg',
                                    width: 16.w,
                                    height: 16.w,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF334155),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF1F5F9),
                      ),
                    ),
                  ],
                ),
              ),

              // Station Card List (SliverList so drag gestures work everywhere)
              Obx(() {
                final stations = controller.displayStations;
                if (stations.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 40.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.ev_station_rounded,
                            size: 48.sp,
                            color: const Color(0xFFCBD5E1),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No stations found',
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF121D31),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Try clearing quick filters or refresh location',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          if (controller.selectedQuickFilter.value != -1) ...[
                            SizedBox(height: 12.h),
                            TextButton(
                              onPressed: () {
                                controller.selectedQuickFilter.value = -1;
                                controller.reload++;
                              },
                              child: Text(
                                'Clear Filter',
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0049C2),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final station = stations[index];
                        return StationCardItem(
                          station: station,
                          onTap: () {
                            controller.getChargeStationDetails(
                              station.id,
                              isCardTap: true,
                            );
                          },
                        );
                      },
                      childCount: stations.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
