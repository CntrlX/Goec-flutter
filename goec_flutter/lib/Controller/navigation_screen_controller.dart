import 'package:get/get.dart';
import '../Model/stationMarkerModel.dart';
import '../Singletones/map_functions.dart';
import 'package:google_place_plus/google_place_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_directions_api/google_directions_api.dart';

class NavigationScreenController extends GetxController {
  RxInt reload = 0.obs;
  RxBool chargingCardExpanded = false.obs;
  Rx<AutocompletePrediction> source = AutocompletePrediction().obs;
  Rx<AutocompletePrediction> destination = AutocompletePrediction().obs;
  Rx<DirectionsResult> directionsResult = DirectionsResult().obs;
  RxList<StationMarkerModel> stationList = RxList();

  @override
  void onInit() {
    // / implement onInit
    super.onInit();
    MapFunctions()
        .markers
        .removeWhere((element) => element.markerId == MarkerId('myMarker'));
    getArguments();
    initMap();
  }

  getArguments() {
    directionsResult = Get.arguments[0];
    source = Get.arguments[1];
    destination = Get.arguments[2];
    stationList.value = Get.arguments[3];
    // MapFunctions().steps.value = 0;
    // MapFunctions().maneuverText.value = 'Go Straight';
    MapFunctions().checkForUpdateSteps();
  }

  initMap() {
    MapFunctions().addCarMarker(MapFunctions().curPos);
    Future.delayed(Duration(milliseconds: 1000), () {
      // MapFunctions().setMapFitToPolyline(
      //   MapFunctions().polylines,
      //   MapFunctions().dirMapController,
      //   isNavigation: true,
      // );
      MapFunctions().animateForNavigation(MapFunctions().curPos);
      // MapFunctions().animatePolyline(MapFunctions().polylineString, reload);
    });
  }

  double getDistance(double latitude, double longitude) {
    return (MapFunctions.distanceBetweenCoordinates(
                MapFunctions().curPos.latitude,
                MapFunctions().curPos.longitude,
                latitude,
                longitude) /
            1000.0)
        .toPrecision(2);
  }
}
