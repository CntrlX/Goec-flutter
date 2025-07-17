import 'dart:async';
import '../Utils/utils.dart';
import 'package:get/get.dart';
import '../Utils/routes.dart';
import '../Singletones/dialogs.dart';
import '../Singletones/app_data.dart';
import '../Model/activeSessionModel.dart';
import '../Utils/local_notifications.dart';
import 'package:freelancer_app/constants.dart';
import 'package:freelancer_app/Singletones/socketRepo.dart';
import 'package:freelancer_app/Model/chargingStatusModel.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';

class ChargingScreenController extends GetxController {
  RxList<int> time = [0, 0].obs;
  RxString chargingStatus = "".obs;
  bool showLowBalanceOnlyOnce = true;
  ActiveSessionModel activeSessionModel = kActiveSessionModel;
  Rx<ChargingStatusModel> status_model = kChargingStatusModel.obs;

  onInit() {
    super.onInit();
    getArguments();
    getChargingStatus();
  }

  getArguments() {
    activeSessionModel =
        Get.arguments != null ? Get.arguments : appData.tempActiveSessionModel;
  }

  onClose() {
    super.onClose();
  }

  Future stopCharging() async {
    bool res = await CommonFunctions().stopCharging(
      connectorId: activeSessionModel.connectorId,
      cpid: activeSessionModel.cpid,
      transactionId: activeSessionModel.transactionId,
    );
    if (res) {
      toDisconnected();
    }
  }

  ///ChargingStatus
  Future getChargingStatus() async {
    ActiveSessionModel res = await CommonFunctions().getActiveSession();
    logger.i('transactionId ${res.transactionId}');
    if (res.transactionId != '-1') {
      activeSessionModel = res;
      status_model.value.status = 'Charging';
    } else {
      status_model.value.status = 'Initiated';
    }
    res = kActiveSessionModel;

    _repeatCall();

    // Define a timer that stops the loop after 3 minutes
    Timer(Duration(minutes: 3), () {
      if (activeSessionModel.transactionId == '-1') {
        activeSessionModel = ActiveSessionModel(
          startTime: '',
          transactionId: '-2',
          chargerName: '',
          connectorType: '',
          outputType: '',
          tariff: 0,
          unitUsed: 0,
          capacity: 0,
          connectorId: '',
          cpid: '',
          chargingStationId: '',
          currentSoc: 0,
        );
      }
    });

    //? Try untill the transaction table updated by charger.
    while (activeSessionModel.transactionId == '-1') {
      res = await CommonFunctions().getActiveSession();
      if (res.transactionId != '-1') {
        activeSessionModel = res;
        status_model.value.status = 'Charging';
      }
      res = kActiveSessionModel;
      await Future.delayed(Duration(seconds: 10));
    }
    //? ///////////////////
    showLowBalanceOnlyOnce = true;

    status_model.value.capacity = activeSessionModel.capacity;
    status_model.value.outputType = activeSessionModel.outputType;
    status_model.value.connectorType = activeSessionModel.connectorType;
    status_model.value.amount =
        (activeSessionModel.tariff) * activeSessionModel.unitUsed;
    status_model.value.unitUsed = activeSessionModel.unitUsed;
    status_model.value.percentage = activeSessionModel.currentSoc;
    time.value = getTimeDifference(
      startTime: activeSessionModel.startTime,
      endtime: DateTime.now().toIso8601String(),
    );

    /////INIT WEBSOCKET FROM HERE

    await SocketRepo().closeSocket();
    if (activeSessionModel.transactionId != '-1' &&
        activeSessionModel.transactionId != '-2') {
      SocketRepo().initSocket(
          tranId: activeSessionModel.transactionId,
          fun: (message) async {
            if (message != null && message['status'] == 'Completed') {
              status_model.value.status = 'Completed';
            } else if (message != null &&
                (message['type'] == 'transactionStop' ||
                    message['type'] == 'Transaction Stopped')) {
              status_model.value.status = 'Disconnected';
              await SocketRepo().closeSocket();
            } else if (message != null) {
              status_model.value = ChargingStatusModel.fromJson(message);
              appData.userModel.value.balanceAmount =
                  status_model.value.balance;
            }

            status_model.value.capacity = activeSessionModel.capacity;
            status_model.value.outputType = activeSessionModel.outputType;
            status_model.value.connectorType = activeSessionModel.connectorType;
            status_model.value.amount =
                (activeSessionModel.tariff) * status_model.value.unitUsed;

            _repeatCall();
          });
    }
  }

