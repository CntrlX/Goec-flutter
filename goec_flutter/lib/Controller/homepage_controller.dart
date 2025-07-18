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
import 'package:flutter/material.dart';
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
  final ChargeScreenController chargeScreenController =
      Get.put(ChargeScreenController());
  final tripsScreenController = Get.put(TripsScreenController());
  final WalletPageController walletPageController =
      Get.put(WalletPageController());
  final NotificationScreenController notificationController =
      Get.put(NotificationScreenController());
  List<StationMarkerModel> station_marker_list = [];
  Debouncer debouncer = Debouncer(milliseconds: 3000);
  RxList<Widget> cards = RxList();

  @override
  void onInit() async {
    super.onInit();
    await _initImages();
    await FireBaseNotification().init();
    Position? pos = await MapFunctions().getCurrentPosition();
    if (pos != null) {
      getNearestChargestations(pos);
      MapFunctions().addMyPositionMarker(pos, MapFunctions().markers_homepage);
    }
    //  else {
    //   getNearestChargestations(Position(
    //       headingAccuracy: 0,
    //       altitudeAccuracy: 0,
    //       longitude: MapFunctions().curPos.longitude,
    //       latitude: MapFunctions().curPos.latitude,
    //       timestamp: DateTime.now(),
    //       accuracy: 0,
    //       altitude: 0,
    //       heading: 0,
    //       speed: 0,
    //       speedAccuracy: 0));
    // }
    Future.delayed(Duration(milliseconds: 1000), () {
      MapFunctions().myPositionListener();
    });
  }

  onClose() {
    MapFunctions().dispose();
    NotificationService().cancelLocalNotification(1);
    super.onClose();
    SocketRepo().closeSocket();
    Injector().dispose();
  }

  onReload() async {
    CommonFunctions().getUserProfile();
    if (MapFunctions().curPos == kPosition) {
      Position? res = await MapFunctions().getCurrentPosition();
      if (res != null) {
        getNearestChargestations(res);
      } else {
        getNearestChargestations(Position(
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
      }
    } else {
      getNearestChargestations(Position(
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
    }

    reload++;
  }

  onHomescreen() async {
    station_marker_list = await CommonFunctions().getNearestChargstations(
        Position(
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
    showLoading('Fetching nearby charge stations.\nPlease wait...');
    await getActiveBooking(false, refresh: true);
    station_marker_list = await CommonFunctions().getNearestChargstations(pos);
    hideLoading();
    /*Apply filter if applicable and use filterpage station_marker_list*/
    var _filterController = await Get.put(FilterScreenController());
    _filterController.station_marker_List = station_marker_list.toList();
    _filterController.applyFilter();
    _filterController.onClose();

    // assignCardsToMapScreen(_filterController.station_marker_List);
    // MapFunctions().markers_homepage.clear();
    // int index = 0;
    // _filterController.station_marker_List.forEach((element) {
    //   MapFunctions().addMarkerHomePage(
    //     id: element.id.toString(),
    //     latLng: LatLng(element.lattitude, element.longitude),
    //     isBusy: element.isBusy,
    //     status: element.charger_status.trim(),
    //     // element.charger_status.trim() != 'Connected' || element.isBusy,
    //     controller: this,
    //     carouselIndex: index,
    //   );
    //   index++;
    // });
  }

  assignCardsToMapScreen(List<StationMarkerModel> list) {
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
                                          child: SvgPicture.asset(
                                            height: 17.sp,
                                            'assets/svg/${e.toLowerCase()}.svg',
                                            color: Color(0xFF8C8C8C),
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
    var res = await MapFunctions().getCurrentPosition();
    if (res != null) MapFunctions().curPos = res;

    MapFunctions().animateToNewPosition(
        LatLng(
          MapFunctions().curPos.latitude,
          MapFunctions().curPos.longitude,
        ),
        bearing: 0);
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
