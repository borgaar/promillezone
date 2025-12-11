part of 'collective_transport_cubit.dart';

sealed class CollectiveTransportState extends Equatable {
  const CollectiveTransportState();

  @override
  List<Object> get props => [];
}

final class CollectiveTransportInitial extends CollectiveTransportState {}

final class CollectiveTransportLoaded extends CollectiveTransportState {
  final StopPlace stopPlaceData;
  final List<Departure> departures;

  CollectiveTransportLoaded({
    required this.stopPlaceData,
    required this.departures,
  }) {
    departures.sort(
      (a, b) =>
          a.expectedDepartureTime.millisecondsSinceEpoch -
          b.expectedDepartureTime.millisecondsSinceEpoch,
    );
  }

  @override
  List<Object> get props => [stopPlaceData, departures];
}
