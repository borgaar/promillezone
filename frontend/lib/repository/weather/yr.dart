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

    final forecasts = _extractSpecificForecasts(timeseries);

    return WeatherData(forecasts: forecasts);
  }

  Forecast? _extractForecastFromEntry(
    Map<String, dynamic> entry,
    String periodField,
  ) {
    try {
      final timeStr = entry['time'] as String;
      final time = DateTime.parse(timeStr);
      final data = entry['data'] as Map<String, dynamic>;

      // Check if the requested period exists
      if (data[periodField] == null) {
        return null;
      }

      // Get instant details for temperature
      final instant = data['instant'] as Map<String, dynamic>;
      final details = instant['details'] as Map<String, dynamic>;
      final temperature = (details['air_temperature'] as num).round();

      final periodData = data[periodField] as Map<String, dynamic>;
      final symbolCode = periodData["summary"]['symbol_code'] as String;

      final precipitation =
          (periodData["details"]?['precipitation_amount'] as num?)?.round() ??
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

  Forecast? _extractNowForecast(List<dynamic> timeseries, DateTime now) {
    for (var entry in timeseries) {
      try {
        final timeStr = entry['time'] as String;
        final time = DateTime.parse(timeStr);
        if (time.isAfter(now) || time.isAtSameMomentAs(now)) {
          return _extractForecastFromEntry(entry, 'next_1_hours');
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  Forecast? _extract6HourForecast(List<dynamic> timeseries, DateTime now) {
    for (var entry in timeseries) {
      try {
        final timeStr = entry['time'] as String;
        final time = DateTime.parse(timeStr);
        final data = entry['data'] as Map<String, dynamic>;

        if (time.isAfter(now) && data['next_6_hours'] != null) {
          return _extractForecastFromEntry(entry, 'next_6_hours');
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  Forecast? _extract12HourForecast(List<dynamic> timeseries, DateTime now) {
    for (var entry in timeseries) {
      try {
        final timeStr = entry['time'] as String;
        final time = DateTime.parse(timeStr);
        final data = entry['data'] as Map<String, dynamic>;

        if (time.isAfter(now) && data['next_12_hours'] != null) {
          return _extractForecastFromEntry(entry, 'next_12_hours');
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  Forecast? _extractDayForecast(List<dynamic> timeseries, DateTime targetDay) {
    try {
      final targetNoon =
          DateTime(targetDay.year, targetDay.month, targetDay.day, 12, 0);

      // Filter to entries on target day with next_12_hours
      final candidateEntries = <MapEntry<Map<String, dynamic>, DateTime>>[];

      for (var entry in timeseries) {
        try {
          final timeStr = entry['time'] as String;
          final time = DateTime.parse(timeStr);
          final data = entry['data'] as Map<String, dynamic>;

          if (time.year == targetDay.year &&
              time.month == targetDay.month &&
              time.day == targetDay.day &&
              data['next_12_hours'] != null) {
            candidateEntries.add(MapEntry(entry, time));
          }
        } catch (e) {
          continue;
        }
      }

      if (candidateEntries.isEmpty) return null;

      // Find entry closest to noon
      var bestEntry = candidateEntries.first;
      var minDiff = (bestEntry.value.difference(targetNoon)).abs();

      for (var candidate in candidateEntries.skip(1)) {
        final diff = (candidate.value.difference(targetNoon)).abs();
        if (diff < minDiff) {
          minDiff = diff;
          bestEntry = candidate;
        }
      }

      return _extractForecastFromEntry(bestEntry.key, 'next_12_hours');
    } catch (e) {
      return null;
    }
  }

  List<Forecast> _extractSpecificForecasts(List<dynamic> timeseries) {
    final forecasts = <Forecast>[];
    final now = DateTime.now();

    // 1. Now forecast (next_1_hours)
    final nowForecast = _extractNowForecast(timeseries, now);
    if (nowForecast != null) forecasts.add(nowForecast);

    // 2. 6-hour forecast (next_6_hours)
    final sixHourForecast = _extract6HourForecast(timeseries, now);
    if (sixHourForecast != null) forecasts.add(sixHourForecast);

    // 3. 12-hour forecast (next_12_hours)
    final twelveHourForecast = _extract12HourForecast(timeseries, now);
    if (twelveHourForecast != null) forecasts.add(twelveHourForecast);

    // 4. Tomorrow at noon
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowForecast = _extractDayForecast(timeseries, tomorrow);
    if (tomorrowForecast != null) forecasts.add(tomorrowForecast);

    // 5. Day after tomorrow at noon
    final dayAfterTomorrow = now.add(const Duration(days: 2));
    final dayAfterTomorrowForecast =
        _extractDayForecast(timeseries, dayAfterTomorrow);
    if (dayAfterTomorrowForecast != null) {
      forecasts.add(dayAfterTomorrowForecast);
    }

    // 6. Three days from now at noon
    final threeDays = now.add(const Duration(days: 3));
    final threeDaysForecast = _extractDayForecast(timeseries, threeDays);
    if (threeDaysForecast != null) forecasts.add(threeDaysForecast);

    return forecasts;
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
