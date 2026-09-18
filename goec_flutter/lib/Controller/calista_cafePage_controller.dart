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

  /// True while connectors / live fields are fetched after instant preview nav.
  RxBool isLoadingDetails = false.obs;

  TextEditingController reviewController = TextEditingController();
  Rx<DirectionsResult> directionsResult = DirectionsResult().obs;
  Rx<AutocompletePrediction> source = AutocompletePrediction().obs,
      destination = AutocompletePrediction().obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _hydrateFromArguments(Get.arguments);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _hydrateFromArguments(dynamic args) {
    if (args == null) return;

    // Instant nav: { station: ChargeStationDetailsModel, loadDetails: true }
    if (args is Map) {
      final station = args['station'];
      final loadDetails = args['loadDetails'] == true;
      if (station is ChargeStationDetailsModel) {
        applyModel(station);
        if (loadDetails || station.chargers.isEmpty) {
          refreshStationDetails();
        }
      }
      return;
    }

    if (args is String) {
      getChargeStationDetails(args);
      return;
    }

    if (args is ChargeStationDetailsModel) {
      applyModel(args);
      if (args.chargers.isEmpty) {
        refreshStationDetails();
      }
    }
  }

  void applyModel(ChargeStationDetailsModel station) {
    model.value = station;
    amenities.value = List.from(station.amenities);
    _recomputeDistanceAndHours();
  }

  void _recomputeDistanceAndHours() {
    if (MapFunctions().curPos.latitude != 0) {
      distance.value = (MapFunctions.distanceBetweenCoordinates(
                  MapFunctions().curPos.latitude,
                  MapFunctions().curPos.longitude,
                  model.value.latitude,
                  model.value.longitude) /
              1000.0)
          .toPrecision(2);
    } else {
      distance.value = 0;
    }
    isOpen.value =
        isTimeInRange(model.value.startTime, model.value.stopTime);
  }

  /// Pull-to-refresh / post-preview hydrate.
  Future<void> refreshStationDetails() async {
    final id = model.value.id;
    if (id.isEmpty || id == '-1') return;

    isLoadingDetails.value = true;
    // Clear stale selection while connectors reload.
    selectedCharger.value = -1;
    selectedType.value = -1;
    try {
      final full = await CommonFunctions().getChargeStationDetails(id);
      applyModel(full);
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> getChargeStationDetails(String stationId) async {
    isLoadingDetails.value = true;
    try {
      final full =
          await CommonFunctions().getChargeStationDetails(stationId);
      applyModel(full);
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Radio-style connector selection (tap again to clear).
  void selectConnector(int chargerIndex, int portIndex) {
    if (selectedCharger.value == chargerIndex &&
        selectedType.value == portIndex) {
      selectedCharger.value = -1;
      selectedType.value = -1;
      return;
    }
    selectedCharger.value = chargerIndex;
    selectedType.value = portIndex;
  }

  @Deprecated('Use selectConnector')
  changeCharger(int index, int index_grid) {
    selectConnector(index, index_grid);
  }

  bool get hasConnectorSelected =>
      selectedCharger.value != -1 && selectedType.value != -1;

  String get selectedConnectorLabel {
    if (!hasConnectorSelected) return '';
    final charger = model.value.chargers[selectedCharger.value];
    final port = charger.evports[selectedType.value];
    final type = port.connectorType.trim().isEmpty
        ? 'Connector'
        : port.connectorType.trim();
    return '$type · Connector ${selectedType.value + 1}';
  }

  String get selectedTariffLabel {
    if (!hasConnectorSelected) return '';
    final tariff = double.tryParse(
            model.value.chargers[selectedCharger.value].tariff) ??
        0;
    return '$kCurrency${tariff.toStringAsFixed(2)}/kWh';
  }

  String get selectedChargerCtaLabel {
    if (!hasConnectorSelected) return 'Start Charging';
    return 'Start Charging · Connector ${selectedType.value + 1}';
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
    final targetState = !model.value.isFavorite;
    bool res = await CommonFunctions().changeFavorite(
        stationId: model.value.id, makeFavorite: targetState);
    if (res) {
      model.value.isFavorite = targetState;
      model.refresh();
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
