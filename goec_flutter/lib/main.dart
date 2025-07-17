import 'dart:async';
import 'package:get/get.dart';
import 'Utils/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freelancer_app/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freelancer_app/Utils/routes.dart';
import 'package:freelancer_app/Singletones/injector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freelancer_app/Utils/local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ScreenUtilInit(
        designSize: Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: ((context, child) {
          return GetMaterialApp(
            title: 'GOEC',
            debugShowCheckedModeBanner: false,
            builder: EasyLoading.init(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: child!,
              ),
            ),
            // builder: EasyLoading.init(),
            theme: ThemeData(
              textTheme: GoogleFonts.poppinsTextTheme(
                Theme.of(context).textTheme.apply(),
              ),
              fontFamily: 'Poppins',
              primarySwatch: Colors.grey,
              scaffoldBackgroundColor: kscaffoldBackgroundColor,
            ),
            initialRoute: Routes.splashpageRoute,
            getPages: AppPages.pages,
          );
        }));
  }
}
