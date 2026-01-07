import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:promillezone/repository/garbage_disposal/repository.dart';

part 'garbage_disposal_state.dart';

class GarbageDisposalCubit extends Cubit<GarbageDisposalState> {
  GarbageDisposalCubit({required this.repository})
    : super(GarbageDisposalInitial());

  final GarbageDisposalRepository repository;
  // ignore: unused_field
  late final Timer _timer;

  Future<void> _fetchTrashSchedule(String addressId) async {
    final data = await repository.getTrashSchedule(addressId: addressId);

    emit(GarbageDisposalLoaded(trashSchedule: data));
  }

  Future<void> initialize({required String addressId}) async {
    _fetchTrashSchedule(addressId);

    // Start periodic updates every hour
    _timer = Timer.periodic(const Duration(hours: 1), (_) async {
      _fetchTrashSchedule(addressId);
    });
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
