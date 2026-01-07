import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

final class Forecast extends Equatable {
  final DateTime time;
  final ImageProvider icon;
  final int temperature;
  final int precipitationMm;

  const Forecast({
    required this.time,
    required this.icon,
    required this.temperature,
    required this.precipitationMm,
  });

  @override
  get props => [time, icon, temperature, precipitationMm];
}

final class WeatherData extends Equatable {
  final List<Forecast> forecasts;

  const WeatherData({required this.forecasts});

  @override
  get props => [forecasts];
}

abstract class WeatherRepository {
  /// Gets current weather and forecast for a location
  ///
  /// Parameters:
  /// - [latitude]: Latitude coordinate of the location
  /// - [longitude]: Longitude coordinate of the location
  ///
  Future<WeatherData> getForecast({
    required double latitude,
    required double longitude,
  });
}
