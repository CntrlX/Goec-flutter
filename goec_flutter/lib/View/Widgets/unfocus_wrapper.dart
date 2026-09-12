import 'package:flutter/material.dart';

class AppFocus {
  AppFocus._();

  static void unfocus([BuildContext? context]) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (context != null && context.mounted) {
      final currentScope = FocusScope.of(context);
      if (!currentScope.hasPrimaryFocus && currentScope.focusedChild != null) {
        currentScope.unfocus();
      }
    }
  }

  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  static void requestFocus(BuildContext context, FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }
}

class UnfocusWrapper extends StatelessWidget {
  final Widget child;
  final HitTestBehavior behavior;
  final VoidCallback? onUnfocus;

  const UnfocusWrapper({
    super.key,
    required this.child,
    this.behavior = HitTestBehavior.translucent,
    this.onUnfocus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: behavior,
      onTap: () {
        AppFocus.unfocus(context);
        onUnfocus?.call();
      },
      child: child,
    );
  }
}

extension UnfocusWidgetExtension on Widget {
  Widget unfocusOnTap({
    HitTestBehavior behavior = HitTestBehavior.translucent,
    VoidCallback? onUnfocus,
  }) {
    return UnfocusWrapper(
      behavior: behavior,
      onUnfocus: onUnfocus,
      child: this,
    );
  }
}
