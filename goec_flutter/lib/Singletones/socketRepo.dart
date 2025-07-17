import 'dart:convert';
import 'package:get/get.dart';
import '../Utils/api_constants.dart';
import '../Utils/routes.dart';
import 'package:freelancer_app/constants.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketRepo {
  //make it singleTone class
  static final SocketRepo _singleton = SocketRepo._internal();
  factory SocketRepo() {
    return _singleton;
  }
  SocketRepo._internal();
  WebSocketChannel? channel;
  RxBool isCharging = false.obs;
  int count = 0;
  initSocket({required String tranId, required Function fun}) {
    final wsUrl = Uri.parse('$kSocketHostUrl/' + tranId);
    channel = WebSocketChannel.connect(wsUrl);
    bool isMessageNull = false;

    if (count < 0) {
      kLog('false return $count');
      return;
    }
    count++;
    channel?.stream.listen((message) {
      logger.e(jsonDecode(message));
      kLog('connected to $wsUrl  and count = $count');
      isMessageNull = message == null ||
          jsonDecode(message)['message'] ==
              "Connected to transaction WebSocket";
      fun(isMessageNull ? null : jsonDecode(message));
      isCharging.value = true;
    }).onDone(() {
      logger.e('connection closed with ocpp');
      if (Get.currentRoute == Routes.chargingPageRoute &&
          Get.isDialogOpen == true) Get.back();
      isCharging.value = false;
      count--;
    });
  }

  closeSocket() async {
    logger.e('called close socket');
    channel?.sink.close(status.goingAway);
  }
}
