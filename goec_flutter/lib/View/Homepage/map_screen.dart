import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../constants.dart';
import '../../Utils/routes.dart';
import '../../Singletones/app_data.dart';
import '../../Singletones/map_functions.dart';
import '../../Controller/homepage_controller.dart';
import '../Widgets/appbutton.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.station_marker_list.isEmpty) {
        controller.onReload();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        controller.activeIndex.value == 2) {
      controller.onReturnFromBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    // When Station Detail (or any route) covers Home, this secondaryAnimation
    // runs. Dropping the GoogleMap platform view during that window is what
    // keeps the push/pop animation at a high refresh rate.
    final secondaryAnimation = ModalRoute.of(context)?.secondaryAnimation ??
        kAlwaysDismissedAnimation;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: AnimatedBuilder(
        animation: secondaryAnimation,
        builder: (context, child) {
          // Keep map down for the whole cover animation; remount only when
          // secondary is fully dismissed (pop finished) to avoid end-of-pop hitch.
          final covered = secondaryAnimation.status != AnimationStatus.dismissed;
          return TickerMode(
            enabled: !covered,
            child: Stack(
              children: [
                // 1. Google Map — replaced with a cheap placeholder while covered
                Positioned.fill(
                  child: covered
                      ? const ColoredBox(color: Color(0xFFE8EAED))
                      : child!,
                ),

                // 2–3. Overlays only while map is interactive (saves paint during push)
                if (!covered) ..._mapOverlays(size),
              ],
            ),
          );
        },
        child: RepaintBoundary(
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
                  if (!MapFunctions().hasUserLocation) {
                    MapFunctions().showNepalOverview();
                  } else if (controller.station_marker_list.isNotEmpty) {
                    controller.focusOnNearestStation();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _mapOverlays(Size size) {
    return [
          // 2. Top Floating Area (Search Capsule + Wallet Card + Quick Filter Pills)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
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
                          child: Hero(
                            tag: 'search_bar_hero',
                            child: Material(
                              color: Colors.transparent,
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
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            height: 16 / 14,
                                            color: const Color(0xFF68768E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                        height: 11.25 / 9,
                                        color: const Color(0xFFA0AABD),
                                        letterSpacing: 0.45,
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        '₹${appData.userModel.value.balanceAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          height: 16 / 12,
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
          ),

          // 3. Station Listing Carousel & Action Buttons (Old UI from main branch pinned to bottom)
          Positioned(
            bottom: 12.h,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PositionedButton(
                        svgUrl: 'assets/svg/refresh-ccw.svg',
                        svgColor: Colors.grey.shade700,
                        bgColor: Colors.white,
                        onTap: controller.onReload,
                      ),
                      PositionedButton(
                        svgUrl: 'assets/svg/tune.svg',
                        svgColor: Colors.grey.shade700,
                        bgColor: Colors.white,
                        onTap: controller.onFilterTap,
                      ),
                      PositionedButton(
                        svgUrl: 'assets/svg/location_searching.svg',
                        svgColor: Colors.grey.shade700,
                        bgColor: Colors.white,
                        onTap: controller.onLocationTap,
                      ),
                      PositionedButton(
                        svgUrl: 'assets/svg/qr_scan.svg',
                        svgColor: Colors.white,
                        bgColor: kOnboardingColors,
                        onTap: controller.onQrScan,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Obx(
                    () => CarouselSlider(
                      carouselController: controller.carouselController
                          .value as CarouselSliderController?,
                      items: controller.cards,
                      options: CarouselOptions(
                        height: 160.h,
                        enlargeCenterPage: true,
                        padEnds: true,
                        onPageChanged: (index, reason) {
                          final stations = controller.displayStations;
                          if (index >= 0 && index < stations.length) {
                            final st = stations[index];
                            if (st.latitude != 0 && st.longitude != 0) {
                              MapFunctions().animateToNewPosition(
                                LatLng(st.latitude, st.longitude),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    ];
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
                height: 16.5 / 12,
                color: isSelected ? Colors.white : const Color(0xFF121D31),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
