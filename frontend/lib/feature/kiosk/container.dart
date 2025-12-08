import 'package:flutter/material.dart';
import 'package:promillezone/feature/kiosk/constants.dart';

class KioskContainer extends StatelessWidget {
  const KioskContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kioskBackgroundColor,
        borderRadius: BorderRadius.circular(kioskBorderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: child,
    );
  }
}
