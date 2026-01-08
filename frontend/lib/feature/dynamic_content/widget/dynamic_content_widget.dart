import 'package:flutter/material.dart';
import 'package:promillezone/feature/kiosk/constants.dart';
import 'package:promillezone/feature/kiosk/container.dart';
import 'package:promillezone/repository/dynamic_content/repository.dart';

const titleStyle = TextStyle(
  color: kioskTextColor,
  fontSize: 40,
  fontWeight: FontWeight.w700,
  fontFamily: "Inter",
);

class DailyContentWidget extends StatelessWidget {
  const DailyContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return KioskPollingContainer<DynamicContent>(
      buildSuccess: (context, value) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: value.blocks.map((b) {
            return switch (b) {
              TextContentBlock(:final title, :final text, :final fontFamily) =>
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: titleStyle,
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              text,
                              style: TextStyle(
                                color: kioskTextColor,
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                                fontFamily: fontFamily,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ImageContentBlock(:final title, :final image) => Expanded(
                child: Column(
                  children: [
                    Text(title, style: titleStyle, textAlign: TextAlign.center),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(
                          kioskBorderRadius / 2,
                        ),
                        child: Image(image: image, fit: BoxFit.fill),
                      ),
                    ),
                  ],
                ),
              ),
            };
          }).toList(),
        );
      },
      mode: TransitionMode.slide,
    );
  }
}
