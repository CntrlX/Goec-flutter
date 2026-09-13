import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'Model/activeSessionModel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freelancer_app/Model/userModel.dart';
import 'package:freelancer_app/Model/orderModel.dart';
import 'package:freelancer_app/Model/reviewMode.dart';
import 'package:freelancer_app/Model/bookingModel.dart';
import 'package:freelancer_app/Model/vehicleModel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/Model/stationMarkerModel.dart';
import 'package:freelancer_app/Model/chargingStatusModel.dart';
import 'package:freelancer_app/Model/chargeStationDetailsModel.dart';

import 'Singletones/app_data.dart';

late Size size = Size(0, 0);
double zoom = 15;

const String kFontFamily = 'Nunito Sans';

final Color kblack = Colors.black;
final Color kwhite = Colors.white;
final Color kamber = Colors.amber;
final Color kred = Colors.red;
final Color kgrey = Colors.grey;
final Color kblue = Colors.blue;
final Color ktransparent = Colors.transparent;
final Color kOnboardingColors = Color(0xff0047C3);
final Color ktextFieldColor = Color(0xffEEEEEE);
final Color kscaffoldBackgroundColor = Color(0xFFF5F5F5);
final Color kscaffoldBackgroundColor2 = Color(0xfff0f1f6);
final Color kDefaultHomePageBackgroundColor = Color(0xffF0F1F6);
final Color kBusyColor = Color(0xffF9E4D5);
final Color kBusyBorderColor = Color(0xffE37A2D);

// Brand & Design System Colors
final Color kBrandPrimaryBlue = const Color(0xFF0049C2);
final Color kBrandPrimaryMint = const Color(0xFF03E8BE);
final Color kNeutralPrimary = const Color(0xFF121D31);
final Color kNeutralSecondary = const Color(0xFF68768E);
final Color kNeutralMuted = const Color(0xFFA0AABD);
final Color kInactiveDotColor = const Color(0xFFDBEAFE);

// Linear gradient (Figma: 133deg, rgba(0,73,194,1) 4% -> rgba(2,232,189,1) 100%)
final LinearGradient kOnboardingGradient = const LinearGradient(
  begin: Alignment(-0.68, -0.73),
  end: Alignment(0.68, 0.73),
  colors: [Color(0xFF0049C2), Color(0xFF02E8BD)],
  stops: [0.04, 1.0],
);

//appStrings
final String kAppName = 'GO EC Merchantile';
final String kLoading = 'Loading...';
//login-screen
final String kLoginSkipButton = 'skip';
final String kLoginJoinGoec = 'Join GO EC and make';
final String kLoginRevolutions = 'Revolutions';

final String kLoginButtonGoogle = 'Google';
final String kLoginButtonFacebook = 'Facebook';
final String kLoginButtonPhone = 'Login with Phone';
final String kLoginTermsAndPrivay = 'Login with Phone';
final String kAll = 'All';
final String kAvailable = 'Available';
final String kPreparing = 'Preparing';
final String kUnavailable = 'Unavailable';
final String kFaulted = 'Faulted';
final String kFinishing = 'Finishing';
final String kCharging = 'Charging';
final String kBusy = 'Busy';
// final String kCurrency = '₹';
final String kCurrency =
    appData.userModel.value.username.contains('+977') ? 'रु' : '₹';

bool get isNepal => appData.userModel.value.username.contains('+977');

late BuildContext kContext;

final String kcProfileImage =
    'https://img.freepik.com/premium-vector/man-avatar-profile-picture-vector-illustration_268834-538.jpg';

final String kaChargingHistory = 'assets/images/chargingHistory.png';
final String kaGisRoute = 'assets/images/gis_route.png';
final String kaWalletBlue = 'assets/images/wallet1.png';
final String kaDirection = 'assets/images/direction.png';
final String kaLocation = 'assets/images/location.png';
final Position kPosition = Position(
    // Default fallback: Nepal (approx. geographic center)
    longitude: 84.1240,
    latitude: 28.3949,
    timestamp: DateTime.now(),
    altitudeAccuracy: 0,
    headingAccuracy: 0,
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0);

