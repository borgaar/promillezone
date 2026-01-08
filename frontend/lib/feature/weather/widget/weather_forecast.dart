import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promillezone/feature/kiosk/container.dart';
import 'package:promillezone/repository/weather/repository.dart';

class WeatherForecast extends StatelessWidget {
  const WeatherForecast({super.key});

  String _getLabelForIndex(int index) {
    return switch (index) {
      0 => 'nå',
      1 => '6t',
      2 => '12t',
      3 => 'i morgen',
      4 => 'overimorgen',
      5 => '3 dager',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return KioskPollingContainer<WeatherData>(
      buildSuccess: (context, value) {
        return Column(
          spacing: 6,
          mainAxisAlignment: MainAxisAlignment.center,
          children: value.forecasts
              .asMap()
              .entries
              .take(6)
              .map((entry) => ForecastRow(
                    forecast: entry.value,
                    label: _getLabelForIndex(entry.key),
                  ))
              .toList(),
        );
      },
      mode: TransitionMode.slide,
    );
  }
}

class ForecastRow extends StatelessWidget {
  const ForecastRow({super.key, required this.forecast, this.label});

  final Forecast forecast;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final String formattedTime = label ??
        (() {
          final time = forecast.time;
          final now = DateTime.now();
          final difference = time.difference(now);
          if (difference.inMinutes < 30) {
            return 'nå';
          } else {
            return DateFormat.Hm().format(time);
          }
        })();

    final Color temperatureColor;
    if (forecast.temperature >= 20) {
      temperatureColor = const Color(0xFFFF9D00);
    } else if (forecast.temperature >= 1) {
      temperatureColor = Colors.white;
    } else {
      temperatureColor = const Color(0xFFB4DBFF);
    }

    final Color precipitationColor;
    if (forecast.precipitationMm == 0) {
      precipitationColor = const Color(0xFF71727A);
    } else if (forecast.precipitationMm <= 3) {
      precipitationColor = const Color(0xFFB4DBFF);
    } else {
      precipitationColor = const Color(0xFF2897FF);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            formattedTime,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image(image: forecast.icon, width: 92),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${forecast.temperature}°",
                      style: TextStyle(
                        color: temperatureColor,
                        fontSize: 42,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: forecast.precipitationMm.toString(),
                            style: TextStyle(
                              color: precipitationColor,
                              fontSize: 38,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: "mm",
                            style: TextStyle(
                              color: precipitationColor,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
