import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:promillezone/repository/weather/repository.dart';

final class YrWeatherRepository extends WeatherRepository {
  @override
  Future<WeatherData> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      "api.met.no",
      "/weatherapi/locationforecast/2.0/compact",
      {"lat": latitude.toString(), "lon": longitude.toString()},
    );

    final response = await Dio().getUri(
      uri,
      options: Options(
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:146.0) Gecko/20100101 Firefox/146.0",
        },
      ),
    );

    final body = response.data as Map<String, dynamic>;
    final properties = body['properties'] as Map<String, dynamic>;
    final timeseries = properties['timeseries'] as List<dynamic>;

    final forecasts = timeseries
        .expand((ts) => [?_extractForecast(ts)])
        .where(
          (f) =>
              f.time.millisecondsSinceEpoch >
              DateTime.now().millisecondsSinceEpoch,
        )
        .toList();
    forecasts.sort((a, b) => a.time.compareTo(b.time));

    return WeatherData(forecasts: forecasts);
  }

  Forecast? _extractForecast(Map<String, dynamic> entry) {
    try {
      final timeStr = entry['time'] as String;
      final time = DateTime.parse(timeStr);
      final data = entry['data'] as Map<String, dynamic>;

      // Get instant details for temperature
      final instant = data['instant'] as Map<String, dynamic>;
      final details = instant['details'] as Map<String, dynamic>;
      final temperature = (details['air_temperature'] as num).round();

      final symbolCode =
          data["next_1_hours"]["summary"]['symbol_code'] as String;

      final precipitation =
          (data["next_1_hours"]?["details"]?['precipitation_amount'] as num?)
              ?.round() ??
          0;

      final icon = _getWeatherIcon(symbolCode);

      return Forecast(
        time: time,
        icon: icon,
        temperature: temperature,
        precipitationMm: precipitation,
      );
    } catch (e) {
      return null;
    }
  }

  ImageProvider _getWeatherIcon(String symbolCode) {
    // Strip any suffix like _day, _night, _polartwilight
    final baseCode = symbolCode.replaceAll(
      RegExp(r'_(day|night|polartwilight)$'),
      '',
    );

    final code = switch (baseCode) {
      'clearsky' => '01',
      'fair' => '02',
      'partlycloudy' => '03',
      'cloudy' => '04',
      'rainshowers' => '05',
      'rainshowersandthunder' => '06',
      'sleetshowers' => '07',
      'snowshowers' => '08',
      'rain' => '09',
      'heavyrain' => '10',
      'heavyrainandthunder' => '11',
      'sleet' => '12',
      'snow' => '13',
      'snowandthunder' => '14',
      'fog' => '15',
      'sleetshowersandthunder' => '20',
      'snowshowersandthunder' => '21',
      'rainandthunder' => '22',
      'sleetandthunder' => '23',
      'lightrainshowersandthunder' => '24',
      'heavyrainshowersandthunder' => '25',
      'lightssleetshowersandthunder' => '26',
      'heavysleetshowersandthunder' => '27',
      'lightssnowshowersandthunder' => '28',
      'heavysnowshowersandthunder' => '29',
      'lightrainandthunder' => '30',
      'lightsleetandthunder' => '31',
      'heavysleetandthunder' => '32',
      'lightsnowandthunder' => '33',
      'heavysnowandthunder' => '34',
      'lightrainshowers' => '40',
      'heavyrainshowers' => '41',
      'lightsleetshowers' => '42',
      'heavysleetshowers' => '43',
      'lightsnowshowers' => '44',
      'heavysnowshowers' => '45',
      'lightrain' => '46',
      'lightsleet' => '47',
      'heavysleet' => '48',
      'lightsnow' => '49',
      'heavysnow' => '50',
      _ => 'default',
    };

    // Add suffix back if present
    final suffix = symbolCode.contains('_day')
        ? 'd'
        : symbolCode.contains('_night')
        ? 'n'
        : symbolCode.contains('_polartwilight')
        ? 'm'
        : '';

    final path = "asset/img/yr/$code$suffix.png";
    return AssetImage(path);
  }
}
