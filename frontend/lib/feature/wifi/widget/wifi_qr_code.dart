import 'package:flutter/material.dart';
import 'package:promillezone/feature/kiosk/container.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WifiQrCode extends StatelessWidget {
  final String ssid;
  final String password;
  final String securityType; // e.g., 'WPA'

  const WifiQrCode({
    super.key,
    required this.ssid,
    required this.password,
    required this.securityType,
  });

  @override
  Widget build(BuildContext context) {
    // Generate the correctly formatted Wi-Fi data string
    final String wifiData = 'WIFI:S:$ssid;T:$securityType;P:$password;;';

    return KioskContainer(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset("asset/img/wifi_icon.png", width: 100),
            QrImageView(
              data: wifiData,
              version: QrVersions.auto,
              size: 180.0,
              eyeStyle: QrEyeStyle(
                color: Colors.white,
                eyeShape: QrEyeShape.square,
              ),
              dataModuleStyle: QrDataModuleStyle(
                color: Colors.white,
                dataModuleShape: QrDataModuleShape.square,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
