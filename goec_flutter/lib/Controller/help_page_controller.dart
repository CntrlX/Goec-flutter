// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HelpPageController extends GetxController {
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
  CarouselController? carouselController;
  RxDouble currentIndex = 0.0.obs;
  String phnNumber = "+919778687615";

  Future<void> openWhatsApp() async {
    var url = "https://wa.me/${phnNumber}";
    if (await launch(url)) {
      kLog("launching $url");
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

  @override
  void onInit() {
    // / implement onInit
    super.onInit();
  }
}
