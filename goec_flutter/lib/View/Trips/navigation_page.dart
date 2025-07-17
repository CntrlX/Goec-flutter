import 'dart:developer';
import 'package:get/get.dart';
import '../../constants.dart';
import '../Widgets/apptext.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import '../Widgets/rounded_container.dart';
import '../../Singletones/map_functions.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Controller/navigation_screen_controller.dart';
import 'package:freelancer_app/View/Widgets/customText.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:freelancer_app/View/Widgets/cached_network_image.dart';

class NavigationScreen extends GetView<NavigationScreenController> {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return SlidingUpPanel(
      minHeight: 120.h,
      isDraggable: controller.stationList.isNotEmpty,
      panelBuilder: (ScrollController sc) => Padding(
        padding: EdgeInsets.only(top: 25.h, left: 25.w, right: 15.w),
        child: SingleChildScrollView(
          controller: sc,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Next Charging Station',
                size: 12.sp,
                color: Color(0xff828282),
              ),
              controller.stationList.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Center(
                        child: CustomText(
                          text: 'No Charging Station Found!',
                          size: 12.sp,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 20.h),
                      itemCount: controller.stationList.length,
                      shrinkWrap: true,
                      itemBuilder: ((context, index) {
                        return nearestCharginStationCard(index);
                      }),
                    ),
            ],
          ),
        ),
      ),
      // panel: Center(
      //   child: Text("This is the sliding Widget"),
      // ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Obx(
                  () => Container(
                    padding: EdgeInsets.all(controller.reload.value * 0 +
                        MapFunctions().reload.value * 0),
                    child: GoogleMap(
                      initialCameraPosition:
                          MapFunctions().initialPosition.value,
                      trafficEnabled: false,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      markers: MapFunctions().markers,
                      polylines: MapFunctions().polylines,
                      onMapCreated: (controller) {
                        MapFunctions().dirMapController = controller;
                        // MapFunctions().setMapStyle(controller);
                        MapFunctions().getCurrentPosition();
                      },
                      onTap: (value) {
                        // MapFunctions().setMapFitToPolyline(
                        //     MapFunctions().polylines,
                        //     MapFunctions().dirMapController);
                        MapFunctions()
                            .animateForNavigation(MapFunctions().curPos);
                        log(MapFunctions().curPos.toString());
                        // MapFunctions().addMarkerHomePage(
                        //     name: value.latitude.toString(),
                        //     latLng: value,
                        //     isGreen: false,
                        //     controller: controller);
                        MapFunctions().checkForUpdateSteps();
                      },
                    ),
                  ),
                ),
                yourDestinationCard(),
                // nearestChargingStationList(),
                // startYourTripCard(),
              ],
            ),
          ),
          // stepWidget(),
          // bottomWidget(),
        ],
      ),
    );
  }

  // Widget nearestChargingStationList() {
  //   return Positioned(
  //     bottom: size.height * 0.0,
  //     child: Obx(
  //       () => AnimatedContainer(
  //           width: size.width * .90,
  //           height: controller.chargingCardExpanded.value
  //               ? size.height * .7
  //               : size.height * .16,
  //           duration: Duration(milliseconds: 300),
  //           alignment: Alignment.center,
  //           // width: size.width * .90,
  //           // height: size.height * .30,
  //           margin: EdgeInsets.all(size.width * .1),
  //           decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(20),
  //               color: Colors.white,
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.grey.shade300,
  //                   blurRadius: 6,
  //                 )
  //               ]),
  //           child: Padding(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: size.width * .035,
  //               vertical: size.height * .025,
  //             ),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     CustomText(
  //                         text: 'Next Charging Station',
  //                         size: 13,
  //                         color: Color(0xff828282)),
  //                     InkWell(
  //                       onTap: () {
  //                         controller.chargingCardExpanded.value =
  //                             !controller.chargingCardExpanded.value;
  //                       },
  //                       child: CustomText(
  //                           text: controller.chargingCardExpanded.value
  //                               ? 'View Less'
  //                               : 'View More',
  //                           size: 13,
  //                           fontWeight: FontWeight.w600,
  //                           color: Color(0xff0047C3)),
  //                     ),
  //                   ],
  //                 ),
  //                 Expanded(
  //                   child: ListView.builder(
  //                       padding: EdgeInsets.only(top: 20.h),
  //                       itemCount:
  //                           !controller.chargingCardExpanded.value ? 1 : 20,
  //                       shrinkWrap: true,
  //                       itemBuilder: ((context, index) {
  //                         return nearestCharginStationCard(index);
  //                       })),
  //                 )
  //               ],
  //             ),
  //           )),
  //     ),
  //   );
  // }

  Widget nearestCharginStationCard(int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * .03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: cachedNetworkImage(
                controller.stationList[index].image,
                height: 40.h,
                width: 40.h,
              )
              //     Image.network(
              //   controller.stationList[index].image,
              //   height: size.width * .1,
              //   width: size.width * .1,
              // ),
              ),
          width(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: controller.stationList[index].name,
                  color: Color(0xff4f4f4f),
                  size: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                    text:
                        'DC ${controller.stationList[index].charger_capacity} kWh',
                    color: Color(0xff828282),
                    size: 12.sp,
                    fontWeight: FontWeight.normal),
              ],
            ),
          ),
          width(10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                  text:
                      '${controller.getDistance(controller.stationList[index].latitude, controller.stationList[index].longitude)}  Kms',
                  color: Color(0xff4f4f4f),
                  size: 12.sp,
                  fontWeight: FontWeight.bold),
              CustomText(
                  text: 'Away',
                  color: Color(0xff828282),
                  size: 12.sp,
                  fontWeight: FontWeight.normal),
            ],
          ),
        ],
      ),
    );
  }

  // Widget stepWidget() {
  //   return Container(
  //     // height: size.height * .10,
  //     // width: size.width,
  //     decoration: BoxDecoration(color: Color(0xff2B2B2B)),
  //     padding: EdgeInsets.symmetric(
  //         horizontal: size.width * .05, vertical: size.height * .01),
  //     child: Row(children: [
  //       Expanded(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Obx(
  //               () => Text(
  //                 'After ${MapFunctions().stepDistance.value} m',
  //                 style: GoogleFonts.inter(
  //                   fontSize: 13,
  //                   fontWeight: FontWeight.w500,
  //                   color: Colors.white.withOpacity(.6),
  //                 ),
  //               ),
  //             ),
  //             // height(3.h),
  //             Container(
  //               // color: Colors.amber,
  //               width: size.width,
  //               child: Obx(() =>
  //                   Html(data: """${MapFunctions().maneuverText}""", style: {
  //                     // "font":
  //                     // GoogleFonts.inter(
  //                     //   fontSize: 10,
  //                     //   fontWeight: FontWeight.w700,
  //                     //   color: Colors.white,
  //                     // ),
  //                     "body": Style(
  //                         padding: HtmlPaddings.all(0),
  //                         fontSize: FontSize.medium,
  //                         alignment: Alignment.topLeft,
  //                         color: Colors.white)
  //                   })),
  //             )
  //           ],
  //         ),
  //       ),
  //       // Spacer(),
  //       Padding(
  //         padding: EdgeInsets.symmetric(vertical: size.height * .02),
  //         child: SvgPicture.asset(
  //           'assets/svg/alt_route.svg',
  //           colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
  //         ),
  //       )
  //     ]),
  //   );
  // }

  // Widget bottomWidget() {
  //   return Container(
  //     height: size.height * .10,
  //     decoration: BoxDecoration(color: Colors.white),
  //     padding: EdgeInsets.symmetric(horizontal: size.width * .05),
  //     child: Row(children: [
  //       Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Booked : 4:30 pm',
  //             style: GoogleFonts.inter(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w600,
  //               color: Color(0xffAAAAAA),
  //             ),
  //           ),
  //           Obx(
  //             () => Text(
  //               '${MapFunctions().awayDistance.value / 1000.0} km Away',
  //               style: GoogleFonts.inter(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w700,
  //                 color: Color(0xff5c5c5c),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //       Spacer(),
  //       InkWell(
  //         onTap: () {
  //           Get.back();
  //         },
  //         child: Container(
  //           padding: EdgeInsets.symmetric(
  //               horizontal: size.width * .03, vertical: size.height * .007),
  //           decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(20),
  //               border: Border.all(color: Colors.black)),
  //           child: Row(
  //             children: [
  //               Text(
  //                 'End',
  //                 style: GoogleFonts.inter(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w500,
  //                   color: Color(0xff000000),
  //                 ),
  //               ),
  //               Icon(Icons.close)
  //             ],
  //           ),
  //         ),
  //       )
  //     ]),
  //   );
  // }

  Widget yourDestinationCard() {
    return Positioned(
        top: size.height * 0.04,
        width: size.width * .90,
        child: Container(
          child: Container(
            padding: EdgeInsets.only(
                // top: size.height * 0.07,
                // bottom: size.height * 0.02,
                ),
            height: size.height * 0.22,
            width: size.width,
            decoration: BoxDecoration(
              color: kwhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                  blurRadius: 32,
                  color: Color(0xff000000).withOpacity(0.06),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * .045),
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                              padding: EdgeInsets.all(3),
                              child: Icon(Icons.arrow_back_ios))),
                      width(size.width * .02),
                      CustomBigText(
                        text: 'Choose destinations',
                        size: 14,
                        color: Color(0xff4f4f4f),
                      ),
                    ],
                  ),
                ),
                height(size.height * .015),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: size.width * .05,
                        right: size.width * .015,
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/svg/adjust.svg'),
                          Column(
                            children: List.generate(
                                4,
                                (index) => Container(
                                      height: 4,
                                      width: 1,
                                      margin: EdgeInsets.symmetric(
                                          vertical: size.height * .0038),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey),
                                    )),
                          ),
                          SvgPicture.asset('assets/svg/location_on_red.svg')
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Obx(
                            () => rounded_container(
                              hintText: 'Starting point',
                              text: controller.source.value.placeId == null
                                  ? null
                                  : controller.source.value.description!
                                      .split(', ')
                                      .first,
                              onTap: () {},
                            ),
                          ),
                          height(size.height * .01),
                          Obx(
                            () => rounded_container(
                              hintText: 'Destination',
                              text: controller.destination.value.placeId == null
                                  ? null
                                  : controller.destination.value.description!
                                      .split(', ')
                                      .first,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    width(size.width * .051)
                  ],
                ),
                height(size.height * .01),
              ],
            ),
          ),
        ));
  }
}
