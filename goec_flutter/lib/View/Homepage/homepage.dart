import 'dart:ui' as ui;

import 'package:get/get.dart';
import '../../Singletones/socketRepo.dart';
import '../../constants.dart';
import 'help_page_alive.dart';
import '../../Utils/routes.dart';
import 'notification_page_alive.dart';
import 'package:flutter/material.dart';
import '../../Singletones/app_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freelancer_app/Utils/utils.dart';
import '../../Singletones/common_functions.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/View/Charge/charge_page.dart';
import 'package:freelancer_app/View/Widgets/customText.dart';
import 'package:freelancer_app/View/Widgets/amenity_icon.dart';
import 'package:freelancer_app/View/Homepage/map_screen.dart';
import 'package:freelancer_app/Singletones/map_functions.dart';
import 'package:freelancer_app/Utils/my_flutter_app_icons.dart';
import 'profile_page_alive.dart';
import 'package:freelancer_app/Controller/homepage_controller.dart';
import 'package:freelancer_app/Model/chargeStationDetailsModel.dart';
import 'package:freelancer_app/View/Widgets/cached_network_image.dart';
import 'package:freelancer_app/View/Widgets/cached_svg_badge.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class HomePageScreen extends StatefulWidget {
  HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final HomePageController controller = Get.find<HomePageController>();

  static const _navIcons = [
    'assets/svg/nav_support.svg',
    'assets/svg/nav_notifications.svg',
    '',
    'assets/svg/nav_history.svg',
    'assets/svg/nav_profile.svg',
  ];

  final Map<int, Widget> _tabCache = {};
  final Map<String, ui.Image?> _navIconImages = {};
  ui.Image? _fabBlue;
  ui.Image? _fabGreen;
  bool _navIconsReady = false;

  @override
  void initState() {
    super.initState();
    // Map tab is the initial page.
    _tabCache[2] = const MapScreen();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheNavArt());
  }

  Future<void> _precacheNavArt() async {
    if (!mounted) return;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final iconSize = 24.sp;
    final fabSize = 72.sp;

    await Future.wait([
      ..._navIcons.where((e) => e.isNotEmpty).map(
            (asset) => SvgRasterCache.precache(
              asset,
              logicalPx: iconSize,
              devicePixelRatio: dpr,
            ),
          ),
      SvgRasterCache.precache(
        'assets/svg/logo_blue.svg',
        logicalPx: fabSize,
        devicePixelRatio: dpr,
      ),
      SvgRasterCache.precache(
        'assets/svg/logo_green.svg',
        logicalPx: fabSize,
        devicePixelRatio: dpr,
      ),
    ]);

    if (!mounted) return;
    setState(() {
      for (final asset in _navIcons) {
        if (asset.isEmpty) continue;
        _navIconImages[asset] = SvgRasterCache.getSync(
          asset,
          logicalPx: iconSize,
          devicePixelRatio: dpr,
        );
      }
      _fabBlue = SvgRasterCache.getSync(
        'assets/svg/logo_blue.svg',
        logicalPx: fabSize,
        devicePixelRatio: dpr,
      );
      _fabGreen = SvgRasterCache.getSync(
        'assets/svg/logo_green.svg',
        logicalPx: fabSize,
        devicePixelRatio: dpr,
      );
      _navIconsReady = true;
    });
  }

  Widget _tabFor(int index) {
    return _tabCache.putIfAbsent(index, () {
      switch (index) {
        case 0:
          return HelpPageAlive();
        case 1:
          return NotiPageAlive();
        case 2:
          return const MapScreen();
        case 3:
          return const ChargeScreen();
        case 4:
          return ProfilePageAlive();
        default:
          return const SizedBox.shrink();
      }
    });
  }

  void _onTabTap(int index) {
    if (index == 2 && controller.activeIndex.value != 2) {
      controller.onHomescreen();
    }
    controller.goToTab(index);
  }

  Widget _buildTabSlot(int index) {
    return Obx(() {
      final current = controller.activeIndex.value;
      final shouldBuild =
          controller.visitedTabs.contains(index) || current == index;
      if (!shouldBuild) {
        return const SizedBox.shrink();
      }
      // Keep both sliding pages alive during the transition; freeze only
      // when fully off-screen. Mask updates sparsely (not every frame).
      return TickerMode(
        enabled: controller.isTabVisiblyActive(index),
        child: RepaintBoundary(
          child: _tabFor(index),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    kContext = context;
    return appData.userModel.value.username.isNotEmpty
        ? Scaffold(
            backgroundColor: kDefaultHomePageBackgroundColor,
            body: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(5, _buildTabSlot),
            ),
            floatingActionButton: InkWell(
              onTap: () {
                if (controller.activeIndex.value != 2) {
                  controller.onHomescreen();
                }
                if (controller.activeIndex.value == 2 &&
                    SocketRepo().isCharging.value) {
                  controller.getActiveBooking(true);
                  return;
                }
                controller.goToTab(
                  2,
                  duration: const Duration(milliseconds: 420),
                );
              },
              child: Obx(() {
                final charging = SocketRepo().isCharging.value;
                final fabImage = charging ? _fabGreen : _fabBlue;
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: charging
                        ? const [
                            BoxShadow(
                              color: Colors.green,
                              blurRadius: 20,
                              spreadRadius: -1,
                            ),
                          ]
                        : const [],
                  ),
                  child: fabImage != null
                      ? RawImage(
                          image: fabImage,
                          width: 72.sp,
                          height: 72.sp,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.low,
                        )
                      : SvgPicture.asset(
                          charging
                              ? 'assets/svg/logo_green.svg'
                              : 'assets/svg/logo_blue.svg',
                          fit: BoxFit.contain,
                          width: 72.sp,
                          height: 72.sp,
                        ),
                );
              }),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: Obx(
              () => AnimatedBottomNavigationBar.builder(
                notchMargin: -50,
                itemCount: 5,
                tabBuilder: (index, isActive) {
                  const activeColor = Color(0xFF0049C2);
                  const inactiveColor = Color(0xFFA0AABD);
                  final itemColor = isActive ? activeColor : inactiveColor;
                  final asset = _navIcons[index];
                  final cached = _navIconsReady ? _navIconImages[asset] : null;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (index == 2)
                        SizedBox(height: 24.h)
                      else if (cached != null)
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            itemColor,
                            BlendMode.srcIn,
                          ),
                          child: RawImage(
                            image: cached,
                            width: 24.sp,
                            height: 24.sp,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.low,
                          ),
                        )
                      else
                        SvgPicture.asset(
                          asset,
                          width: 24.sp,
                          height: 24.sp,
                          colorFilter: ColorFilter.mode(
                            itemColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      SizedBox(height: 4.h),
                      Text(
                        (index == 2 && SocketRepo().isCharging.value)
                            ? 'Charging'
                            : NavBarIcon.labels[index],
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 10.5.sp,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: (index == 2 && SocketRepo().isCharging.value)
                              ? Colors.green
                              : itemColor,
                        ),
                        textScaler: TextScaler.noScaling,
                      )
                    ],
                  );
                },
                activeIndex: controller.activeIndex.value,
                height: size.height * .085,
                gapLocation: GapLocation.none,
                notchSmoothness: NotchSmoothness.defaultEdge,
                onTap: _onTabTap,
              ),
            ),
          )
        : Scaffold(
            body: MapScreen(),
          );
  }
}


