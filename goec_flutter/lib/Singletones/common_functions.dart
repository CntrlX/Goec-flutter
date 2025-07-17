import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dialogs.dart';
import 'package:get/get.dart';
import '../Utils/toastUtils.dart';
import '../Utils/api_constants.dart';
import '../Model/favoriteModel.dart';
import '../Model/notificationModel.dart';
import '../Model/activeSessionModel.dart';
import 'package:geolocator/geolocator.dart';
import '../Model/chargeTransactionModel.dart';
import 'package:freelancer_app/Utils/api.dart';
import 'package:freelancer_app/constants.dart';
import 'package:freelancer_app/Utils/routes.dart';
import 'package:freelancer_app/Model/userModel.dart';
import 'package:freelancer_app/Model/orderModel.dart';
import 'package:freelancer_app/Model/reviewMode.dart';
import 'package:freelancer_app/Model/vehicleModel.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:freelancer_app/Singletones/app_data.dart';
import 'package:freelancer_app/Model/apiResponseModel.dart';
import 'package:freelancer_app/Singletones/socketRepo.dart';
import 'package:freelancer_app/Model/searchStationModel.dart';
import 'package:freelancer_app/Model/stationMarkerModel.dart';
import 'package:freelancer_app/Utils/SharedPreferenceUtils.dart';
import 'package:freelancer_app/Model/chargeStationDetailsModel.dart';
import 'package:freelancer_app/Controller/walletPage_controller.dart';
import 'package:freelancer_app/Controller/notification_screen_controller.dart';

class CommonFunctions {
  //make it singleTone class
  static final CommonFunctions _singleton = CommonFunctions._internal();
  factory CommonFunctions() {
    return _singleton;
  }
  CommonFunctions._internal();
  //code starts from here

  final _razorpay = Razorpay();
  var _getOrderResponse;

  Future<void> handlePaymentSuccess(PaymentSuccessResponse response) async {
    /// call api here when it is success payment
    //SAVE THE PAYEMENT TO CMS
    await savePaymentRazorpay(payResponse: response);
    await CommonFunctions().getUserProfile();
    if (Get.currentRoute != Routes.rfidNumberRoute) {
      WalletPageController _walletPageController = Get.find();
      await _walletPageController.getWalletTransactions();
    }
    closeRazorPay();
  }

  void handlePaymentError(PaymentFailureResponse response) async {
    // Do something when payment fails
    await savePaymentRazorpay();
    if (Get.currentRoute != Routes.rfidNumberRoute) {
      WalletPageController _walletPageController = Get.find();
      await _walletPageController.getWalletTransactions();
    }
    closeRazorPay();
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected

    kLog(response);
  }

///////////////////////////////DONE////////////////////////////////
  void openRazorPay(
      {required int amount,
      required String order_id,
      required String descirption}) {
    if (order_id.isEmpty) return;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    var options = {
      // 'key': 'rzp_test_xZbHmrCgGp6f4n',
      'key': 'rzp_live_lUMWOKzR3TjDtx',
      // 'key': 'rzp_test_UVHUchmIfC00AX',
      'amount': amount * 100, //in the smallest currency sub-unit.
      'name': 'GOEC',
      'order_id': order_id, // Generate order_id using Orders API
      'description': descirption,
      'timeout': 300, // in seconds
      'prefill': {'contact': '9123456789', 'email': 'goev@gmail.com'}
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      showError('Failed to place order. Try again later!');
    }
  }

