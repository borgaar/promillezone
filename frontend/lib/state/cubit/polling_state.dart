part of 'polling_cubit.dart';

sealed class PollingState<T extends Object> extends Equatable {
  const PollingState();

  @override
  List<Object> get props => [];
}

final class PollingInitial<T extends Object> extends PollingState<T> {}

final class PollingFailure<T extends Object> extends PollingState<T> {
  final String message;

  const PollingFailure({required this.message});

  @override
  get props => [...super.props, message];
}

final class PollingSuccess<T extends Object> extends PollingState<T> {
  final T value;

  const PollingSuccess({required this.value});

  @override
  get props => [...super.props, value];
}
