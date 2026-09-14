import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Utils/firebase_notifications.dart';
import '../Utils/routes.dart';
import '../Utils/utils.dart';
import 'chargePage_controller.dart';
import 'package:flutter_svg/svg.dart';
import '../Singletones/app_data.dart';
import '../View/Homepage/homepage.dart';
// ignore_for_file: deprecated_member_use
import '../Model/activeSessionModel.dart';
import 'package:geolocator/geolocator.dart';
import 'notification_screen_controller.dart';
import 'package:freelancer_app/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:freelancer_app/Utils/debouncer.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:freelancer_app/Singletones/injector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/Singletones/socketRepo.dart';
import 'package:freelancer_app/View/Widgets/customText.dart';
import 'package:freelancer_app/Model/stationMarkerModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:freelancer_app/Singletones/map_functions.dart';
import 'package:freelancer_app/Singletones/dialogs.dart';
import 'package:freelancer_app/View/Widgets/amenity_icon.dart';
import 'package:freelancer_app/Utils/local_notifications.dart';
import 'package:freelancer_app/Utils/image_byte_converter.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';
import 'package:freelancer_app/Controller/walletPage_controller.dart';
import 'package:freelancer_app/Controller/trips_screen_controller.dart';
import 'package:freelancer_app/Controller/filter_screen_controller.dart';
import 'package:freelancer_app/Controller/charging_screen_controller.dart';

class HomePageController extends GetxController {
  // RxDouble height = 80.0.obs;
  RxString name = ''.obs;
  RxString done = 'do'.obs;
  RxInt activeIndex = 2.obs;
  RxInt reload = 0.obs;
  // RxBool isCharging = false.obs;
  //NEW HELP PAGE STARTS
  Rx<carousel.CarouselSliderController> carouselController =
      carousel.CarouselSliderController().obs;
  RxDouble currentIndex = 0.0.obs;
  String phnNumber = "+919778687615";
  RxList carouselText = [
    "GOEC super charging station Provides High ROI",
    "operate your charging station from anywhere in the world without human intervention.",
    "For a future-focused business, capitalize on the growing EV market."
  ].obs;
  RxList carouselImage = [
    "assets/images/carouselOne.png",
    "assets/images/carouselTwo.png",
    "assets/images/carouselThree.png",
  ].obs;
  //NEW HELP PAGE ENDS

  //NEW NOTIFICATION PAGE STARTS
  // RxList<NotificationModel> modelList = RxList([]);
  // ENDS

  //Mapscreen Starts
  PageController cardController = PageController();
  //Ends

  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();
  PageController pageController = PageController(initialPage: 2);
  PanelController panelController = PanelController();

  /// Fractional PageView position — used to keep both sliding tabs alive
  /// during animated transitions (smoother than freezing on activeIndex).
  final RxDouble pagePosition = 2.0.obs;

  /// Bitmask of tabs currently on-screen (including mid-transition).
  /// Updated only when visibility changes — avoids per-frame Obx rebuilds.
  final RxInt visibleTabMask = (1 << 2).obs;

  /// Tabs that have been opened at least once (preserves state without
  /// building every tab up front).
  final Set<int> visitedTabs = <int>{2};

  bool _isTabAnimating = false;

  void _onPageControllerTick() {
    if (!pageController.hasClients) return;
    final page = pageController.page;
    if (page == null) return;
    if ((pagePosition.value - page).abs() > 0.001) {
      pagePosition.value = page;
    }
    var mask = 0;
    for (var i = 0; i < 5; i++) {
      if ((page - i).abs() < 0.999) {
        mask |= 1 << i;
      }
    }
    if (visibleTabMask.value != mask) {
      visibleTabMask.value = mask;
    }
  }

  void _attachPageListener() {
    pageController.addListener(_onPageControllerTick);
  }

  bool isTabVisiblyActive(int index) =>
      (visibleTabMask.value & (1 << index)) != 0;

