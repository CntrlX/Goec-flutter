import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/Singletones/injector.dart';
import 'package:freelancer_app/Utils/app_pages.dart';
import 'package:freelancer_app/Utils/local_notifications.dart';
import 'package:freelancer_app/Utils/routes.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: 'AIzaSyAV3Z723XVgs7ZQEXWHjH67EVZJnkpgVhI',
    appId: '1:494709087984:android:d8c3b159c1fcbc2df9ac35',
    messagingSenderId: '494709087984',
    projectId: 'goecapp-e4890',
    storageBucket: 'goecapp-e4890.appspot.com',
  ));
  await Injector().init();
  await NotificationService().init();
  runApp(const MyApp());
}

/// Picks the highest refresh rate available for the current resolution
/// (Android only; no-op on iOS / LTPO panels that ignore this API).
Future<void> _setMaxRefreshRate() async {
  if (kIsWeb || !Platform.isAndroid) return;
  try {
    await FlutterDisplayMode.setHighRefreshRate();
    // Smoother input when the display runs above 60Hz.
    GestureBinding.instance.resamplingEnabled = true;
  } catch (_) {
    // Devices / OEMs may reject preferred mode; keep default.
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Per flutter_displaymode docs: set preferred mode from root initState
    // (session-scoped; must be re-applied each launch).
    _setMaxRefreshRate();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: ((context, child) {
          return GetMaterialApp(
            title: 'GOECM',
            debugShowCheckedModeBanner: false,
            builder: EasyLoading.init(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: child!,
              ),
            ),
            theme: ThemeData(
              fontFamily: kFontFamily,
              primarySwatch: Colors.grey,
              scaffoldBackgroundColor: kscaffoldBackgroundColor,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
            ),
            initialRoute: Routes.splashpageRoute,
            getPages: AppPages.pages,
          );
        }));
  }
}
