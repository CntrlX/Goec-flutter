
import 'dart:developer';
import '../constants.dart';
import 'package:get/get.dart';
import '../Utils/routes.dart';
import '../Utils/toastUtils.dart';
import 'package:flutter/material.dart';
import '../Model/stationMarkerModel.dart';
import '../Singletones/common_functions.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_place_plus/google_place_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:freelancer_app/Singletones/map_functions.dart';
import 'package:google_directions_api/google_directions_api.dart';

class DirectionsScreenController extends GetxController {
  RxInt reload = 0.obs;
  Rx<AutocompletePrediction> source = AutocompletePrediction().obs;
  Rx<AutocompletePrediction> destination = AutocompletePrediction().obs;
  Rx<DirectionsResult> directionsResult = DirectionsResult().obs;
  final TextEditingController tripsNameController = TextEditingController();
  RxList<StationMarkerModel> stationList = RxList();
  RxInt saveCount = 0.obs;
  RxBool isSaved = false.obs;
  RxString distance = ''.obs;
  String duration = '';
  RxString route_via = ''.obs;
  @override
  void onInit() {
    // / implement onInit
    super.onInit();
    MapFunctions().polylines = {};
    MapFunctions().markers = {};
    // getArguments();
    // initMap();
  }

  void getArguments() {
    directionsResult = Get.arguments[0];
    source = Get.arguments[1];
    destination = Get.arguments[2];
  }

  void initMap() async {
    MapFunctions()
        .addMyPositionMarker(MapFunctions().curPos, MapFunctions().markers);
    Future.delayed(Duration(milliseconds: 1000), () {
      log('delayed');
      log(MapFunctions().polylineString);
      MapFunctions().setMapFitToPolyline(
        MapFunctions().polylines,
        MapFunctions().dirMapController!,
      );
    });
    distance.value =
        (directionsResult.value.routes?.first.legs?.first.distance?.text ??
                '0 KMS')
            .replaceFirst('km', 'KMS');
    duration =
        directionsResult.value.routes?.first.legs?.first.duration?.text ??
            '0 hr 0 min';

    getroute(MapFunctions().polylines.first.points).then((value) {
      route_via.value = value.first.split(RegExp(r'[,]'))[1];
    });
  }

  Future<void> getDirectionsPolyline() async {
    if (source.value.placeId != null && destination.value.placeId != null) {
      showLoading('Fetching nearby charge stations.\nPlease wait...');
      var direction =
          await MapFunctions().getDirections(source.value, destination.value);

      if (direction != null) {
        directionsResult.value = direction;
        stationList.value = await CommonFunctions()
            .getInbetweenChargstations(MapFunctions().polylines.first.points);

        ///
        // stationList = await CommonFunctions().getNearestChargstations(
        //   Position(
        //     latitude: 10.789062462150037,
        //     longitude: 76.17657098919153,
        //     timestamp: DateTime.now(),
        //     accuracy: 0,
        //     altitude: 0,
        //     altitudeAccuracy: 0,
        //     heading: 0,
        //     headingAccuracy: 0,
        //     speed: 0,
        //     speedAccuracy: 0,
        //   ),
        // );

        ///
        stationList.forEach((element) {
          MapFunctions().addMarkerTripPage(
            id: element.id.toString(),
            latLng: LatLng(element.latitude, element.longitude),
            status: element.charger_status.trim(),
          );
        });

        initMap();
        logger.i(stationList.length);
        hideLoading();
      } else {
        showError('Failed to get direction');
      }
    }
  }

  getSource() {
    Get.toNamed(Routes.searchPlacesPageRoute)!.then((value) {
      if (value == null || value.isEmpty) return;
      source.value = value[0];
      getDirectionsPolyline();
    });
  }

  getDestination() {
    Get.toNamed(Routes.searchPlacesPageRoute)!.then((value) {
      if (value == null || value.isEmpty) return;
      destination.value = value[0];
      getDirectionsPolyline();
    });
  }

  Future<List<String>> getroute(List<LatLng> latlng) async {
    var res = await MapFunctions().getNameAndPlaceIdFromLatLng(
      latlng[latlng.length ~/ 2].latitude,
      latlng[latlng.length ~/ 2].longitude,
    );
    return res;
  }

  @override
  void onClose() {
    // / implement onClose
    super.onClose();
    MapFunctions().dirMapController?.dispose();
    MapFunctions().timer?.cancel();
  }
}
