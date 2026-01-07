import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:promillezone/repository/weather/repository.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({required this.repository}) : super(WeatherInitial());

  final WeatherRepository repository;
  // ignore: unused_field
  late final Timer _timer;

  Future<void> _fetchWeather() async {
    final data = await repository.getForecast(
      latitude: 63.417616,
      longitude: 10.421926,
    );

    emit(WeatherLoaded(weatherData: data));
  }

  Future<void> initialize() async {
    _fetchWeather();

    // Start periodic updates every 15 minutes
    _timer = Timer.periodic(const Duration(minutes: 15), (_) async {
      _fetchWeather();
    });
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