final VehicleModel kVehicleModel = VehicleModel(
    id: '-1',
    icon:
        'https://sternbergclinic.com.au/wp-content/uploads/2020/03/placeholder.png',
    brand: '',
    defaultVehicle: false,
    evRegNumber: '',
    modelName: '',
    // outputType: '',
    // typeOfPorts: '',
    // year: '',
    // ratedVoltages: 0,
    // capacity: 0,
    // numberOfPorts: 0,
    compactable_port: []);
final UserModel kUserModel = UserModel(
    id: '-1',
    username: '',
    userId: '',
    // phone: '',
    email: '',
    image: '',
    // status: '',
    name: '',
    total_sessions: 0,
    total_units: 0,
    rfidTag: [],
    defaultVehicle: kVehicleModel,
    balanceAmount: 0);
final ChargeStationDetailsModel kChargeStationDetailsModel =
    ChargeStationDetailsModel(
        id: '-1',
        name: '',
        address: '',
        rating: 0,
        image:
            'https://sternbergclinic.com.au/wp-content/uploads/2020/03/placeholder.png',
        latitude: -1,
        longitude: -1,
        amenities: [],
        startTime: '',
        stopTime: '',
        isFavorite: false,
        chargers: []);
final StationMarkerModel kStationMarkerModel = StationMarkerModel(
    id: '-1',
    latitude: -1,
    longitude: -1,
    amenities: [],
    charger_status: '',
    ac_dc: '',
    startTime: '',
    stopTime: '',
    charger_type: [],
    charger_capacity: '',
    image:
        'https://sternbergclinic.com.au/wp-content/uploads/2020/03/placeholder.png',
    name: '',
    rating: 0,
    address: '');

final BookingModel kBookingModel = BookingModel(
  bookingId: -1,
  // chargingpoint: -1,
  chargerName: '',
  // userEVId: -1,
  // username: '',
  // amount: 0,
  unitConsumed: 0,
  // stopReason: '',
  // userstartattempts: 0,
  // userstopattempts: 0,
  // maxattempts: 0,
  // pricing: 0,
  damount: 0,
  tdamount: 0,
  // extracharges: 0,
  taxes: 0,
  // bookedvia: '',
  // user_can_Request: '',
  // priceby: '',
  book_time: '',
  start_time: '',
  stop_time: '',
  // requested_stop_time: '',
  // requested_stop_duration: '',
  // requested_stop_unit: 0,
  // requested_stop_soc: '',
  // stopchargingby: '',
  // discountcode: '',
  status: '',
  // scheduleId: '',
  // capacity: 0,
  // connectorType: '',
  // outputType: '',
  tariff: 0,
);

final ChargingStatusModel kChargingStatusModel = ChargingStatusModel(
    // tran_id: -1,
    // connector: -1,
    amount: 0,
    percentage: 0,
    // Duration: 0,
    // PriceBy: '',
    unitUsed: 0,
    // load: 0,
    // price: 0,
    // startTime: '',
    // lastupdated: '',
    // Charger: '',
    status: '',
    // tariff: 0,
    // Chargingstatus: '',
    capacity: 0,
    outputType: '',
    connectorType: '',
    // taxamount: 0,
    balance: 0);

final ActiveSessionModel kActiveSessionModel = ActiveSessionModel(
  startTime: '',
  transactionId: '-1',
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

final ReviewModel kReviewModel = ReviewModel(
    // stationId: -1,
    // name: '',
    image:
        'https://img.freepik.com/premium-vector/man-avatar-profile-picture-vector-illustration_268834-538.jpg',
    rating: 0,
    review: '',
    userName: '',
    createdAt: '');

final OrderModel kOrderModel = OrderModel(
  transactionId: '-1',
  type: '',
  pgOrderId: '',
  // pgPaymentId: '',
  // bookingId: -1,
  // appuserName: '',
  amount: 0,
  // pgSIgnature: '',
  status: '',
  // pgOrderGenTime: '',
  createdAt: '',
  // lastUpdateTime: '',
  // paymentMode: '',
  // pgLog: '',
  // statusUpdateBy: '',
  // rfidAmountPaid: ''
);

//app-Textstyles

final TextStyle kAppSkipButtonTextStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: kwhite,
);

final TextStyle kAppJoinGOECTextStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 20.sp,
  fontWeight: FontWeight.w500,
  color: kwhite,
);
final TextStyle kAppSignupStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 20.sp,
  fontWeight: FontWeight.w600,
  color: kblack,
);

