import 'package:flutter/material.dart';
import 'package:promillezone/feature/daily_content/widget/daily_content_widget.dart';
import 'package:promillezone/feature/kiosk/constants.dart';
import 'package:promillezone/feature/time/widget/time_widget.dart';

class KioskPage extends StatelessWidget {
  const KioskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AspectRatio(
        aspectRatio: 16 / 9,
        child: Padding(
          padding: const EdgeInsets.all(kioskContainerSpacing),
          child: Column(
            spacing: kioskContainerSpacing,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  spacing: kioskContainerSpacing,
                  children: [
                    Expanded(flex: 1, child: TimeWidget()),
                    Expanded(flex: 2, child: DailyContentWidget()),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(children: [Expanded(child: Placeholder())]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