  _repeatCall() {
    switch (status_model.value.status) {
      case 'Initiated':
        {
          if (Get.isDialogOpen == false)
            Dialogs().gunStatusAlert(
              'Plug in the Connector',
              'Please make sure the connector is plugged-in',
            );
          toInitiating();
        }
        break;
      case 'Charging':
        {
          if (chargingStatus.value != 'progress' &&
              chargingStatus.value != 'finishing') {
            toConnected();
            Future.delayed(Duration(seconds: 1), () => toProgress());
          } else if (chargingStatus.value == 'progress') {
            time.value = getTimeDifference(
              // startTime: '2024-01-17 20:52:17',
              startTime: activeSessionModel.startTime,
              endtime: DateTime.now().toIso8601String(),
            );
            NotificationService().createLocalNotification(
              100,
              status_model.value.percentage,
              1,
            );
          }
        }
        break;
      case 'Completed':
        {
          toFinished();
          NotificationService().cancelLocalNotification(1);
        }
        break;
      case 'Disconnected':
        {
          toDisconnected();
          NotificationService().cancelLocalNotification(1);
        }
        break;
      case '':
        {
          toReconnect();
        }
        break;
      default:
        {
          toFinished();
          SocketRepo().closeSocket();
          NotificationService().cancelLocalNotification(1);
        }
        //pop the dialog if status not I and dialog is opened.
        if (Get.currentRoute == Routes.chargingPageRoute &&
            Get.isDialogOpen == true &&
            status_model.value.status != 'Initiated' &&
            (chargingStatus.value == 'connected' ||
                chargingStatus.value == 'disconnected')) {
          Get.back();
        }
        if (Get.currentRoute == Routes.chargingPageRoute &&
            Get.isDialogOpen == true &&
            chargingStatus.value == 'finishing') {
          Get.back();
        }
    }
  }

  onClickFinished() {
    Get.offNamed(Routes.shareExperiencePageRoute,
        arguments: [activeSessionModel.chargingStationId, status_model.value]);
  }

  downloadInvoice() async => await CommonFunctions().downloadBookingInvoice(
        int.parse(activeSessionModel.transactionId),
      );

  toConnected() => chargingStatus.value = "connected";
  toFinished() => chargingStatus.value = "finished";
  toCompleted() => chargingStatus.value = "completed";
  toDisconnected() => chargingStatus.value = "disconnected";
  toProgress() => chargingStatus.value = "progress";
  toReconnect() => chargingStatus.value = "";
  toInitiating() => chargingStatus.value = "initiating";
}




// class ChargingScreenController extends GetxController {
//   // connected finished completed disconnected progress
//   Timer? _timer;
//   RxList<int> time = [0, 0].obs;
//   RxString chargingStatus = "".obs;
//   bool showLowBalanceOnlyOnce = true;
//   ActiveSessionModel activeSessionModel = kActiveSessionModel;
//   Rx<ChargingStatusModel> status_model = kChargingStatusModel.obs;
//   // String chargerName = '';
//   // String chargingPoint = '';
//   // String qr_or_app_data = '';
//   // Rx<BookingModel> booking_model = kBookingModel.obs;
//   // ChargingStatusModel rest_api_status_model = kChargingStatusModel;

//   onInit() {
//     super.onInit();
//     getArguments();
//     getChargingStatus();
//     // qr_or_app_data =
//     //     Get.arguments != null ? Get.arguments[0] ?? '253-z1-1-Q' : '444-t1-1-Q';
//     // booking_model.value = Get.arguments != null
//     //     ? Get.arguments[1] ?? appData.tempBookingModel
//     //     : appData.tempBookingModel;
//     // List<String> seperator = qr_or_app_data.split('-');
//     // chargerName = seperator[1];
//     // chargingPoint = seperator[2];