final TextStyle kAppRevolutionsTextStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 59.sp,
  fontWeight: FontWeight.w600,
  color: Color(0xff00FFB3),
);

final TextStyle kAppBottomTextSpanTextStyle1 = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 13.sp,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

final TextStyle kAppBottomTextSpanTextStyle2 = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 13.sp,
  fontWeight: FontWeight.w400,
  color: kOnboardingColors,
  decoration: TextDecoration.underline,
);

final TextStyle kAppBigTextStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 20.sp,
  fontWeight: FontWeight.w600,
  color: Color(0xff828282),
);

final TextStyle kAppSuperBigTextStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 30.sp,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

final TextStyle kAppSmallTextStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: Color(0xff828282),
);
final TextStyle kAppSuperSmallTextStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 10,
  fontWeight: FontWeight.w400,
  color: Color(0xff828282),
);

final TextStyle kApphintTextStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0xffBDBDBD),
);
final TextStyle kApphintTextStyle2 = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Color.fromARGB(251, 105, 105, 105),
);

// Onboarding Revamp Text Styles (Figma)
// style_33a990a6: Nunito Sans Bold 32px, Line Height 40px (1.25)
final TextStyle kOnboardingHeadingStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 32.sp,
  fontWeight: FontWeight.w700,
  height: 40 / 32,
  color: kNeutralPrimary,
);

// ts4: Nunito Sans Bold Italic 32px, Line Height 40px (1.25)
final TextStyle kOnboardingHighlightStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 32.sp,
  fontWeight: FontWeight.w700,
  fontStyle: FontStyle.italic,
  height: 40 / 32,
  color: Colors.white,
);

// style_82b3aa69: Nunito Sans Regular 16px, Line Height 24.38px (1.52)
final TextStyle kOnboardingSubtitleStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 16.sp,
  fontWeight: FontWeight.w400,
  height: 24.38 / 16,
  color: kNeutralSecondary,
);

// EL-f1f194d6: Nunito Sans Bold 16px, Line Height 24px (1.5), Letter Spacing 0.025em (0.4px)
final TextStyle kOnboardingButtonTextStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 16.sp,
  fontWeight: FontWeight.w700,
  height: 24 / 16,
  letterSpacing: 0.4,
  color: Colors.white,
);

// style_082fc0f0: Nunito Sans Medium 12px, Line Height 14.38px (1.2)
final TextStyle kOnboardingTermsMutedStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 12.sp,
  fontWeight: FontWeight.w500,
  height: 14.38 / 12,
  color: kNeutralMuted,
);

// style_67ac4a96: Nunito Sans Medium 12px, Line Height 14.38px (1.2)
final TextStyle kOnboardingTermsLinkStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 12.sp,
  fontWeight: FontWeight.w500,
  height: 14.38 / 12,
  color: kBrandPrimaryBlue,
);

Logger logger = Logger();
kLog(Object value) {
  // logger.d(value);
  logger.t(value.toString());
  // logger.t("Trace log");

  // logger.d("Debug log");

  // logger.i("Info log");

  // logger.w("Warning log");

  // logger.e("Error log", error: 'Test Error');

  // logger.f("What a fatal log");
}

class Const {
  //time slot page

  static Color titleColor = const Color(0xff4B4B4B);
  static Color subTitleColor = const Color(0xff494949);
  static Color hashTagTextColor = const Color(0xffF1673B);
  static Color cardBorderColor = const Color(0xffC7C7C7);
  static Color cardBorderActiveColor = const Color(0xff579A35);

  static Color availableTextColor = const Color(0xff7AC368);
  static Color notAvailableTextColor = Color.fromARGB(255, 205, 57, 43);
  static Color activeCardBgColor = const Color(0xffF1FFEA);

  static Color activeCardTimeColor = const Color(0xff579A35);
  static Color inactiveDateTextColor = const Color(0xff828282);
  static Color inactiveDateBgtColor = Color(0xFFE2E2E2);

  static Color activeDateTextColor = const Color(0xffFF8C68);
  static Color activeDateBgtColor = const Color(0xffFF8C68).withOpacity(0.15);
}
