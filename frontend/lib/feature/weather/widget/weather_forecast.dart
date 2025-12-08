import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promillezone/feature/weather/cubit/weather_cubit.dart';

class WeatherForecast extends StatelessWidget {
  const WeatherForecast({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        return switch (state) {
          WeatherInitial() => const SizedBox.shrink(),
          WeatherInProgress() => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          WeatherLoaded(:final weatherData) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: weatherData.current.isDay
                    ? [const Color(0xFF0D5275), const Color(0xFF1E7A9C)]
                    : [const Color(0xFF0A1929), const Color(0xFF1A2942)],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time and location header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('E H.mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                          weatherData.location.localtimeEpoch * 1000,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Time display
                Text(
                  DateFormat('HH:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                      weatherData.location.localtimeEpoch * 1000,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    height: 1,
                  ),
                ),

                // Location
                Text(
                  weatherData.location.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 32),

                // Weather icon and temperature
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather icon
                    Image.network(
                      'https:${weatherData.current.condition.icon}'.replaceAll(
                        '64x64',
                        '128x128',
                      ),
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.wb_sunny,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Temperature and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current temperature
                          Text(
                            '${weatherData.current.tempC.round()}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.w200,
                              height: 1,
                            ),
                          ),

                          // Temperature range
                          Text(
                            'min ${weatherData.forecast.mintempC.round()}, maks ${weatherData.forecast.maxtempC.round()}°',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Weather condition
                          Text(
                            weatherData.current.condition.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
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
        };
      },
    );
  }
}