//     // if (booking_model.value.status == 'R' ||
//     //     booking_model.value.status == 'U') {
//     //   getChargingStatus(booking_model.value.bookingId.toString());
//     // } else {
//     //   changeStatus(isStart: true, bookingId: booking_model.value.bookingId);
//     // }
//   }

//   getArguments() {
//     activeSessionModel =
//         Get.arguments != null ? Get.arguments : kActiveSessionModel;
//   }

//   onClose() {
//     super.onClose();
//     _timer?.cancel();
//   }

//   Future stopCharging() async {
//     // showLoading(kLoading);
//     bool res = await CommonFunctions().stopCharging(
//       connectorId: activeSessionModel.connectorId,
//       cpid: activeSessionModel.cpid,
//       transactionId: activeSessionModel.transactionId,
//     );
//     // hideLoading();
//     if (res) {
//       toDisconnected();
//     }
//   }

//   ///ChargingStatus
//   Future getChargingStatus() async {
//     // _timer = Timer.periodic(Duration(seconds: 7), (timer) async {

//     ActiveSessionModel res = await CommonFunctions().getActiveSession();
//     logger.i('transactionId ${res.transactionId}');
//     if (res.transactionId != '-1') {
//       activeSessionModel = res;
//       status_model.value.status = 'Charging';
//     } else {
//       status_model.value.status = 'Initiated';
//     }
//     res = kActiveSessionModel;

//     _repeatCall();

//     // Define a timer that stops the loop after 3 minutes
//     Timer(Duration(minutes: 3), () {
//       if (activeSessionModel.transactionId == '-1') {
//         activeSessionModel = ActiveSessionModel(
//           startTime: '',
//           transactionId: '-2',
//           chargerName: '',
//           connectorType: '',
//           outputType: '',
//           tariff: 0,
//           unitUsed: 0,
//           capacity: 0,
//           connectorId: '',
//           cpid: '',
//           chargingStationId: '',
//           currentSoc: 0,
//         );
//       }
//     });

//     //? Try untill the transaction table updated by charger.
//     while (activeSessionModel.transactionId == '-1') {
//       res = await CommonFunctions().getActiveSession();
//       if (res.transactionId != '-1') {
//         activeSessionModel = res;
//         status_model.value.status = 'Charging';
//       }
//       res = kActiveSessionModel;
//       await Future.delayed(Duration(seconds: 10));
//     }
//     //? ///////////////////
//     showLowBalanceOnlyOnce = true;

//     status_model.value.capacity = activeSessionModel.capacity;
//     status_model.value.outputType = activeSessionModel.outputType;
//     status_model.value.connectorType = activeSessionModel.connectorType;
//     status_model.value.amount =
//         (activeSessionModel.tariff) * activeSessionModel.unitUsed;
//     status_model.value.unitUsed = activeSessionModel.unitUsed;
//     status_model.value.percentage = activeSessionModel.currentSoc;
//     time.value = getTimeDifference(
//       startTime: activeSessionModel.startTime,
//       endtime: DateTime.now().toIso8601String(),
//     );

//     // status_model.value.taxamount =
//     //     (booking_model.value.taxes) * status_model.value.unit;

//     /// Timer? _timer;
//     // String time = '';

//     /////INIT WEBSOCKET FROM HERE

//     await SocketRepo().closeSocket();
//     if (activeSessionModel.transactionId != '-1' &&
//         activeSessionModel.transactionId != '-2') {
//       SocketRepo().initSocket(
//           tranId: activeSessionModel.transactionId,
//           fun: (message) async {
//             // _timer?.cancel();
//             if (message != null && message['status'] == 'Completed') {
//               status_model.value.status = 'Completed';
//             } else if (message != null &&
//                 (message['type'] == 'transactionStop' ||
//                     message['type'] == 'Transaction Stopped')) {
//               status_model.value.status = 'Disconnected';
//               await SocketRepo().closeSocket();
//             } else if (message != null) {
//               status_model.value = ChargingStatusModel.fromJson(message);
//             }

