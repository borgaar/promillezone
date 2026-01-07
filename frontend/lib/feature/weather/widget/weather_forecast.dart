import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promillezone/feature/kiosk/container.dart';
import 'package:promillezone/feature/weather/cubit/weather_cubit.dart';

class WeatherForecast extends StatelessWidget {
  const WeatherForecast({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is! WeatherLoaded) {
          return const SizedBox.shrink();
        }

        final weatherData = state.weatherData;

        return KioskContainer(
          child: Column(
            children: weatherData.forecasts.map((forecast) {
              final time = forecast.time;

              final now = DateTime.now();
              final difference = time.difference(now);
              final String formattedTime;

              if (difference.inMinutes < 30) {
                formattedTime = 'nå';
              } else {
                final hours = difference.inHours;
                formattedTime = '${hours}t';
              }

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

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  Image(image: forecast.icon, width: 110),
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
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
