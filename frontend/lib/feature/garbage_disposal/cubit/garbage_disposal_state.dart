part of 'garbage_disposal_cubit.dart';

sealed class GarbageDisposalState extends Equatable {
  const GarbageDisposalState();

  @override
  List<Object> get props => [];
}

final class GarbageDisposalInitial extends GarbageDisposalState {}

final class GarbageDisposalLoaded extends GarbageDisposalState {
  final List<TrashScheduleEntry> trashSchedule;

  const GarbageDisposalLoaded({required this.trashSchedule});

  @override
  List<Object> get props => [trashSchedule];
}
