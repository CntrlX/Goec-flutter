import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freelancer_app/constants.dart';

/// White status bar + dark (black) status icons for screens without an AppBar.
const SystemUiOverlayStyle kWhiteStatusBarStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.white,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.dark,
);

/// Wraps a page so the status bar is white with black icons.
class WhiteStatusBar extends StatelessWidget {
  final Widget child;
  const WhiteStatusBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kWhiteStatusBarStyle,
      child: child,
    );
  }
}

/// Preferred size for [CustomAppBar], including status-bar inset.
Size customAppBarPreferredSize(BuildContext context) {
  final contentHeight = MediaQuery.sizeOf(context).height * 0.09;
  return Size.fromHeight(
    MediaQuery.paddingOf(context).top + contentHeight,
  );
}

class LoginCustomAppBar extends StatelessWidget {
  final String? text;
  final Widget? icon;
  const LoginCustomAppBar({super.key, this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              "assets/images/goeclogo.png",
              height: 33,
              width: 68,
            ),
          ],
        ),
        Row(
          children: [
            if (text != null)
              Text(
                text!,
                style: kAppSkipButtonTextStyle,
              ),
            SizedBox(
              width: 10,
            ),
            if (icon != null)
              IconButton(
                onPressed: () {},
                icon: icon!,
              ),
          ],
        )
      ],
    );
  }
}

class OnboardingCustomAppBar extends StatelessWidget {
  final String? text;
  final Widget? icon;
  const OnboardingCustomAppBar({super.key, this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 0.002 * size.height,
          bottom: 0.002 * size.height,
        ),
        color: kOnboardingColors,
        alignment: Alignment.center,
        child: Image.asset(
          "assets/images/goeclogo.png",
          height: size.height * 0.065,
          width: size.width * 0.17,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final Color? color;
  final Widget? logo;
  final Widget? backButton;
  final void Function()? skiponTap;
  final void Function()? icononTap;
  const CustomAppBar({
    super.key,
    this.text,
    this.icon,
    this.color,
    this.skiponTap,
    this.icononTap,
    this.logo,
    this.backButton,
  });

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    final statusTop = MediaQuery.paddingOf(context).top;
    final barColor = color ?? kOnboardingColors;
    final useLightIcons = ThemeData.estimateBrightnessForColor(barColor) ==
        Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (useLightIcons
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Container(
        padding: EdgeInsets.only(
          left: size.width * 0.055,
          right: size.width * 0.055,
          top: statusTop,
        ),
        color: barColor,
        child: SizedBox(
          height: size.height * 0.09,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              backButton ?? SizedBox(),
              Row(
                children: [
                  logo ??
                      Image.asset(
                        "assets/images/goeclogo.png",
                        height: size.height * 0.065,
                        width: size.width * 0.17,
                      ),
                ],
              ),
              Row(
                children: [
                  if (text != null)
                    InkWell(
                      onTap: skiponTap,
                      child: Text(
                        text!,
                        style: kAppSkipButtonTextStyle,
                      ),
                    ),
                  if (icon != null)
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.004),
                      child: IconButton(
                        color: kwhite,
                        onPressed: skiponTap,
                        icon: icon!,
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
