import 'dart:io';
import 'utils.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'api_constants.dart';
import '../Singletones/app_data.dart';
import 'package:http/http.dart' as http;
import '../Model/apiResponseModel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:freelancer_app/constants.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';

class CallAPI {
  //make it singleTone class
  static final CallAPI _singleton = CallAPI._internal();
  factory CallAPI() {
    return _singleton;
  }
  CallAPI._internal();

  int timeOutSec = 15;

/////////POST DATA/////////////////
  Future<ResponseModel> postData(Map<String, dynamic> data, String url) async {
    try {
      kLog('POST $url');
      http.Response res = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${appData.token}',
        },
      ).timeout(Duration(seconds: timeOutSec), onTimeout: () {
        return http.Response('Error', 408);
      });
      log('post request end');
      var body;
      if (res.statusCode == 200 || res.statusCode == 201)
        body = json.decode(res.body);
      else
        logger.e(res.statusCode);
      return ResponseModel(statusCode: res.statusCode, body: body);
    } on Exception catch (e) {
      logger.e(e.toString());
      hideLoading();
    }
    return ResponseModel(statusCode: 404, body: null);
  }

/////////GET DATA/////////////////
  Future<ResponseModel> getData(String url) async {
    var body;
    log('GET + $url');
    try {
      http.Response res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${appData.token}',
        },
      ).timeout(Duration(seconds: timeOutSec), onTimeout: () {
        return http.Response('Error', 408);
      });
      if (res.statusCode == 200) {
        body = json.decode(res.body);
      } else
        logger.e(res.statusCode);

      return ResponseModel(statusCode: res.statusCode, body: body);
    } on Exception catch (e) {
      logger.e(e.toString());
      hideLoading();
      showError('Failed to get data');
    }

    return ResponseModel(statusCode: 404, body: null);
  }

/////////PUT DATA/////////////////
  Future<ResponseModel> putData(Map<String, dynamic> data, String url) async {
    try {
      log('PUT $url');
      http.Response res = await http.put(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${appData.token}',
        },
      ).timeout(Duration(seconds: timeOutSec), onTimeout: () {
        return http.Response('Error', 408);
      });
      log('PUT request end');
      var body;
      kLog(res.statusCode.toString());
      kLog(res.body.toString());
      if (res.statusCode == 200)
        body = json.decode(res.body);
      else
        logger.e(res.statusCode);
      return ResponseModel(statusCode: res.statusCode, body: body);
    } on Exception catch (e) {
      logger.e(e.toString());
      hideLoading();
      showError('Failed to put data');
      // TOD
    }
    return ResponseModel(statusCode: 404, body: null);
  }

///////DELETE API///////////////
  Future<ResponseModel> deleteData(
      Map<String, dynamic> data, String url) async {
    try {
      log('DELETE $url');
      http.Response res = await http.delete(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${appData.token}',
        },
      ).timeout(Duration(seconds: timeOutSec), onTimeout: () {
        return http.Response('Error', 408);
      });
      log('delete request end');
      var body;
      if (res.statusCode == 200) {
        body = json.decode(res.body);
      } else
        logger.e(res.statusCode);

      return ResponseModel(statusCode: res.statusCode, body: body);
    } on Exception catch (e) {
      logger.e(e.toString());
      hideLoading();
      showError('Failed to delete!');
      // /
    }
    return ResponseModel(statusCode: 404, body: null);
  }

/////////DOWNLOAD PDF/////////////////
  Future<void> downloadPdf(int transactionId) async {
    bool status = await getStoragePermission();
    if (!status) {
      showError('Storage permission Denied');
      return;
    }
    showLoading('Downloading...');
    var res = await getData(
      kApi_ocpp_url + 'invoice/' + '$transactionId',
    );
    if (res.statusCode == 200) {
      String base64String = res.body['result'];
      RegExp base64RegEx = RegExp('[^a-zA-Z0-9+/=]');
      String sanitizedString = base64String.replaceAll(base64RegEx, '');
      Uint8List bytes = base64Decode(sanitizedString);
      // Uint8List bytes = base64Decode(res.body['result']);
      hideLoading();
      final file = File(
          '${(await getDownloadFolderpath())}/booking_invoice_$transactionId.pdf');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      showSuccess('Downloaded successfully');
      OpenFilex.open(file.path);
    } else {
      showError('Unable to download!');
      return;
    }
  }

  /////IMAGE UPLOAD//////
  Future<String> uploadFile(File file) async {
    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST",
        Uri.parse("https://oxium.goecworld.com:5100/api/v1/image/upload"));

    //create multipart using filepath, string or bytes
    var pic = await http.MultipartFile.fromPath('image', file.path);
    //add multipart to request
    request.files.add(pic);
    request.headers.addAll({
      'Authorization': 'Bearer ${appData.token}',
    });
    var response = await request.send();
    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var res = jsonDecode(responseString);
    if (response.statusCode == 200 && res['status']) {
      return res['url'];
    } else {
      return '';
    }
  }
}
