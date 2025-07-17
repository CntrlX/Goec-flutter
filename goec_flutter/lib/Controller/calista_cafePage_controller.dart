import 'package:get/get.dart';
import '../Utils/routes.dart';
import '../Utils/toastUtils.dart';
import 'package:flutter/material.dart';
import '../Model/activeSessionModel.dart';
import '../Singletones/map_functions.dart';
import 'package:share_plus/share_plus.dart';
import '../Singletones/common_functions.dart';
import 'package:freelancer_app/constants.dart';
import 'package:freelancer_app/Utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_place_plus/google_place_plus.dart';
import 'package:freelancer_app/Singletones/app_data.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:freelancer_app/Model/chargeStationDetailsModel.dart';

class CalistaCafePageController extends GetxController {
  RxInt selectedCharger = (-1).obs;
  RxInt selectedType = (-1).obs;
  RxInt itemCountPerConnector = 3.obs;
  RxBool isOpen = false.obs;
  RxDouble distance = 0.0.obs;
  Rx<ChargeStationDetailsModel> model = kChargeStationDetailsModel.obs;
  RxList amenities = RxList();
  RxInt selectedRating = 0.obs;
  TextEditingController reviewController = TextEditingController();
  Rx<DirectionsResult> directionsResult = DirectionsResult().obs;
  Rx<AutocompletePrediction> source = AutocompletePrediction().obs,
      destination = AutocompletePrediction().obs;
  @override
  void onInit() {
    // / implement onInit

    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is String)
        getChargeStationDetails('${Get.arguments}');
      else
        assignPreviouslyGotModel();
    }
  }

  assignPreviouslyGotModel() {
    model.value = Get.arguments;
    amenities.value = model.value.amenities;
    distance.value = (MapFunctions.distanceBetweenCoordinates(
                MapFunctions().curPos.latitude,
                MapFunctions().curPos.longitude,
                model.value.latitude,
                model.value.longitude) /
            1000.0)
        .toPrecision(2);
    isOpen.value = isTimeInRange(model.value.startTime, model.value.stopTime);
  }

//THIS FUNCTION IS NOT USED HERE. IF NEEDED THEN WE WILL USE IT
  getChargeStationDetails(String stationId) async {
    // showLoading(kLoading);
    model.value = await CommonFunctions().getChargeStationDetails(stationId);
    amenities.value = model.value.amenities;
    kLog(model.value.isFavorite.toString());
    if (MapFunctions().curPos.latitude != 0) {
      distance.value = (MapFunctions.distanceBetweenCoordinates(
                  MapFunctions().curPos.latitude,
                  MapFunctions().curPos.longitude,
                  model.value.latitude,
                  model.value.longitude) /
              1000.0)
          .toPrecision(2);
    }
    isOpen.value = isTimeInRange(model.value.startTime, model.value.stopTime);
    // hideLoading();
  }

  changeCharger(int index, int index_grid) {
    if (selectedCharger.value != -1)
      selectedCharger.value = -1;
    else
      selectedCharger.value = index;
    if (selectedType.value != -1)
      selectedType.value = -1;
    else
      selectedType.value = index_grid;
  }

  postReviewForChargeStation() async {
    showLoading(kLoading);
    bool status = await CommonFunctions().postReviewForChargeStation(
        model.value.id, selectedRating.value, reviewController.text);
    hideLoading();
    return status;
  }

  startCharging() {
    appData.tempActiveSessionModel = ActiveSessionModel(
        capacity: double.tryParse(
                model.value.chargers[selectedCharger.value].capacity) ??
            0,
        chargerName: model.value.chargers[selectedCharger.value].chargerName,
        connectorId: model.value.chargers[selectedCharger.value]
            .evports[selectedType.value].connectorId
            .toString(),
        connectorType: model.value.chargers[selectedCharger.value]
            .evports[selectedType.value].connectorType,
        cpid: model.value.chargers[selectedCharger.value].cpid,
        outputType: model.value.chargers[selectedCharger.value].outputType,
        tariff:
            double.parse(model.value.chargers[selectedCharger.value].tariff),
        transactionId: '-1',
        unitUsed: 0,
        startTime: '',
        chargingStationId: '',
        currentSoc: 0);
    appData.qr = '${model.value.id}' +
        '-' +
        model.value.chargers[selectedCharger.value].cpid +
        '-' +
        '${model.value.chargers[selectedCharger.value].evports[selectedType.value].connectorId}' +
        '-' +
        'A';
    CommonFunctions().createBookingAndCheck(
      appData.tempActiveSessionModel,
      model.value.name,
    );
  }

  getDirections(bool isNavigation) async {
    showLoading(kLoading);
    List<String> list = await MapFunctions().getNameAndPlaceIdFromLatLng(
        MapFunctions().curPos.latitude, MapFunctions().curPos.longitude);
    source.value = AutocompletePrediction(
      description: list[0],
      placeId: list[1],
    );
    list = await MapFunctions().getNameAndPlaceIdFromLatLng(
        model.value.latitude, model.value.longitude);
    destination.value = AutocompletePrediction(
      description: list[0],
      placeId: list[1],
    );
    directionsResult.value =
        (await MapFunctions().getDirections(source.value, destination.value)) ??
            DirectionsResult();
    hideLoading();
    if (directionsResult.value.status == DirectionsStatus.ok) {
      Get.toNamed(
          isNavigation
              ? Routes.navigationPageRoute
              : Routes.directionsPageRoute,
          arguments: [directionsResult, source, destination]);
    }
  }

  changeFavoriteStatus() async {
    showLoading(kLoading);
    bool res = await CommonFunctions().changeFavorite(
        stationId: model.value.id, makeFavorite: !model.value.isFavorite);
    if (res) {
      await getChargeStationDetails(model.value.id.toString());
    }
    hideLoading();
  }

  launchOnGoogleMap() {
    launchUrlString(
        'https://www.google.com/maps/dir/?api=1&destination=${model.value.latitude},${model.value.longitude}',
        mode: LaunchMode.externalApplication);
  }

  shareStationLocation() {
    Share.share(
        'Check out the ${model.value.name} chargestation by clicking the following link:\n https://www.google.com/maps/dir/?api=1&destination=${model.value.latitude},${model.value.longitude}',
        subject: 'Checkout ${model.value.name} station!');
  }
}
