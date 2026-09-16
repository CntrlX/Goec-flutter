import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:freelancer_app/Model/evPortsModel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:validators/validators.dart';

import '../Singletones/app_data.dart';
import '../constants.dart';
import 'SharedPreferenceUtils.dart';
import 'app_datetime.dart';

/// Charger-type icon path used by [filter_screen] (`assets/svg/${title.toLowerCase()}.svg`).
/// Maps common API variants (CCS, Type2, CHAdeMO, …) onto those same assets.
String connectorTypeSvgAsset(String connectorType) {
  final raw = connectorType.trim();
  if (raw.isEmpty) return 'assets/svg/connector_plug.svg';

  final t = raw.toLowerCase().replaceAll(RegExp(r'[\s_\-/]+'), ' ').trim();

  if (t.contains('chademo') || t.contains('cha demo')) {
    return 'assets/svg/chademo.svg';
  }
  if (t.contains('gbt') || t.contains('gb t') || t.contains('gb/t')) {
    return 'assets/svg/gbt.svg';
  }
  if (t.contains('iec') || t.contains('60309')) {
    return 'assets/svg/iec_60309.svg';
  }
  if (t == 'type 2' || t == 'type2' || t.contains('type 2')) {
    return 'assets/svg/type 2.svg';
  }
  if (t == 'type 1' || t == 'type1' || t.contains('type 1')) {
    return 'assets/svg/type 1.svg';
  }
  if (t.contains('combol')) {
    return 'assets/svg/combol.svg';
  }
  // Filter label is "CSS"; APIs often send CCS / Combo.
  if (t.contains('ccs') || t.contains('css') || t.contains('combo')) {
    return 'assets/svg/css.svg';
  }

  // Exact filter titles: CSS, GBT, Type 2, IEC_60309, CHAdemO, Combol, Type 1
  final filterKey = raw.toLowerCase();
  const known = {
    'css',
    'gbt',
    'type 2',
    'iec_60309',
    'chademo',
    'combol',
    'type 1',
  };
  if (known.contains(filterKey)) {
    return 'assets/svg/$filterKey.svg';
  }

  return 'assets/svg/connector_plug.svg';
}

String? validateText(String value) {
  if (value.isEmpty) {
    return "Required field";
  }
  return null;
}

String? validatePassword(String value) {
  if (!(value.length > 5)) {
    return "Password should contain 6 characters";
  }
  return null;
}

String? validateEmail(String value) {
  if (!isEmail(value)) {
    return "Email address not valid";
  }
  return null;
}

String? validateNumber(String value) {
  if (!isNumeric(value) && value.length != 11) {
    return 'Phone number must be 11 digits with no country code';
  }
  return null;
}

Future<String> getToken() async {
  return appData.token = await getString('token') ?? '';
}

extension TitleCase on String {
  String toTitleCase() {
    if (this == '') {
      return '';
    }

    final List<String> words = this.trim().split(' ');
    final List<String> capitalizedWords = words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .toList();

    return capitalizedWords.join(' ');
  }
}

Future<Map<String, dynamic>> loadJsonFromAsset(String path) async {
  String jsonString = await rootBundle.loadString(path);
  return json.decode(jsonString);
}

List<dynamic> calculateAvailabiliy(
    List<EvPortModel> evPorts, bool isConnected) {
  int available = 0,
      busy = 0,
      // unAvailable = 0,
      faulty = 0,
      total = evPorts.length;
  String trailing = '';
  evPorts.forEach((element) {
    // kLog(element.ocppStatus);
    if (element.ocppStatus == kAvailable || element.ocppStatus.isEmpty)
      available++;
    else if (element.ocppStatus == 'Charging')
      busy++;
    else if (element.ocppStatus == kFaulted) faulty++;
    // else
    // unAvailable++;
  });
  if (available > 0)
    trailing = '$kAvailable $available/$total';
  else if (busy > 0)
    trailing = kBusy;
  else if (faulty > 0)
    trailing = kFaulted;
  else
    trailing = kUnavailable;

  //if charger is disconnected then show unavailable
  if (!isConnected) {
    trailing = kUnavailable;
    available = 0;
  }
  return [trailing, available];
}

