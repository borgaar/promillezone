import 'dart:io';

import 'package:flutter/material.dart';
import 'package:promillezone/feature/collective_transport/widget/collective_transport_stop_viewer.dart';
import 'package:promillezone/feature/countdown/widget/countdown.dart';
import 'package:promillezone/feature/dynamic_content/widget/dynamic_content_widget.dart';
import 'package:promillezone/feature/garbage_disposal/widget/garbage_disposal.dart';
import 'package:promillezone/feature/kiosk/constants.dart';
import 'package:promillezone/feature/kiosk/container.dart';
import 'package:promillezone/feature/time/widget/time_widget.dart';
import 'package:promillezone/feature/weather/widget/weather_forecast.dart';
import 'package:promillezone/feature/wifi/widget/wifi_qr_code.dart';

class KioskPage extends StatelessWidget {
  const KioskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: "Inter"),
      ),
      child: Scaffold(
        body: AspectRatio(
          aspectRatio: 16 / 9,
          child: Padding(
            // Our TV is a bit fucked, shifting everything to the right
            padding: Platform.localHostname == "zone"
                ? EdgeInsets.only(right: kioskContainerSpacing * 3)
                : const EdgeInsets.all(kioskContainerSpacing),
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
                  child: Row(
                    spacing: kioskContainerSpacing,
                    children: [
                      Expanded(flex: 3, child: WeatherForecast()),
                      Expanded(flex: 6, child: CollectiveTransportStopViewer()),
                      Expanded(
                        flex: 2,
                        child: Column(
                          spacing: kioskContainerSpacing,
                          children: [
                            Expanded(child: GarbageDisposal()),
                            SizedBox(
                              height: 200,
                              child: WifiQrCode(
                                ssid: 'pear_to_pear_network_5G',
                                password: 'thebestkindofnetwork',
                                securityType: 'WPA2',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
