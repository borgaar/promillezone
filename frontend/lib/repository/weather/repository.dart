import 'package:equatable/equatable.dart';

// Domain Models

class WeatherCondition extends Equatable {
  final String text;
  final String icon;
  final int code;

  const WeatherCondition({
    required this.text,
    required this.icon,
    required this.code,
  });

  @override
  List<Object?> get props => [text, icon, code];
}

class Location extends Equatable {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;
  final String tzId;
  final int localtimeEpoch;
  final String localtime;

  const Location({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.tzId,
    required this.localtimeEpoch,
    required this.localtime,
  });

  @override
  List<Object?> get props => [
        name,
        region,
        country,
        lat,
        lon,
        tzId,
        localtimeEpoch,
        localtime,
      ];
}

class CurrentWeather extends Equatable {
  final int lastUpdatedEpoch;
  final String lastUpdated;
  final double tempC;
  final double tempF;
  final bool isDay;
  final WeatherCondition condition;
  final double windMph;
  final double windKph;
  final int windDegree;
  final String windDir;
  final double pressureMb;
  final double pressureIn;
  final double precipMm;
  final double precipIn;
  final int humidity;
  final int cloud;
  final double feelslikeC;
  final double feelslikeF;
  final double windchillC;
  final double windchillF;
  final double heatindexC;
  final double heatindexF;
  final double dewpointC;
  final double dewpointF;
  final double visKm;
  final double visMiles;
  final double uv;
  final double gustMph;
  final double gustKph;
  final double? shortRad;
  final double? diffRad;
  final double? dni;
  final double? gti;

  const CurrentWeather({
    required this.lastUpdatedEpoch,
    required this.lastUpdated,
    required this.tempC,
    required this.tempF,
    required this.isDay,
    required this.condition,
    required this.windMph,
    required this.windKph,
    required this.windDegree,
    required this.windDir,
    required this.pressureMb,
    required this.pressureIn,
    required this.precipMm,
    required this.precipIn,
    required this.humidity,
    required this.cloud,
    required this.feelslikeC,
    required this.feelslikeF,
    required this.windchillC,
    required this.windchillF,
    required this.heatindexC,
    required this.heatindexF,
    required this.dewpointC,
    required this.dewpointF,
    required this.visKm,
    required this.visMiles,
    required this.uv,
    required this.gustMph,
    required this.gustKph,
    this.shortRad,
    this.diffRad,
    this.dni,
    this.gti,
  });

  @override
  List<Object?> get props => [
        lastUpdatedEpoch,
        lastUpdated,
        tempC,
        tempF,
        isDay,
        condition,
        windMph,
        windKph,
        windDegree,
        windDir,
        pressureMb,
        pressureIn,
        precipMm,
        precipIn,
        humidity,
        cloud,
        feelslikeC,
        feelslikeF,
        windchillC,
        windchillF,
        heatindexC,
        heatindexF,
        dewpointC,
        dewpointF,
        visKm,
        visMiles,
        uv,
        gustMph,
        gustKph,
        shortRad,
        diffRad,
        dni,
        gti,
      ];
}

class ForecastDay extends Equatable {
  final double maxtempC;
  final double maxtempF;
  final double mintempC;
  final double mintempF;
  final double avgtempC;
  final double avgtempF;
  final double maxwindMph;
  final double maxwindKph;
  final double totalprecipMm;
  final double totalprecipIn;
  final double totalsnowCm;
  final double avgvisKm;
  final double avgvisMiles;
  final int avghumidity;
  final bool dailyWillItRain;
  final int dailyChanceOfRain;
  final bool dailyWillItSnow;
  final int dailyChanceOfSnow;
  final WeatherCondition condition;
  final double uv;

  const ForecastDay({
    required this.maxtempC,
    required this.maxtempF,
    required this.mintempC,
    required this.mintempF,
    required this.avgtempC,
    required this.avgtempF,
    required this.maxwindMph,
    required this.maxwindKph,
    required this.totalprecipMm,
    required this.totalprecipIn,
    required this.totalsnowCm,
    required this.avgvisKm,
    required this.avgvisMiles,
    required this.avghumidity,
    required this.dailyWillItRain,
    required this.dailyChanceOfRain,
    required this.dailyWillItSnow,
    required this.dailyChanceOfSnow,
    required this.condition,
    required this.uv,
  });

  @override
  List<Object?> get props => [
        maxtempC,
        maxtempF,
        mintempC,
        mintempF,
        avgtempC,
        avgtempF,
        maxwindMph,
        maxwindKph,
        totalprecipMm,
        totalprecipIn,
        totalsnowCm,
        avgvisKm,
        avgvisMiles,
        avghumidity,
        dailyWillItRain,
        dailyChanceOfRain,
        dailyWillItSnow,
        dailyChanceOfSnow,
        condition,
        uv,
      ];
}

class WeatherData extends Equatable {
  final Location location;
  final CurrentWeather current;
  final ForecastDay forecast;

  const WeatherData({
    required this.location,
    required this.current,
    required this.forecast,
  });

  @override
  List<Object?> get props => [location, current, forecast];
}

// Exceptions

abstract class WeatherException implements Exception {
  final String code;
  final String message;

  const WeatherException({required this.code, required this.message});

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class WeatherBadRequestException extends WeatherException {
  const WeatherBadRequestException({
    required super.code,
    required super.message,
  });
}

class WeatherUnauthorizedException extends WeatherException {
  const WeatherUnauthorizedException({
    required super.code,
    required super.message,
  });
}

class WeatherNotFoundException extends WeatherException {
  const WeatherNotFoundException({
    required super.code,
    required super.message,
  });
}

class WeatherInternalServerException extends WeatherException {
  const WeatherInternalServerException({
    required super.code,
    required super.message,
  });
}

class WeatherUnknownException extends WeatherException {
  const WeatherUnknownException({
    required super.code,
    required super.message,
  });
}

class WeatherInvalidLocationException extends WeatherException {
  const WeatherInvalidLocationException({
    required super.code,
    required super.message,
  });
}

class WeatherApiKeyInvalidException extends WeatherException {
  const WeatherApiKeyInvalidException({
    required super.code,
    required super.message,
  });
}

// Repository Interface

abstract interface class WeatherRepository {
  /// Gets current weather and forecast for a location
  ///
  /// Parameters:
  /// - [latitude]: Latitude coordinate of the location
  /// - [longitude]: Longitude coordinate of the location
  ///
  /// Returns a [WeatherData] with location, current weather, and daily forecast
  ///
  /// Throws:
  /// - [WeatherBadRequestException] if coordinates are invalid
  /// - [WeatherUnauthorizedException] if API key is invalid or expired
  /// - [WeatherNotFoundException] if location cannot be found
  /// - [WeatherApiKeyInvalidException] if API key authentication fails
  /// - [WeatherInvalidLocationException] if coordinates format is wrong
  /// - [WeatherInternalServerException] if WeatherAPI server error occurs
  /// - [WeatherUnknownException] if unknown error occurs
  Future<WeatherData> getForecast({
    required double latitude,
    required double longitude,
  });
}