  void closeRazorPay() {
    _razorpay.clear();
  }

///////////////////////////////DONE////////////////////////////////
  Future<String> getOrderIdRazorpay(int amount) async {
    logger.i(amount);
    var res = await CallAPI().postData(
      {
        "amount": amount,
        "currency": "INR",
        'userId': appData.userModel.value.id,
        "type": "wallet top-up"
      },
      kApi_payment_url + 'paymentOrder',
    );
    _getOrderResponse = res.body;
    if (res.statusCode == 200) {
      return res.body['result']['id'];
    } else {
      showError('Failed to place order. Try again later!');
      return '';
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<void> savePaymentRazorpay(
      {PaymentSuccessResponse? payResponse}) async {
    var payload;
    if (payResponse != null) {
      payload = {
        'razorpay_order_id': payResponse.orderId,
        'razorpay_payment_id': payResponse.paymentId,
        'razorpay_signature': payResponse.signature,
        'userId': appData.userModel.value.id,
      };
    } else if (_getOrderResponse != null) {
      payload = {
        'razorpay_order_id': _getOrderResponse['result']['id'],
        'razorpay_payment_id': '',
        'razorpay_signature': '',
        'userId': appData.userModel.value.id,
      };
    } else {
      showError('Failed to update. Response is Empty');
    }
    logger.i(payload);
    var res =
        await CallAPI().postData(payload, kApi_payment_url + 'paymentVerify');
    _getOrderResponse = null;
    if (res.statusCode == 200 && res.body['status']) {
      if (Get.currentRoute == Routes.rfidNumberRoute) {
        showSuccess('Payment successful!');
      } else {
        Dialogs().rechargePopUp(isSuccess: true);
      }
    } else {
      if (Get.currentRoute == Routes.rfidNumberRoute) {
        showError('Payment failed with error code ${res.statusCode}!');
      } else {
        Dialogs().rechargePopUp(isSuccess: false);
      }
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<Map<String, dynamic>> getEvTemplates() async {
    ResponseModel res = await CallAPI().getData(kApi_vehicle_url + 'list');
    if (res.statusCode == 200 && res.body['status']) {
      List list = res.body['result'] ?? [];
      Map<String, dynamic> response = {};
      List<VehicleModel> brandVehicles = [];
      List<String> brands = [kAll];
      VehicleModel ev;
      list.forEach((element) {
        brandVehicles = [];
        brands.add(element['brand']);
        element['vehicles'].forEach((vehicleElement) {
          ev = VehicleModel.fromjson(vehicleElement);
          ev.brand = element['brand'];
          brandVehicles.add(ev);
        });
        response[element['brand']] = brandVehicles;
      });
      response['brands'] = brands;
      return response;
    } else {
      return {
        'brands': [kAll],
      };
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<bool> addEvToUser({
    required String vehicleId,
    required String regNumber,
  }) async {
    ResponseModel res = await CallAPI().putData({
      "evRegNumber": regNumber,
      "vehicleId": vehicleId,
    }, kApi_user_url + 'addVehicle/' + appData.userModel.value.id);
    kLog(res.body.toString());
    return (res.statusCode == 200 && res.body['status']);
  }

///////////////////////////////DONE////////////////////////////////
  Future<bool> setDefaultVehicle({required String regNumber}) async {
    ResponseModel res = await CallAPI().putData({
      "vehicleId": regNumber,
    }, kApi_user_url + 'updateDefaultVehicle/' + appData.userModel.value.id);
    kLog(res.body.toString());
    return (res.statusCode == 200 && res.body['status']);
  }

//? ///////////////////not implemented
  Future<bool> deleteEvOfUser(String regNumber) async {
    ResponseModel res = await CallAPI().putData(
      {"evRegNumber": regNumber},
      kApi_user_url + 'removeVehicle/' + appData.userModel.value.id,
    );
    return (res.statusCode == 200 && res.body['status']);
  }

///////////////////////////////DONE////////////////////////////////
  Future<List<VehicleModel>> getUserEvs() async {
    var res = await CallAPI()
        .getData(kApi_user_url + 'vehicleList/' + appData.userModel.value.id);
    kLog(res.body.toString());
    if (res.statusCode == 200 && res.body['status']) {
      List<VehicleModel> list = [];
      res.body['result'].forEach((element) {
        list.add(VehicleModel.fromjson(element));
      });
      kLog(list.length.toString());
      return list;
    } else {
      return [];
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<UserModel> getUserProfile() async {
    var res = await CallAPI().getData(
        kApi_user_url + 'user/byMobileNo/' + appData.userModel.value.username);
    if (res.statusCode == 200 && res.body['result'] != null) {
      logger.i(res.body);
      return appData.userModel.value = UserModel.fromJson(res.body['result']);
    } else {
      kUserModel.username = '';
      if (res.statusCode == 500) {
        clearData();
        appData.token = '';
      }
      return kUserModel;
    }
  }

  ///////////////////////////////DONE////////////////////////////////
  Future<bool> putUserNameEmail(String name, String email) async {
    kLog('username' + appData.userModel.value.username);
    var res = await CallAPI().putData({
      "username": name,
      "email": email,
    }, kApi_user_url + 'update/byMobileNo/' + appData.userModel.value.username);
    if (res.statusCode == 200 && res.body['status']) {
      return true;
    } else {
      showError('Failed to save name and email.');
      return false;
    }
  }

  ///////////////////////////////DONE////////////////////////////////
  Future<bool> putUserProfile(String name, String email, String phone) async {
    var res = await CallAPI().putData({
      "username": name,
      "email": email,
      "mobile": phone,
    }, kApi_user_url + 'update/byMobileNo/' + appData.userModel.value.username);
    if (res.statusCode == 200 && res.body['status']) {
      appData.userModel.value = UserModel.fromJson(res.body['result']);
      return true;
    } else {
      showError('Failed to save name and email.');
      return false;
    }
  }

  ///////////////////////////////DONE////////////////////////////////
  Future<bool> putProfileImage(File file) async {
    String url = await CallAPI().uploadFile(file);
    if (url != '') {
      var res = await CallAPI().putData(
        {
          "image": url,
        },
        kApi_user_url + 'update/byMobileNo/' + appData.userModel.value.username,
      );
      if (res.statusCode == 200 && res.body['status']) {
        return true;
      } else {
        showError('Failed to save profile image.');
        return false;
      }
    } else {
      showError('Failed to save profile image.');
      return false;
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<bool> updateFcmToken({
    required String token,
  }) async {
    ResponseModel res = await CallAPI().putData({
      "firebaseToken": token,
    }, kApi_user_url + 'updateFirebaseId/' + appData.userModel.value.id);
    return (res.statusCode == 200 && res.body['status']);
  }

///////////////////////////////DONE////////////////////////////////
  Future<bool> deleteUser() async {
    var res = await CallAPI()
        .deleteData({}, kApi_user_url + appData.userModel.value.id);
    if (res.statusCode == 200 && res.body['status']) {
      return true;
    } else {
      return false;
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<int> getRFIDPrice() async {
    var res = await CallAPI()
        .getData(kApi_rfid_url + 'config/byName/rfid-default-price');
    if (res.statusCode == 200 && res.body['status']) {
      return double.parse(res.body['result']).toInt();
    } else {
      return 0;
    }
  }

  ///////////////////////////////DONE////////////////////////////////
  Future<List<StationMarkerModel>> getNearestChargstations(Position pos) async {
    var res = await CallAPI().postData({
      "latitude": "${pos.latitude}",
      "longitude": "${pos.longitude}",
    }, kApi_station_url + 'nearBy/list');
    if (res.statusCode == 200 && res.body['status']) {
      List<StationMarkerModel> list = [];
      res.body['result'].forEach((element) {
        list.add(StationMarkerModel.fromJson(element));
      });
      return list;
    } else {
      return [];
    }
  }

  ///////////////////////////////DONE////////////////////////////////
  Future<List<StationMarkerModel>> getInbetweenChargstations(
      List<LatLng> latlng) async {
    // logger.i(latlng.map((e) => [e.latitude, e.longitude]).toList());
    logger.i({
      "start": {
        "latitude": latlng.first.latitude,
        "longitude": latlng.first.longitude
      },
      "end": {
        "latitude": latlng.last.latitude,
        "longitude": latlng.last.longitude
      }
    });
    var res = await CallAPI().postData({
      "start": {
        "latitude": latlng.first.latitude,
        "longitude": latlng.first.longitude
      },
      "end": {
        "latitude": latlng.last.latitude,
        "longitude": latlng.last.longitude
      }
      // "coordinates": latlng.map((e) => [e.latitude, e.longitude]).toList(),
    }, kApi_station_url + 'inbetween-points/list');
    if (res.statusCode == 200 && res.body['success']) {
      List<StationMarkerModel> list = [];
      res.body['result'].forEach((element) {
        list.add(StationMarkerModel.fromJson(element));
      });
      return list;
    } else {
      return [];
    }
  }

  ///////////////////////////////DONE////////////////////////////////
  Future<ChargeStationDetailsModel> getChargeStationDetails(String id) async {
    var res = await CallAPI().postData({
      "mobileNo": appData.userModel.value.username,
    }, kApi_station_url + id);
    if (res.statusCode == 200 && res.body['status']) {
      return ChargeStationDetailsModel.fromJson(res.body['result']);
    } else {
      return kChargeStationDetailsModel;
    }
  }

  ///////////////////////////////DONE////////////////////////////////
  Future<List<SearchStationrModel>> getSearchedChargeStations(
      String name) async {
    var res = await CallAPI().postData({
      'name': name,
    }, kApi_station_url + 'list/byName');
    if (res.statusCode == 200 && res.body['status']) {
      List<SearchStationrModel> list = [];
      res.body['result'].forEach((element) {
        list.add(SearchStationrModel.fromJson(element));
      });
      return list;
    } else {
      return [];
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<bool> postReviewForChargeStation(
    String id,
    int rating,
    String review,
  ) async {
    var res = await CallAPI().postData(
      {
        "user": appData.userModel.value.id,
        "chargingStation": id,
        "rating": "$rating",
        "comment": review.trim(),
      },
      kApi_review_url + 'create',
    );
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        res.body['status']) {
      return true;
    } else {
      return false;
    }
  }

  ///////////////////////////////DONE////////////////////////////////
  Future<List<ReviewModel>> getReviewOfStation(String stationId) async {
    var res = await CallAPI().postData({
      'chargingStation': stationId,
    }, kApi_review_url + 'getReviews');
    if (res.statusCode == 200 && res.body['status']) {
      List<ReviewModel> list = [];
      res.body['result'].forEach((element) {
        list.add(ReviewModel.fromJson(element));
      });
      return list;
    } else {
      return [];
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<bool> sendOtp(String username) async {
    logger.i(username);
    var res = await CallAPI().getData(
      kApi_user_url + 'sendOtp/' + username.trim(),
    );
    if (res.statusCode == 200 && res.body['status']) {
      logger.d(res.body['otp']);
      return true;
    } else {
      return false;
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<ResponseModel> verifyOTP(String username, String otp) async {
    var res = await CallAPI().putData(
      {"otp": otp},
      kApi_user_url + 'login/' + username.replaceAll(' ', ''),
    );
    if (res.statusCode == 200 && res.body['status']) {
      return res;
    } else {
      return ResponseModel(statusCode: 500, body: '');
    }
  }

  ////////////! CHARGING API's //////////////////////
  ///ontap
  Future createBookingAndCheck(
      ActiveSessionModel charger, String? stationName) async {
    showLoading('Checking existing active session...');
    if (SocketRepo().isCharging.value) {
      showError('Active session is going on');
      return;
    }
    showLoading('Creating booking...');
    bool sucess = await CommonFunctions().checkBalance();
    hideLoading();
    if (sucess) {
      Dialogs().tariffPopUp(charger, stationName);
    } else {
      Dialogs().notEnoughCreditPopUp();
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<bool> checkBalance() async {
    var res = await CallAPI().getData(
      kApi_user_url +
          'transaction/authenticate/byId/' +
          appData.userModel.value.id,
    );
    if (res.statusCode == 200 && res.body['status']) {
      return true;
    } else {
      return false;
    }
  }

  ///////////////////////////////DONE////////////////////////////////
  Future<bool> startCharging(
      {required String connectorId, required String cpid}) async {
    showLoading('Connecting...');
    var res = await CallAPI().postData(
      {
        "idTag": appData.userModel.value.userId,
        "connectorId": int.parse(connectorId)
      },
      kApi_ocpp_url + 'remoteStartTransaction/' + cpid,
    );
    hideLoading();
    if (res.statusCode == 200 && res.body['status']) {
      return true;
    } else {
      return false;
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<ActiveSessionModel> getActiveSession() async {
    var res = await CallAPI()
        .getData(kApi_ocpp_url + 'activeSession/' + appData.userModel.value.id);
    if (res.statusCode == 200 && res.body['result']['transactionId'] != null) {
      return ActiveSessionModel.fromJson(res.body['result']);
    } else {
      return kActiveSessionModel;
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<bool> stopCharging(
      {required String transactionId,
      required String cpid,
      required String connectorId}) async {
    var res = await CallAPI().postData(
      {
        "transactionId": transactionId,
        "CPID": cpid,
        "connectorId": connectorId,
      },
      kApi_ocpp_url + 'remoteStopTransaction/' + cpid,
    );
    if (res.statusCode == 200 && res.body['status']) {
      kLog('booking cancelled successfully');
      return true;
    } else
      return false;
  }

  ////////////! CHARGING API's //////////////////////

///////////////////////////////DONE////////////////////////////////
  Future<List<OrderModel>> getWalletTransactions(
      String startdate, String enddate, List mode, List status) async {
    var res = await CallAPI().postData(
      {
        'user': appData.userModel.value.id,
        if (startdate.isNotEmpty) 'fromDate': startdate,
        if (enddate.isNotEmpty) 'toDate': enddate,
        if (mode.isNotEmpty && mode.length == 1) 'paymentModes': mode[0],
        if (status.isNotEmpty && status.length == 1) 'status': status[0],
      },
      kApi_wallet_url + 'filteredList',
    );
    if (res.statusCode == 200 && res.body['status']) {
      List<OrderModel> list = [];
      res.body['result'].forEach((element) {
        list.add(OrderModel.fromJson(element));
      });
      return list;
    } else {
      return [];
    }
  }

  //Todo
  Future<List<NotificationModel>> getNotifications(
      String page, String size) async {
    var res = await CallAPI().getData(
      kApi_notification_url + 'list/' + appData.userModel.value.id,
    );
    if (res.statusCode == 200 && res.body['status']) {
      List<NotificationModel> list = [];
      NotificationScreenController _walletPageController = Get.find();
      _walletPageController.totalElements = res.body['result'].length;
      res.body['result'].forEach((element) {
        list.add(NotificationModel.fromJson(element));
      });
      return list;
    } else {
      return [];
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<List<ChargeTransactionModel>> getChargeTransactions(
      String pageNo, String startdate, String enddate) async {
    var res = await CallAPI().postData({
      'pageNo': pageNo,
      if (startdate.isNotEmpty) 'fromDate': startdate,
      if (enddate.isNotEmpty) 'toDate': enddate,
    }, kApi_ocpp_url + 'chargingHistory/' + appData.userModel.value.id);
    if (res.statusCode == 200 && res.body['success']) {
      appData.chargingHistoryCount = res.body['totalCount'];
      List<ChargeTransactionModel> list = [];
      res.body['result'].forEach((element) {
        list.add(ChargeTransactionModel.fromJson(element));
      });
      return list;
    } else {
      return [];
    }
  }

  downloadBookingInvoice(int transactionId) async {
    kLog(transactionId.toString());
    await CallAPI().downloadPdf(transactionId);
  }

  downloadWalletInvoice(String tranId) async {
    kLog(tranId.toString());
    // await CallAPI()
    //     .download('walletinvoice?tranId=$tranId', 'wallet_invoice_$tranId');
  }

///////////////////////////////DONE////////////////////////////////
  Future<List<FavoriteModel>> getFavorites() async {
    var res = await CallAPI().postData({
      'mobileNo': appData.userModel.value.username,
    }, kApi_station_url + 'favorite/list');
    kLog(res.body.toString());
    if (res.statusCode == 200 && res.body.isNotEmpty && res.body['status']) {
      List<FavoriteModel> list = [];
      res.body['result'].forEach((element) {
        list.add(FavoriteModel.fromJson(element));
      });
      return list;
    } else {
      return [];
    }
  }

///////////////////////////////DONE////////////////////////////////
  Future<bool> changeFavorite({
    required String stationId,
    required bool makeFavorite,
  }) async {
    logger.f(appData.userModel.value.id);
    var res;
    if (makeFavorite) {
      res = await CallAPI().putData(
        {
          "favoriteStation": stationId,
        },
        kApi_user_url + 'addFavoriteStation/' + appData.userModel.value.id,
      );
    } else {
      res = await CallAPI().putData(
        {
          "favoriteStation": stationId,
        },
        kApi_user_url + 'removeFavoriteStation/' + appData.userModel.value.id,
      );
    }
    kLog(res.body.toString());
    if (res.statusCode == 200 && res.body['status']) {
      return true;
    } else {
      return false;
    }
  }
}
