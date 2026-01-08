import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promillezone/repository/collective_transport/entur.dart';
import 'package:promillezone/repository/collective_transport/repository.dart';
import 'package:promillezone/repository/dynamic_content/repository.dart';
import 'package:promillezone/repository/dynamic_content/static.dart';
import 'package:promillezone/repository/garbage_disposal/repository.dart';
import 'package:promillezone/repository/garbage_disposal/trv.dart';
import 'package:promillezone/repository/weather/repository.dart';
import 'package:promillezone/repository/weather/yr.dart';
import 'package:promillezone/state/cubit/polling_cubit.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WeatherRepository>(
          create: (_) => YrWeatherRepository(),
        ),
        RepositoryProvider<CollectiveTransportRepository>(
          create: (_) => EnturCollectiveTransportRepository(),
        ),
        RepositoryProvider<GarbageDisposalRepository>(
          create: (_) => TrvGarbageDisposalRepository(),
        ),
        RepositoryProvider<DynamicContentRepository>(
          create: (_) => StaticDynamicContentRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PollingCubit(
              onPoll: () => context.read<WeatherRepository>().getForecast(
                latitude: 63.417616,
                longitude: 10.421926,
              ),
              interval: Duration(minutes: 1),
            )..initialize(),
          ),
          BlocProvider(
            create: (context) => PollingCubit(
              onPoll: () => context
                  .read<CollectiveTransportRepository>()
                  .getDepartures(stopPlaceId: 'NSR:StopPlace:42528'),
              interval: Duration(seconds: 3),
            )..initialize(),
          ),
          BlocProvider(
            create: (context) => PollingCubit(
              onPoll: () =>
                  context.read<GarbageDisposalRepository>().getTrashSchedule(
                    addressId: "c15582ed-a56c-4e8f-bc1a-0ac037b97470",
                  ),
              interval: Duration(hours: 1),
            )..initialize(),
          ),
          BlocProvider(
            create: (context) {
              final repo = context.read<DynamicContentRepository>();

              return PollingCubit(
                onPoll: repo.pollContent,
                interval: repo.pollingInterval,
              )..initialize();
            },
          ),
        ],
        child: child,
      ),
    );
  }
}
