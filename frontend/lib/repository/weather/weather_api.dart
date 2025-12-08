import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'repository.dart';

final class WeatherApiRepository implements WeatherRepository {
  final Dio _dio;
  final String _apiKey;

  WeatherApiRepository()
      : _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '',
        _dio = Dio(BaseOptions(
          baseUrl: 'https://api.weatherapi.com/v1',
          connectTimeout: const Duration(milliseconds: 10000),
          receiveTimeout: const Duration(milliseconds: 10000),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )) {
    if (_apiKey.isEmpty) {
      throw const WeatherApiKeyInvalidException(
        code: 'missing_api_key',
        message: 'WEATHER_API_KEY not found in environment variables',
      );
    }
  }

  @override
  Future<WeatherData> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/forecast.json',
        queryParameters: {
          'q': '$latitude,$longitude',
          'days': 1,
          'key': _apiKey,
        },
      );

      if (response.data == null) {
        throw const WeatherUnknownException(
          code: 'no_data',
          message: 'No weather data returned from server',
        );
      }

      return _mapToWeatherData(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  WeatherData _mapToWeatherData(Map<String, dynamic> data) {
    final locationData = data['location'] as Map<String, dynamic>;
    final currentData = data['current'] as Map<String, dynamic>;
    final forecastData = data['forecast'] as Map<String, dynamic>;
    final forecastDayData =
        (forecastData['forecastday'] as List).first as Map<String, dynamic>;
    final dayData = forecastDayData['day'] as Map<String, dynamic>;

    return WeatherData(
      location: _mapToLocation(locationData),
      current: _mapToCurrentWeather(currentData),
      forecast: _mapToForecastDay(dayData),
    );
  }

  Location _mapToLocation(Map<String, dynamic> data) {
    return Location(
      name: data['name'] as String,
      region: data['region'] as String,
      country: data['country'] as String,
      lat: (data['lat'] as num).toDouble(),
      lon: (data['lon'] as num).toDouble(),
      tzId: data['tz_id'] as String,
      localtimeEpoch: data['localtime_epoch'] as int,
      localtime: data['localtime'] as String,
    );
  }

  WeatherCondition _mapToCondition(Map<String, dynamic> data) {
    return WeatherCondition(
      text: data['text'] as String,
      icon: data['icon'] as String,
      code: data['code'] as int,
    );
  }

  CurrentWeather _mapToCurrentWeather(Map<String, dynamic> data) {
    final conditionData = data['condition'] as Map<String, dynamic>;

    return CurrentWeather(
      lastUpdatedEpoch: data['last_updated_epoch'] as int,
      lastUpdated: data['last_updated'] as String,
      tempC: (data['temp_c'] as num).toDouble(),
      tempF: (data['temp_f'] as num).toDouble(),
      isDay: (data['is_day'] as int) == 1,
      condition: _mapToCondition(conditionData),
      windMph: (data['wind_mph'] as num).toDouble(),
      windKph: (data['wind_kph'] as num).toDouble(),
      windDegree: data['wind_degree'] as int,
      windDir: data['wind_dir'] as String,
      pressureMb: (data['pressure_mb'] as num).toDouble(),
      pressureIn: (data['pressure_in'] as num).toDouble(),
      precipMm: (data['precip_mm'] as num).toDouble(),
      precipIn: (data['precip_in'] as num).toDouble(),
      humidity: data['humidity'] as int,
      cloud: data['cloud'] as int,
      feelslikeC: (data['feelslike_c'] as num).toDouble(),
      feelslikeF: (data['feelslike_f'] as num).toDouble(),
      windchillC: (data['windchill_c'] as num).toDouble(),
      windchillF: (data['windchill_f'] as num).toDouble(),
      heatindexC: (data['heatindex_c'] as num).toDouble(),
      heatindexF: (data['heatindex_f'] as num).toDouble(),
      dewpointC: (data['dewpoint_c'] as num).toDouble(),
      dewpointF: (data['dewpoint_f'] as num).toDouble(),
      visKm: (data['vis_km'] as num).toDouble(),
      visMiles: (data['vis_miles'] as num).toDouble(),
      uv: (data['uv'] as num).toDouble(),
      gustMph: (data['gust_mph'] as num).toDouble(),
      gustKph: (data['gust_kph'] as num).toDouble(),
      shortRad:
          data['short_rad'] != null ? (data['short_rad'] as num).toDouble() : null,
      diffRad:
          data['diff_rad'] != null ? (data['diff_rad'] as num).toDouble() : null,
      dni: data['dni'] != null ? (data['dni'] as num).toDouble() : null,
      gti: data['gti'] != null ? (data['gti'] as num).toDouble() : null,
    );
  }

  ForecastDay _mapToForecastDay(Map<String, dynamic> data) {
    final conditionData = data['condition'] as Map<String, dynamic>;

    return ForecastDay(
      maxtempC: (data['maxtemp_c'] as num).toDouble(),
      maxtempF: (data['maxtemp_f'] as num).toDouble(),
      mintempC: (data['mintemp_c'] as num).toDouble(),
      mintempF: (data['mintemp_f'] as num).toDouble(),
      avgtempC: (data['avgtemp_c'] as num).toDouble(),
      avgtempF: (data['avgtemp_f'] as num).toDouble(),
      maxwindMph: (data['maxwind_mph'] as num).toDouble(),
      maxwindKph: (data['maxwind_kph'] as num).toDouble(),
      totalprecipMm: (data['totalprecip_mm'] as num).toDouble(),
      totalprecipIn: (data['totalprecip_in'] as num).toDouble(),
      totalsnowCm: (data['totalsnow_cm'] as num).toDouble(),
      avgvisKm: (data['avgvis_km'] as num).toDouble(),
      avgvisMiles: (data['avgvis_miles'] as num).toDouble(),
      avghumidity: (data['avghumidity'] as num).toInt(),
      dailyWillItRain: (data['daily_will_it_rain'] as int) == 1,
      dailyChanceOfRain: data['daily_chance_of_rain'] as int,
      dailyWillItSnow: (data['daily_will_it_snow'] as int) == 1,
      dailyChanceOfSnow: data['daily_chance_of_snow'] as int,
      condition: _mapToCondition(conditionData),
      uv: (data['uv'] as num).toDouble(),
    );
  }

  WeatherException _handleError(DioException e) {
    final response = e.response;

    if (response == null) {
      return WeatherUnknownException(
        code: 'network_error',
        message: e.message ?? 'Network error occurred',
      );
    }

    final data = response.data;

    String code = 'unknown';
    String message = 'An unknown error occurred';

    if (data is Map<String, dynamic>) {
      if (data['error'] != null && data['error'] is Map<String, dynamic>) {
        final error = data['error'] as Map<String, dynamic>;
        code = error['code']?.toString() ?? code;
        message = error['message']?.toString() ?? message;
      } else {
        code = data['code']?.toString() ?? code;
        message = data['message']?.toString() ?? message;
      }
    }

    switch (response.statusCode) {
      case 400:
        if (code == '1006' || message.toLowerCase().contains('location')) {
          return WeatherInvalidLocationException(code: code, message: message);
        }
        return WeatherBadRequestException(code: code, message: message);

      case 401:
      case 403:
        if (code == '2006' ||
            code == '2007' ||
            code == '2008' ||
            message.toLowerCase().contains('api key') ||
            message.toLowerCase().contains('authentication')) {
          return WeatherApiKeyInvalidException(code: code, message: message);
        }
        return WeatherUnauthorizedException(code: code, message: message);

      case 404:
        return WeatherNotFoundException(code: code, message: message);

      case 500:
      case 503:
        return WeatherInternalServerException(code: code, message: message);

      default:
        return WeatherUnknownException(code: code, message: message);
    }
  }
}
