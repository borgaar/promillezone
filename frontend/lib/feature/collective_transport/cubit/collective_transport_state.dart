part of 'collective_transport_cubit.dart';

sealed class CollectiveTransportState extends Equatable {
  const CollectiveTransportState();

  @override
  List<Object> get props => [];
}

final class CollectiveTransportInitial extends CollectiveTransportState {}

final class CollectiveTransportInProgress extends CollectiveTransportState {}

final class CollectiveTransportLoaded extends CollectiveTransportState {
  final StopPlace stopPlaceData;

  const CollectiveTransportLoaded({required this.stopPlaceData});

  @override
  List<Object> get props => [stopPlaceData];
}
