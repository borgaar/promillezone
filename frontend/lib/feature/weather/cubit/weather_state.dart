part of 'weather_cubit.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

final class WeatherInitial extends WeatherState {}

final class WeatherInProgress extends WeatherState {}

final class WeatherLoaded extends WeatherState {
  final WeatherData weatherData;

  const WeatherLoaded({required this.weatherData});

  @override
  List<Object> get props => [weatherData];
}
