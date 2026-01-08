import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'polling_state.dart';

class PollingCubit<T extends Object> extends Cubit<PollingState<T>> {
  /// Create a PollingCubit.
  ///
  /// Do not forget to call initialize() when created.
  ///
  /// ```
  /// PollingCubit(onPoll: () => value, interval: Duration(seconds: 3))..initialize()
  /// ```
  PollingCubit({required this.onPoll, required this.interval})
    : super(PollingInitial<T>());

  final Future<T> Function() onPoll;
  final Duration interval;

  // ignore: unused_field
  late final Timer _timer;

  Future<void> _poll() async {
    try {
      final data = await onPoll();

      emit(PollingSuccess<T>(value: data));
    } catch (e) {
      emit(PollingFailure<T>(message: e.toString()));
    }
  }

  Future<void> initialize() async {
    _poll();

    // Start periodic updates every 5 seconds
    _timer = Timer.periodic(interval, (_) => _poll());
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
