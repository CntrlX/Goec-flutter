import 'package:flutter/widgets.dart';

// class CustomIcon {
//   CustomIcon._();

//   static const _kFontFam = 'CustomIcon';
//   static const String? _kFontPkg = null;

//   static const IconData map = IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
//   static const IconData bolt = IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
//   static const IconData account_balance_wallet = IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
//   static const IconData mode_of_travel = IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
//   static const IconData support_agent = IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
// }

class CustomIcon {
  CustomIcon._();

  static const _kFontFam = 'CustomIcon';
  static const String? _kFontPkg = null;

  static const List<IconData> icons = [
    IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg),
    IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg),
    IconData(0xe806, fontFamily: _kFontFam, fontPackage: _kFontPkg),
    IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg),
    IconData(0xe805, fontFamily: _kFontFam, fontPackage: _kFontPkg),
  ];

  static const List<String> labels = [
    'Support',
    'Notifications',
    'Stations',
    'History',
    'Wallet',
  ];

  // static const IconData support_agent =
  //     IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  // static const IconData group_9024 =
  //     IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  // static const IconData notifications =
  //     IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  // static const IconData wallet =
  //     IconData(0xe805, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  // static const IconData map =
  //     IconData(0xe806, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}

class NavBarIcon {
  NavBarIcon._();

  static const _kFontFam = 'NavBarIcon';
  static const String? _kFontPkg = null;

  static const List<IconData> icons = [
    IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg),
    IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg),
    IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg),
    IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg),
    IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg),
  ];

  static const List<String> labels = [
    'Support',
    'Notifications',
    'Stations',
    'History',
    'More',
  ];
}