showBottomSheetWhenClickedOnMarker(
    ChargeStationDetailsModel model, HomePageController controller) async {
  // CalistaCafePageController calcontroller =
  //     Get.put(CalistaCafePageController());
  double distance = 0;
  distance = (MapFunctions.distanceBetweenCoordinates(
              MapFunctions().curPos.latitude,
              MapFunctions().curPos.longitude,
              model.latitude,
              model.longitude) /
          1000.0)
      .toPrecision(2);
  List amenities = model.amenities;
  bool available = false;
  List res = [];
  model.chargers.forEach((element) {
    res = calculateAvailabiliy(
        element.evports, element.ocppStatus == 'Connected');
    kLog(res.toString());
    if (res[1] > 0) available = true;
  });
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: kContext,
    isScrollControlled: true,
    builder: (context) => PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // calcontroller.dispose();
        return;
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
          SlidingUpPanel(
            color: Colors.transparent,
            controller: controller.panelController,
            minHeight: size.height * .32,
            maxHeight: size.height * .80,
            onPanelSlide: (value) {
              // kLog(value.toString());
            },
            onPanelClosed: () {},

            onPanelOpened: () {
              Get.offNamed(Routes.calistaCafePageRoute, arguments: model);
            },
            // panel: CalistaCafeScreen(),
            panel: Container(
              color: Colors.white,
            ),
            collapsed: Container(
              height: size.height * .32,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Column(children: [
                height(size.height * .01),
                Container(
                  height: size.height * .006,
                  width: size.width * .25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffD9D9D9)),
                ),
                height(size.height * .05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * .06),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              color: Colors.grey,
                              height: 90.w,
                              // width: 90.w,
                              child: cachedNetworkImage(model.image),
                            )),
                      ),
                      width(size.width * .035),
                      Expanded(
                        flex: 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: size.height * .023,
                              width: size.width * .14,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xffFFE1C7)),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Color(0xffF2994A),
                                      size: 15,
                                    ),
                                    CustomText(
                                        text: model.rating.toStringAsFixed(2),
                                        size: 12,
                                        color: Color(0xffF2994A)),
                                  ]),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: CustomText(
                                      text: model.name,
                                      overflow: TextOverflow.ellipsis,
                                      color: Color(0xff4F4F4F),
                                      fontWeight: FontWeight.bold),
                                ),
                                width(size.width * .017),
                              ],
                            ),
                            CustomText(
                                text: '${distance} km away',
                                color: Color(0xff828282),
                                fontWeight: FontWeight.normal,
                                size: 12),
                            if (amenities.isNotEmpty &&
                                amenities[0].isNotEmpty) ...[
                              height(8.h),
                              GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 4.7),
                                itemCount: amenities.length,
                                itemBuilder: (context, index) {
                                  logger.i(amenities[index].toLowerCase());
                                  return Row(
                                    children: [
                                      AmenityIcon(
                                        amenity: amenities[index].toString(),
                                        size: 14,
                                        color: const Color(0xff828282),
                                      ),
                                      width(size.width * .01),
                                      Expanded(
                                        child: CustomText(
                                            text: amenities[index],
                                            color: Color(0xff828282),
                                            fontWeight: FontWeight.normal,
                                            size: 12),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              height(8.h),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                height(size.height * .05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * .04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: size.height * .04,
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * .035),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: available
                                ? Color(0xff219653)
                                : Color.fromARGB(255, 221, 90, 90)),
                        child: Row(
                          children: [
                            available
                                ? SvgPicture.asset('assets/svg/tick.svg')
                                : Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            width(size.width * .01),
                            CustomText(
                                text: available
                                    ? 'Chargers Available'
                                    : 'Chargers Unavailable',
                                size: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffF2F2F2)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              showLoading(kLoading);
                              bool res = await CommonFunctions().changeFavorite(
                                  stationId: model.id,
                                  makeFavorite: !model.isFavorite);
                              if (res) {
                                model.isFavorite = !model.isFavorite;
                                controller.reload++;
                              }
                              hideLoading();
                            },
                            child: Obx(
                              () => Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(
                                    horizontal: size.width * .01 +
                                        controller.reload.value * 0),
                                padding: EdgeInsets.all(size.width * .02),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Color(0xffBDBDBD))),
                                child: SvgPicture.asset(model.isFavorite
                                    ? 'assets/svg/favorite1.svg'
                                    : 'assets/svg/favorite.svg'),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ]),
            ),
          ),
        ],
      ),
    ),
  );
}
