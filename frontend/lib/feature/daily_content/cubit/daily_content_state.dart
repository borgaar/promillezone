part of 'daily_content_cubit.dart';

sealed class DailyContentState extends Equatable {
  const DailyContentState();

  @override
  List<Object> get props => [];
}

final class DailyContentInitial extends DailyContentState {}

final class DailyContentSuccess extends DailyContentState {
  const DailyContentSuccess({
    required this.joke,
    required this.quote,
    required this.cat,
  });

  final String joke;
  final String quote;
  final ImageProvider cat;

  @override
  List<Object> get props => [joke, quote, cat];
}

final class DailyContentFailure extends DailyContentState {
  const DailyContentFailure({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}
