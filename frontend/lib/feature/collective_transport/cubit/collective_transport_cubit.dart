import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:promillezone/repository/collective_transport/repository.dart';

part 'collective_transport_state.dart';

class CollectiveTransportCubit extends Cubit<CollectiveTransportState> {
  CollectiveTransportCubit({required this.repository})
    : super(CollectiveTransportInitial());

  final CollectiveTransportRepository repository;
  // ignore: unused_field
  late final Timer _timer;

  Future<void> _fetchDepartures() async {
    final data = await repository.getDepartures(
      stopPlaceId: 'NSR:StopPlace:42528',
    );

    emit(
      CollectiveTransportLoaded(
        stopPlaceData: data,
        departures: data.departures,
      ),
    );
  }

  Future<void> initialize() async {
    _fetchDepartures();

    // Start periodic updates every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      _fetchDepartures();
    });
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
