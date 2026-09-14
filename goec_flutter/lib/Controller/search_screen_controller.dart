import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/stationMarkerModel.dart';
import 'homepage_controller.dart';

class SearchScreenController extends GetxController {
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final RxString searchQuery = ''.obs;
  final RxList<StationMarkerModel> searchResults = <StationMarkerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(_onSearchChanged);
    if (Get.isRegistered<HomePageController>()) {
      final home = Get.find<HomePageController>();
      if (home.station_marker_list.isEmpty) {
        home.onReload();
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Smoothly focus text field after hero page transition completes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!isClosed && !searchFocusNode.hasFocus) {
        searchFocusNode.requestFocus();
      }
    });
  }

  void _onSearchChanged() {
    final text = searchTextController.text;
    searchQuery.value = text;
    filterStations(text);
  }

  void filterStations(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      searchResults.clear();
      return;
    }

    if (Get.isRegistered<HomePageController>()) {
      final homeController = Get.find<HomePageController>();
      final allStations = homeController.station_marker_list;

      final matched = allStations.where((s) {
        final name = s.name.toLowerCase();
        final addr = s.address.toLowerCase();
        final connectorTypes =
            s.charger_type.map((e) => e.toString().toLowerCase()).join(' ');

        return name.contains(cleanQuery) ||
            addr.contains(cleanQuery) ||
            connectorTypes.contains(cleanQuery);
      }).toList();

      searchResults.assignAll(matched);
    }
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  @override
  void onClose() {
    searchTextController.removeListener(_onSearchChanged);
    searchFocusNode.dispose();
    searchTextController.dispose();
    super.onClose();
  }
}