String getTimeFromTimeStamp(String timestamp, String format) {
  if (timestamp.isEmpty) return '00:00 AM';
  return AppDateTime.format(
    timestamp,
    pattern: format,
    fallback: '00:00 AM',
    useRawIfUnparsed: true,
  );
}

String convertToPmFormat(String time) {
  if (time.isEmpty) return '00:00 AM';
  DateTime dateTime = DateTime.parse('2000-01-01 $time');
  String formattedTime = DateFormat('h:mm a').format(dateTime);
  return formattedTime;
}

bool isTimeInRange(String startTime, String endTime) {
  if (startTime.isEmpty || endTime.isEmpty) return false;

  DateFormat dateFormat = DateFormat.Hm();
  DateTime now = dateFormat.parse(dateFormat.format(DateTime.now()));

  DateTime start = dateFormat.parse(startTime);
  DateTime end = dateFormat.parse(endTime);

  if (start.isAfter(end)) {
    // Handle case where start time is after end time (e.g., spanning midnight)
    end = end.add(Duration(days: 1));
  }
  // logger.i('now ${dateFormat.parse(dateFormat.format(DateTime.now()))}');
  // logger.i('start $start');
  // logger.i("end $end");
  if (now.isAfter(start) && now.isBefore(end)) {
    return true;
  } else {
    return false;
  }
}

Future<String> getDownloadFolderpath() async {
  var directory;
  String path = '';
  if (Platform.isAndroid) {
    // directory = await getExternalStorageDirectory();
    kLog((await getExternalStorageDirectory()).toString());
    directory = Directory('/storage/emulated/0');
    path = '${directory.path}/Download';
  } else if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
    // directory = await getDownloadsDirectory();
    path = '${directory.path}';
  }
  kLog(path);
  return path;
}

getTimeDifference({required String startTime, required String endtime}) {
  if (startTime.isEmpty) return [0, 0];
  final start = AppDateTime.parse(startTime);
  final end = endtime.isNotEmpty
      ? AppDateTime.parse(endtime)
      : DateTime.now().toLocal();
  if (start == null || end == null) return [0, 0];

  final difference = end.difference(start).inMilliseconds;
  if (difference < 0) return [0, 0];
  final hours = (difference / (1000 * 60 * 60)).floor();
  final minutes = ((difference / (1000 * 60)) % 60).floor();
  return [hours, minutes];
}

String dateFromTimeStamp(String input) {
  final parsed = AppDateTime.parse(input);
  return parsed?.toString() ?? input;
}

List<int> getTimeDifferenceforHistory(
    {required String startTime, required String endTime}) {
  return AppDateTime.differenceHoursMinutes(startTime, endTime);
}

/// Prefer [AppDateTime.parse]. Kept for older call sites.
DateTime parseDateTime(String input) {
  return AppDateTime.parse(input) ?? DateTime.now().toLocal();
}

String extractPhoneNumber(String phoneNumber) {
  String result = phoneNumber.replaceAll(new RegExp(r'[^0-9]'), '');
  return "+$result";
}

Future<bool> getStoragePermission() async {
  if (Platform.isAndroid) {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    if (android.version.sdkInt < 33) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else if (await Permission.storage.request().isPermanentlyDenied) {
        await openAppSettings();
        return false;
      } else if (await Permission.audio.request().isDenied) {
        return false;
      }
    } else {
      if (await Permission.photos.request().isGranted) {
        return true;
      } else if (await Permission.photos.request().isPermanentlyDenied) {
        await openAppSettings();
        return false;
      } else if (await Permission.photos.request().isDenied) {
        return false;
      }
    }
  } else if (Platform.isIOS) {
    PermissionStatus res = await Permission.storage.request();
    return res.isGranted;
  }
  return false;
}