//             appData.userModel.value.balanceAmount = status_model.value.balance;
//             status_model.value.capacity = activeSessionModel.capacity;
//             status_model.value.outputType = activeSessionModel.outputType;
//             status_model.value.connectorType = activeSessionModel.connectorType;
//             status_model.value.amount =
//                 (activeSessionModel.tariff) * status_model.value.unitUsed;
//             // status_model.value.taxamount =
//             //     (booking_model.value.taxes) * status_model.value.unit;

//             _repeatCall();
// // This timer is for if there is no update within the interval then close the session by checking /bookingStatus api
//             /// if (status_model.value.status == 'R' ||
//             ///     status_model.value.status == 'I' ||
//             ///     status_model.value.status == 'U')
//             ///   _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
//             ///     kLog('getting status from loop');
//             ///     var res = await CommonFunctions()
//             ///         .getChargingStatus(bookingId.toString());
//             ///     if (res.connector != -1) status_model.value = res;
//             ///     _repeatCall();
//             ///     if (status_model.value.status != 'R' &&
//             ///         status_model.value.status != 'I') _timer?.cancel();
//             ///   });
//             // / time = status_model.value.lastupdated;
//           });
//       // });
//     }
//   }

//   _repeatCall() {
//     switch (status_model.value.status) {
//       case 'Initiated':
//         {
//           if (Get.isDialogOpen == false)
//             Dialogs().gunStatusAlert(
//               'Plug in the Connector',
//               'Please make sure the connector is plugged-in',
//             );
//           toInitiating();
//         }
//         break;
//       case 'Charging':
//         {
//           if (chargingStatus.value != 'progress' &&
//               chargingStatus.value != 'finishing') {
//             toConnected();
//             Future.delayed(Duration(seconds: 1), () => toProgress());
//           } else if (chargingStatus.value == 'progress') {
//             time.value = getTimeDifference(
//               // startTime: '2024-01-17 20:52:17',
//               startTime: activeSessionModel.startTime,
//               endtime: DateTime.now().toIso8601String(),
//             );
//             NotificationService().createLocalNotification(
//               100,
//               status_model.value.percentage,
//               1,
//             );
//           }
//         }
//         break;
//       case 'Completed':
//         {
//           toFinished();
//           _timer?.cancel();
//           NotificationService().cancelLocalNotification(1);
//         }
//         break;
//       case 'Disconnected':
//         {
//           toDisconnected();
//           _timer?.cancel();
//           NotificationService().cancelLocalNotification(1);
//         }
//         break;
//       case '':
//         {
//           toReconnect();
//         }
//         break;
//       default:
//         {
//           toFinished();
//           SocketRepo().closeSocket();
//           NotificationService().cancelLocalNotification(1);
//         }
//         //pop the dialog if status not I and dialog is opened.
//         if (Get.currentRoute == Routes.chargingPageRoute &&
//             Get.isDialogOpen == true &&
//             status_model.value.status != 'Initiated' &&
//             (chargingStatus.value == 'connected' ||
//                 chargingStatus.value == 'disconnected')) {
//           Get.back();
//         }
//         if (Get.currentRoute == Routes.chargingPageRoute &&
//             Get.isDialogOpen == true &&
//             chargingStatus.value == 'finishing') {
//           Get.back();
//         }
//     }
//   }

//   // _repeatCall() async {
//   //   logger.i('status ${status_model.value.status}');
//   //   logger.i('chargingStatus ${chargingStatus.value}');
//   //   //Normal status check starts from here
//   //   if (status_model.value.status == 'Initiated') {
//   //     if (Get.isDialogOpen == false)
//   //       Dialogs().gunStatusAlert('Plug in the Connector',
//   //           'Please make sure the connector is plugged-in');
//   //     toInitiating();
//   //   } else if (status_model.value.status == 'Charging') {
//   //     //IF CHARGING STARTED
//   //     if (chargingStatus.value != 'progress' &&
//   //         chargingStatus.value != 'finishing') {
//   //       toConnected();
//   //       Future.delayed(Duration(seconds: 1), () => toProgress());
//   //     } else if (chargingStatus.value == 'progress') {
//   //       time.value = getTimeDifference(

