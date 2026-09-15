import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freelancer_app/Controller/splash_screen_controller.dart';
import 'package:freelancer_app/View/Widgets/appbar.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late AnimationController _textController;
  late AnimationController _underlineController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<Offset> _slideAnimation;

  // Individual character animations for G - O - E - C
  final List<String> _letters = ['G', 'O', 'E', 'C'];
  late List<Animation<double>> _letterOpacities;
  late List<Animation<double>> _letterScales;
  late List<Animation<double>> _letterBlurs;
  late List<Animation<Offset>> _letterSlides;
  late List<Animation<double>> _letterTilts;

  late Animation<double> _trackingAnimation;
  late Animation<double> _underlineWidth;
  late Animation<double> _underlineOpacity;

  @override
  void initState() {
    super.initState();
    Get.put(SplashScreenController());

    // 1. Logo Entrance Animation (1100ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // 2. Ambient Shimmer Controller (Looping)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // 3. Advanced Text Controller (950ms)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    // 4. Accent Underline Line Controller (450ms)
    _underlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_entranceController);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _blurAnimation = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Global tracking (letter spacing) expansion -> lock
    _trackingAnimation = Tween<double>(begin: 6.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Staggered per-character micro-physics
    _letterOpacities = [];
    _letterScales = [];
    _letterBlurs = [];
    _letterSlides = [];
    _letterTilts = [];

    const charCount = 4;
    for (int i = 0; i < charCount; i++) {
      final double start = (i * 0.11).clamp(0.0, 0.6);
      final double end = (start + 0.48).clamp(0.0, 1.0);

      _letterOpacities.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(start, (start + 0.3).clamp(0.0, 1.0),
                curve: Curves.easeOut),
          ),
        ),
      );

      _letterScales.add(
        TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.7, end: 1.08)
                .chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 65,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.08, end: 1.0)
                .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 35,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(start, end, curve: Curves.linear),
          ),
        ),
      );

      _letterBlurs.add(
        Tween<double>(begin: 8.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );

      _letterSlides.add(
        Tween<Offset>(begin: const Offset(0, 0.45), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );

      _letterTilts.add(
        Tween<double>(begin: 0.35, end: 0.0).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    // Underline glow accent
    _underlineWidth = Tween<double>(begin: 0.0, end: 54.w).animate(
      CurvedAnimation(
        parent: _underlineController,
        curve: Curves.easeOutCubic,
      ),
    );

    _underlineOpacity = Tween<double>(begin: 0.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _underlineController,
        curve: Curves.easeIn,
      ),
    );

    _playChoreographedEntrance();
  }

  Future<void> _playChoreographedEntrance() async {
    _entranceController.forward();
    // Stagger: start text when logo entrance is in full flight
    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _underlineController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _textController.dispose();
    _underlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (size.height == 0) {
      size = MediaQuery.of(context).size;
    }
    return WhiteStatusBar(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Logo Vector Mark
              AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: _blurAnimation.value,
                            sigmaY: _blurAnimation.value,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/goec_m_logo.svg",
                                width: 165.w,
                                fit: BoxFit.contain,
                              ),
                              if (_entranceController.value > 0.5)
                                Shimmer.fromColors(
                                  baseColor: Colors.transparent,
                                  highlightColor:
                                      Colors.white.withValues(alpha: 0.6),
                                  period: const Duration(milliseconds: 1600),
                                  direction: ShimmerDirection.ltr,
                                  child: SvgPicture.asset(
                                    "assets/svg/goec_m_logo.svg",
                                    width: 165.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 12.h),

              // 2. High-Tech Staggered Brand Typography
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  final tracking = _trackingAnimation.value;
                  return ShaderMask(
                    shaderCallback: (bounds) =>
                        kOnboardingGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_letters.length, (index) {
                            final letter = _letters[index];
                            final opacity = _letterOpacities[index].value;
                            final scale = _letterScales[index].value;
                            final blur = _letterBlurs[index].value;
                            final slide = _letterSlides[index].value;
                            final tilt = _letterTilts[index].value;

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: (tracking / 2).w),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.002)
                                  ..rotateX(tilt * math.pi),
                                child: SlideTransition(
                                  position: AlwaysStoppedAnimation(slide),
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Transform.scale(
                                      scale: scale,
                                      child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                          sigmaX: blur,
                                          sigmaY: blur,
                                        ),
                                        child: Text(
                                          letter,
                                          style: TextStyle(
                                            fontFamily: kFontFamily,
                                            fontSize: 38.sp,
                                            fontWeight: FontWeight.w800,
                                            height: 1.1,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        // Coordinated specular sheen sweep across resolved characters
                        if (_textController.value > 0.6)
                          Positioned.fill(
                            child: Shimmer.fromColors(
                              baseColor: Colors.transparent,
                              highlightColor:
                                  Colors.white.withValues(alpha: 0.55),
                              period: const Duration(milliseconds: 1400),
                              direction: ShimmerDirection.ltr,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    List.generate(_letters.length, (index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: (tracking / 2).w),
                                    child: Text(
                                      _letters[index],
                                      style: TextStyle(
                                        fontFamily: kFontFamily,
                                        fontSize: 38.sp,
                                        fontWeight: FontWeight.w800,
                                        height: 1.1,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 6.h),

              // 3. Sleek Symmetrical Brand Accent Line
              AnimatedBuilder(
                animation: _underlineController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _underlineOpacity.value,
                    child: Container(
                      width: _underlineWidth.value,
                      height: 2.2.h,
                      decoration: BoxDecoration(
                        gradient: kOnboardingGradient,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