  Future<void> goToTab(
    int index, {
    bool animate = true,
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeInOutCubic,
  }) async {
    if (index < 0 || index > 4) return;
    if (_isTabAnimating) return;
    if (activeIndex.value == index &&
        pageController.hasClients &&
        (pageController.page?.round() ?? activeIndex.value) == index) {
      return;
    }

    // Build destination before the slide starts to avoid a blank frame.
    visitedTabs.add(index);
    // Ensure destination bit is on before paint so the page isn't blank.
    visibleTabMask.value = visibleTabMask.value | (1 << index);
    activeIndex.value = index;

    if (!pageController.hasClients) return;

    if (!animate) {
      pageController.jumpToPage(index);
      pagePosition.value = index.toDouble();
      visibleTabMask.value = 1 << index;
      return;
    }

    _isTabAnimating = true;
    try {
      await pageController.animateToPage(
        index,
        duration: duration,
        curve: curve,
      );
    } finally {
      _isTabAnimating = false;
      if (pageController.hasClients) {
        pagePosition.value = pageController.page ?? index.toDouble();
      } else {
        pagePosition.value = index.toDouble();
      }
      visibleTabMask.value = 1 << index;
    }
  }

  final ChargeScreenController chargeScreenController =
      Get.put(ChargeScreenController());
  final tripsScreenController = Get.put(TripsScreenController());
  final WalletPageController walletPageController =
      Get.put(WalletPageController());
  final NotificationScreenController notificationController =
      Get.put(NotificationScreenController());
  RxList<StationMarkerModel> station_marker_list = <StationMarkerModel>[].obs;
  Debouncer debouncer = Debouncer(milliseconds: 3000);
  RxList<Widget> cards = RxList();