//   //           /// startTime: booking_model.value.start_time,
//   //           startTime: activeSessionModel.startTime,
//   //           // startTime: '2024-01-17 20:52:17',
//   //           endtime: DateTime.now().toIso8601String());
//   //       NotificationService()
//   //           .createLocalNotification(100, status_model.value.percentage, 1);
//   //     }
//   //   } else if (status_model.value.status == 'Completed') {
//   //     toFinished();
//   //     _timer?.cancel();
//   //     NotificationService().cancelLocalNotification(1);
//   //   } else if (status_model.value.status == 'Disconnected') {
//   //     toDisconnected();
//   //     _timer?.cancel();
//   //     NotificationService().cancelLocalNotification(1);
//   //   } else if (status_model.value.status.isEmpty ||
//   //       status_model.value.status == 'U') {
//   //     toReconnect();
//   //   } else {
//   //     toFinished();
//   //     SocketRepo().closeSocket();
//   //     NotificationService().cancelLocalNotification(1);
//   //   }

//   //   //pop the dialog if status not I and dialog is opened.
//   //   if (Get.currentRoute == Routes.chargingPageRoute &&
//   //       Get.isDialogOpen == true &&
//   //       status_model.value.status != 'I' &&
//   //       (chargingStatus.value == 'connected' ||
//   //           chargingStatus.value == 'disconnected')) {
//   //     kLog('kill from init');
//   //     Get.back();
//   //   }
//   //   if (Get.currentRoute == Routes.chargingPageRoute &&
//   //       Get.isDialogOpen == true &&
//   //       chargingStatus.value == 'finishing' &&
//   //       status_model.value.status != 'R') {
//   //     kLog('kill from finish');
//   //     Get.back();
//   //   }
//   //HACK
//   // if (status_model.value. == -1 &&
//   //     Get.isDialogOpen != true &&
//   //     showLowBalanceOnlyOnce &&
//   //     status_model.value.status == 'R' &&
//   //     status_model.value.balance < appData.gettingLowAllertValue) {
//   //   showLowBalanceOnlyOnce = false;
//   //   Dialogs().notEnoughCreditPopUp(balance: status_model.value.balance);
//   // }
//   // }

//   onClickFinished() {
//     Get.toNamed(Routes.shareExperiencePageRoute,
//         arguments: [activeSessionModel.chargingStationId, status_model.value]);
//   }

//   downloadInvoice() async {
//     await CommonFunctions()
//         .downloadBookingInvoice(int.parse(activeSessionModel.transactionId));
//   }

//   toConnected() {
//     chargingStatus.value = "connected";
//   }

//   toFinished() {
//     chargingStatus.value = "finished";
//   }

//   toCompleted() {
//     chargingStatus.value = "completed";
//   }

//   toDisconnected() {
//     chargingStatus.value = "disconnected";
//   }

//   toProgress() {
//     chargingStatus.value = "progress";
//   }

//   toReconnect() {
//     chargingStatus.value = "";
//   }

//   toInitiating() {
//     chargingStatus.value = "initiating";
//   }

//   // Future changeStatus({required bool isStart, required int bookingId}) async {
//   //   // showLoading(kLoading);
//   //   bool res = await CommonFunctions().changeChargingStatus(
//   //       isStart: isStart,
//   //       bookingId: bookingId.toString(),
//   //       chargerName: chargerName,
//   //       chargingPoint: chargingPoint);
//   //   // hideLoading();
//   //   if (res && isStart) {
//   //     getChargingStatus(bookingId.toString());
//   //   } else if (res) {
//   //     // toDisconnected();
//   //   } else if (isStart) toDisconnected();
//   // }
// }
