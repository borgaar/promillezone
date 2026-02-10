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

  static const _recoveryInterval = Duration(seconds: 5);

  final Future<T> Function() onPoll;
  final Duration interval;

  Timer? _timer;
  bool _isRecovering = false;

  Future<void> _poll() async {
    try {
      final data = await onPoll();
      _isRecovering = false;
      emit(PollingSuccess<T>(value: data));
    } catch (e) {
      _isRecovering = true;
      emit(PollingFailure<T>(message: e.toString()));
    }
    _scheduleNextPoll();
  }

  void _scheduleNextPoll() {
    _timer?.cancel();
    final nextInterval = _isRecovering ? _recoveryInterval : interval;
    _timer = Timer(nextInterval, _poll);
  }

  Future<void> initialize() async {
    _poll();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