  @override
  void onInit() async {
    _attachPageListener();
    super.onInit();
    await _initImages();
    await FireBaseNotification().init();

    final requestLocation = Get.arguments == 'requestLocation';
    final hasPermission =
        await MapFunctions().isLocationPermissionGranted();

    if (requestLocation && !hasPermission) {
      // Let the homepage paint first, then show the Figma location sheet.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Dialogs().showLocationPermissionSheet(
          onEnabled: () => _bootstrapLocation(),
        );
      });
    } else {
      await _bootstrapLocation();
    }
  }

  Future<void> _bootstrapLocation() async {
    // 1. Instantly use cached last location (0ms) if available
    Position? pos = await MapFunctions().getLastLocation();
    if (pos != null) {
      MapFunctions().curPos = pos;
      MapFunctions().initCameraPosition(LatLng(pos.latitude, pos.longitude));
      await getNearestChargestations(pos);
      MapFunctions().addMyPositionMarker(pos, MapFunctions().markers_homepage);
    }

    // 2. Fetch fresh high-accuracy position
    Position? freshPos = await MapFunctions().getCurrentPosition();
    if (freshPos != null) {
      MapFunctions().curPos = freshPos;
      MapFunctions().initCameraPosition(LatLng(freshPos.latitude, freshPos.longitude));
      if (pos == null ||
          Geolocator.distanceBetween(
                pos.latitude,
                pos.longitude,
                freshPos.latitude,
                freshPos.longitude,
              ) >
              500) {
        await getNearestChargestations(freshPos);
      }
      MapFunctions().addMyPositionMarker(freshPos, MapFunctions().markers_homepage);
    }

    MapFunctions().myPositionListener();
  }

  @override
  void onClose() {
    pageController.removeListener(_onPageControllerTick);
    MapFunctions().dispose();
    NotificationService().cancelLocalNotification(1);
    super.onClose();
    SocketRepo().closeSocket();
    Injector().dispose();
  }

  onReload() async {
    CommonFunctions().getUserProfile();
    Position? pos = MapFunctions().curPos != kPosition
        ? MapFunctions().curPos
        : (await MapFunctions().getLastLocation() ??
            await MapFunctions().getCurrentPosition());

    if (pos != null) {
      MapFunctions().curPos = pos;
      await getNearestChargestations(pos);
    } else {
      await getNearestChargestations(MapFunctions().curPos);
    }

    reload++;
  }

  onHomescreen() async {
    final list = await CommonFunctions().getNearestChargstations(Position(
        headingAccuracy: 0,
        altitudeAccuracy: 0,
        longitude: MapFunctions().curPos.longitude,
        latitude: MapFunctions().curPos.latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0));
    station_marker_list.assignAll(list);
    var _filterController = await Get.put(FilterScreenController());
    _filterController.station_marker_List = station_marker_list.toList();
    _filterController.applyFilter();
    _filterController.onClose();
  }

  _initImages() async {
    MapFunctions().bytesBlue = await ImageByteConverter.getBytesFromAsset(
        "assets/svg/blue_marker.png", 70);
    MapFunctions().bytesGreen = await ImageByteConverter.getBytesFromAsset(
        "assets/svg/green_marker.png", 70);
    MapFunctions().bytesGray = await ImageByteConverter.getBytesFromAsset(
        "assets/svg/gray_marker.png", 70);
    MapFunctions().navigationMarker =
        await ImageByteConverter.getBytesFromAsset(
            "assets/images/pointer.png", 70);
    MapFunctions().carMarker = await ImageByteConverter.getBytesFromAsset(
        "assets/images/CSAR.png", 70);
    MapFunctions().myMarker = await ImageByteConverter.getBytesFromAsset(
        "assets/images/myMarker.png", 60);
  }

  getNearestChargestations(Position pos) async {
    MapFunctions().curPos = pos;
    showLoading('Fetching nearby charge stations.\nPlease wait...');
    await getActiveBooking(false, refresh: true);
    final fetched = await CommonFunctions().getNearestChargstations(pos);
    hideLoading();
    station_marker_list.assignAll(fetched);

    /*Apply filter if applicable and use filterpage station_marker_list*/
    var _filterController = await Get.put(FilterScreenController());
    _filterController.station_marker_List = station_marker_list.toList();
    _filterController.applyFilter();
    _filterController.onClose();

    updateMapMarkers();
    focusOnNearestStation();
    reload++;
  }

  RxInt selectedQuickFilter = (-1).obs;

  double calculateDistanceToStation(StationMarkerModel station) {
    try {
      final userLat = MapFunctions().curPos.latitude;
      final userLng = MapFunctions().curPos.longitude;
      if (userLat != 0 &&
          userLng != 0 &&
          station.latitude != 0 &&
          station.longitude != 0) {
        final dist = Geolocator.distanceBetween(
              userLat,
              userLng,
              station.latitude,
              station.longitude,
            ) /
            1000.0;
        if (!dist.isNaN && !dist.isInfinite) {
          return dist;
        }
      }
    } catch (_) {}
    return 999999.0;
  }

  List<StationMarkerModel> get displayStations {
    reload.value;
    List<StationMarkerModel> list = List.from(station_marker_list);

    if (selectedQuickFilter.value == 0) {
      // Fast Chargers (>50kW)
      list = list.where((s) {
        final cap = s.charger_capacity.toLowerCase();
        final acDc = s.ac_dc.toLowerCase();
        return acDc.contains('dc') ||
            cap.contains('50') ||
            cap.contains('60') ||
            cap.contains('120') ||
            cap.contains('150') ||
            cap.contains('240') ||
            cap.contains('kw') ||
            s.ac_dc.isNotEmpty;
      }).toList();
    } else if (selectedQuickFilter.value == 1) {
      // Available Now
      list = list.where((s) {
        final status = s.charger_status.toLowerCase();
        return status == 'online' || status == 'available';
      }).toList();
    } else if (selectedQuickFilter.value == 2) {
      // CCS2 / Type 2
      list = list.where((s) {
        return s.charger_type.any((t) {
          final str = t.toString().toLowerCase();
          return str.contains('ccs') ||
              str.contains('type 2') ||
              str.contains('type2');
        });
      }).toList();
    } else if (selectedQuickFilter.value == 3) {
      // 24/7 Open
      list = list.where((s) {
        return s.startTime.isEmpty ||
            (s.startTime == '00:00' && s.stopTime == '23:59') ||
            s.startTime.toLowerCase().contains('24') ||
            s.startTime == s.stopTime;
      }).toList();
    }

    list.sort((a, b) {
      double distA = calculateDistanceToStation(a);
      double distB = calculateDistanceToStation(b);
      return distA.compareTo(distB);
    });

    return list;
  }

  void toggleQuickFilter(int index) {
    if (selectedQuickFilter.value == index) {
      selectedQuickFilter.value = -1;
    } else {
      selectedQuickFilter.value = index;
    }
    reload++;
  }

  void focusOnNearestStation() {
    if (station_marker_list.isEmpty) return;
    StationMarkerModel? nearest;
    double minDistance = double.infinity;
    for (var station in station_marker_list) {
      if (station.latitude != 0 && station.longitude != 0) {
        double dist = calculateDistanceToStation(station);
        if (dist < minDistance) {
          minDistance = dist;
          nearest = station;
        }
      }
    }
    if (nearest != null) {
      try {
        MapFunctions().animateToNewPosition(
          LatLng(nearest.latitude, nearest.longitude),
          newZoom: 15.0,
        );
      } catch (_) {}
    }
  }

  void updateMapMarkers() {
    MapFunctions().markers_homepage.clear();
    if (MapFunctions().curPos != kPosition) {
      MapFunctions().addMyPositionMarker(
          MapFunctions().curPos, MapFunctions().markers_homepage);
    }
    int index = 0;
    for (var element in station_marker_list) {
      if (element.latitude != 0 && element.longitude != 0) {
        MapFunctions().addMarkerHomePage(
          id: element.id.toString(),
          latLng: LatLng(element.latitude, element.longitude),
          controller: this,
          status: element.charger_status.trim(),
          carouselIndex: index,
        );
      }
      index++;
    }
    reload++;
  }

  assignCardsToMapScreen(List<StationMarkerModel> list) {
    if (list.isNotEmpty) {
      station_marker_list.assignAll(list);
    }
    cards.value = list.map((e) {
      double distance = 0;
      distance = (MapFunctions.distanceBetweenCoordinates(
                  MapFunctions().curPos.latitude,
                  MapFunctions().curPos.longitude,
                  e.latitude,
                  e.longitude) /
              1000.0)
          .toPrecision(2);
      List amenities = e.amenities;
      String available = e.charger_status == 'Online'
          ? kAvailable
          : e.charger_status == 'Busy'
              ? kBusy
              : kUnavailable;
      List connector = e.charger_type;
      int connectorCount = 0;
      if (connector.length > 2) {
        connectorCount = connector.length - 2;
        connector = connector.getRange(0, 2).toList();
      }
      return GestureDetector(
        onTap: () {
          getChargeStationDetails(e.id.toString(), isCardTap: true);
        },
        child: Container(
          height: 160.h,
          margin: EdgeInsets.only(right: 20),
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Color(0xffF2994A),
                    size: 15.sp,
                  ),
                  CustomText(
                    text: e.rating.toStringAsFixed(1),
                    size: 14.sp,
                    color: Color(0xffF2994A),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 2.h,
                      horizontal: 8.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: Color(0xFFF6F6F6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 10.h,
                          width: 10.h,
                          decoration: BoxDecoration(
                            color: isTimeInRange(e.startTime, e.stopTime)
                                ? Color(0xff219653)
                                : Color.fromARGB(255, 195, 56, 56),
                            shape: BoxShape.circle,
                          ),
                        ),
                        width(5.w),
                        CustomText(
                          text:
                              '${convertToPmFormat(e.startTime)} to ${convertToPmFormat(e.stopTime)}',
                          color: Colors.black,
                          size: 12.sp,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomText(
                            size: 16.sp,
                            text: e.name,
                            maxLines: 2,
                            height: 1.2,
                            overflow: TextOverflow.ellipsis,
                            color: Color(0xff4F4F4F),
                            fontWeight: FontWeight.bold,
                          ),
                          amenities.isEmpty
                              ? SizedBox(height: 17.sp)
                              : Row(
                                  children: amenities
                                      .map(
                                        (e) => Padding(
                                          padding: EdgeInsets.only(right: 15.w),
                                          child: AmenityIcon(
                                            amenity: e.toString(),
                                            size: 17.sp,
                                            color: const Color(0xFF8C8C8C),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                launchOnGoogleMap(e.latitude, e.longitude),
                            child: SvgPicture.asset(
                              height: 30.sp,
                              'assets/svg/direction_blue.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          height(5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                height: 13.sp,
                                'assets/svg/location.svg',
                                fit: BoxFit.contain,
                              ),
                              width(5.w),
                              CustomText(
                                text: '${distance} km',
                                color: Color(0xff828282),
                                fontWeight: FontWeight.normal,
                                size: 12.sp,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  Row(
                    children: [
                      connector.isEmpty
                          ? SizedBox(height: 20.h)
                          : Row(
                              children: connector
                                  .map(
                                    (e) => e.isEmpty
                                        ? SizedBox()
                                        : Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5.w,
                                                vertical: 3.w,
                                              ),
                                              margin: EdgeInsets.only(
                                                right: 5.w,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Color(0xffF29E50),
                                              ),
                                              child: Center(
                                                child: CustomText(
                                                  text: e,
                                                  size: 12.sp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                  )
                                  .toList(),
                            ),
                      if (connectorCount > 0)
                        CustomText(
                          text: "+$connectorCount",
                          size: 12.sp,
                          color: Color(0xFF8C8C8C),
                        ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      available == kAvailable
                          ? SvgPicture.asset(
                              'assets/svg/tick.svg',
                              colorFilter: ColorFilter.mode(
                                Colors.green,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                              size: 20.sp,
                            ),
                      width(size.width * .01),
                      CustomText(
                        text: '$available',
                        overflow: TextOverflow.ellipsis,
                        size: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: available == kAvailable
                            ? Color(0xff219653)
                            : available == kBusy
                                ? Color.fromARGB(255, 221, 90, 90)
                                : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          // child: Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 15.w),
          //   child: Column(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Padding(
          //           padding: EdgeInsets.symmetric(horizontal: size.width * .00),
          //           child: Row(
          //             children: [
          //               Expanded(
          //                 flex: 7,
          //                 child: Column(
          //                   mainAxisAlignment: MainAxisAlignment.start,
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Row(
          //                       crossAxisAlignment: CrossAxisAlignment.end,
          //                       children: [
          //                         Expanded(
          //                           child: CustomText(
          //                               text: e.name,
          //                               overflow: TextOverflow.ellipsis,
          //                               color: Color(0xff4F4F4F),
          //                               fontWeight: FontWeight.bold),
          //                         ),
          //                         width(size.width * .017),
          //                       ],
          //                     ),
          //                     Row(
          //                       mainAxisAlignment:
          //                           MainAxisAlignment.spaceBetween,
          //                       children: [
          //                         CustomText(
          //                           text: '${distance} km away',
          //                           color: Color(0xff828282),
          //                           fontWeight: FontWeight.normal,
          //                           size: 12,
          //                         ),
          //                         CustomText(
          //                             text:
          //                                 '${convertToPmFormat(e.startTime)} to ${convertToPmFormat(
          //                               e.stopTime,
          //                             )}',
          //                             color: Color(0xffa9a9a9),
          //                             size: 12)
          //                       ],
          //                     ),
          //                     ...[
          //                       height(8.h),
          //                       Container(
          //                         width: double.infinity,
          //                         child: Row(
          //                           children: [
          //                             if (amenities.isNotEmpty &&
          //                                 amenities[0].isNotEmpty)
          //                               Row(
          //                                   children: amenities
          //                                       .map(
          //                                         (e) => Padding(
          //                                           padding: EdgeInsets.only(
          //                                               right: 10.w),
          //                                           child: SvgPicture.asset(
          //                                               'assets/svg/${e.toLowerCase()}.svg'),
          //                                         ),
          //                                       )
          //                                       .toList()),
          //                             // width(10.w),
          //                             Container(
          //                               height: size.height * .023,
          //                               width: size.width * .14,
          //                               decoration: BoxDecoration(
          //                                   borderRadius:
          //                                       BorderRadius.circular(10),
          //                                   color: Color(0xffFFE1C7)),
          //                               child: Row(
          //                                   mainAxisAlignment:
          //                                       MainAxisAlignment.center,
          //                                   children: [
          //                                     Icon(
          //                                       Icons.star,
          //                                       color: Color(0xffF2994A),
          //                                       size: 15,
          //                                     ),
          //                                     CustomText(
          //                                         text: e.rating
          //                                             .toStringAsFixed(2),
          //                                         size: 12,
          //                                         color: Color(0xffF2994A)),
          //                                   ]),
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                       height(8.h),
          //                       Row(
          //                         children: [
          //                           Expanded(
          //                             child: CustomText(
          //                                 text: e.address,
          //                                 overflow: TextOverflow.ellipsis,
          //                                 color: Color(0xff4f4f4f),
          //                                 fontWeight: FontWeight.normal,
          //                                 size: 12),
          //                           ),
          //                         ],
          //                       ),
          //                     ],
          //                   ],
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //         // height(size.height * .05),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Row(
          //               children: [
          //                 Row(
          //                   children: connector
          //                       .map((e) => e.isEmpty
          //                           ? SizedBox()
          //                           : Align(
          //                               alignment: Alignment.center,
          //                               child: Container(
          //                                 // height: 12,
          //                                 padding: EdgeInsets.symmetric(
          //                                     horizontal: 5.w, vertical: 2.w),
          //                                 margin: EdgeInsets.only(right: 5.w),
          //                                 decoration: BoxDecoration(
          //                                   borderRadius:
          //                                       BorderRadius.circular(5),
          //                                   color: Color.fromRGBO(
          //                                       184, 210, 255, 0.6),
          //                                 ),
          //                                 child: Center(
          //                                   child: CustomText(
          //                                     text: e,
          //                                     size: 10.sp,
          //                                     color: Color(0xff0047C3),
          //                                   ),
          //                                 ),
          //                               ),
          //                             ))
          //                       .toList(),
          //                 ),
          //                 if (connectorCount > 0)
          //                   CustomText(
          //                     text: "+$connectorCount",
          //                     size: 10.sp,
          //                     color: Color(0xff0047C3),
          //                   ),
          //               ],
          //             ),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.end,
          //               children: [
          //                 available == kAvailable
          //                     ? SvgPicture.asset('assets/svg/tick.svg',
          //                         colorFilter: ColorFilter.mode(
          //                             Colors.green, BlendMode.srcIn))
          //                     : Icon(
          //                         Icons.info_outline,
          //                         color: Colors.grey,
          //                         size: 20,
          //                       ),
          //                 width(size.width * .01),
          //                 CustomText(
          //                     text: '$available',
          //                     overflow: TextOverflow.ellipsis,
          //                     size: 12.sp,
          //                     fontWeight: FontWeight.bold,
          //                     color: available == kAvailable
          //                         ? Color(0xff219653)
          //                         : available == kBusy
          //                             ? Color.fromARGB(255, 221, 90, 90)
          //                             : Colors.grey.shade400),
          //               ],
          //             ),
          //           ],
          //         )
          //       ]),
          // ),
        ),
      );
    }).toList();
  }

  getActiveBooking(bool isClickOnCard, {bool refresh = false}) async {
    ActiveSessionModel _activeSessionModel =
        await CommonFunctions().getActiveSession();

    if (_activeSessionModel.transactionId != '-1') {
      if (refresh && !SocketRepo().isCharging.value) {
        appData.tempActiveSessionModel = _activeSessionModel;
        // ChargingScreenController _chargingController =
        await Get.delete<ChargingScreenController>();
        await Get.put(ChargingScreenController());
        // await _chargingController.getChargingStatus();
        // _chargingController.onClose();
        appData.tempActiveSessionModel = kActiveSessionModel;
        return;
      } else if (!isClickOnCard) {
        // ChargingScreenController _chargingController =
        await Get.delete<ChargingScreenController>();
        await Get.put(ChargingScreenController());
        // await _chargingController.getChargingStatus();
        // _chargingController.onClose();
        return;
      }
      Get.toNamed(Routes.chargingPageRoute, arguments: _activeSessionModel);
    } else {
      SocketRepo().isCharging.value = false;
    }
  }

  getChargeStationDetails(String stationId, {bool isCardTap = false}) async {
    showLoading(kLoading);
    var res = await CommonFunctions().getChargeStationDetails(stationId);
    hideLoading();
    if (isCardTap) {
      Get.toNamed(Routes.calistaCafePageRoute, arguments: res);
    } else {
      showBottomSheetWhenClickedOnMarker(res, this);
    }
  }

  //NEW HELP PAGE STARTS
  Future<void> openWhatsApp() async {
    var url = "https://wa.me/${phnNumber}";
    if (await canLaunchUrl(Uri.parse(url))) {
      if (Platform.isAndroid) {
        await launch(url);
      } else if (Platform.isIOS) {
        await launch(url);
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> openPhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (Platform.isAndroid) {
      await launchUrl(launchUri);
    } else if (Platform.isIOS) {
      await launchUrl(launchUri);
    }
  }

  Future<void> openMail(String mail) async {
    var email = 'mailto:${mail}?subject=Subject&body=Body';
    if (await launch(email)) {
      if (Platform.isAndroid) {
        await launch(email);
      } else if (Platform.isIOS) {
        await launch(email);
      }
    } else {
      throw 'Could not launch $email';
    }
  }
  //NEW HELP PAGE ENDS

  //MapScreeen Functions Starts
  onFilterTap() {
    Get.toNamed(Routes.filterPageRoute, arguments: station_marker_list);
  }

  onLocationTap() async {
    final maps = MapFunctions();

    if (!await maps.isLocationPermissionGranted()) {
      Dialogs().showLocationPermissionSheet(
        onEnabled: () => onLocationTap(),
      );
      return;
    }

    final res = await maps.getCurrentPosition();
    if (res == null) {
      Dialogs().showLocationPermissionSheet(
        onEnabled: () => onLocationTap(),
      );
      return;
    }

    maps.curPos = res;
    maps.animateToNewPosition(
      LatLng(res.latitude, res.longitude),
      bearing: 0,
    );
  }

  onQrScan() {
    Get.toNamed(Routes.qrScanPageRoute);
  }

  launchOnGoogleMap(double latitude, double longitude) {
    launchUrlString(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
        mode: LaunchMode.externalApplication);
  }
}
