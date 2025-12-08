import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promillezone/feature/collective_transport/cubit/collective_transport_cubit.dart';
import 'package:promillezone/feature/daily_content/cubit/daily_content_cubit.dart';
import 'package:promillezone/feature/garbage_disposal/cubit/garbage_disposal_cubit.dart';
import 'package:promillezone/feature/weather/cubit/weather_cubit.dart';
import 'package:promillezone/repository/collective_transport/entur.dart';
import 'package:promillezone/repository/collective_transport/repository.dart';
import 'package:promillezone/repository/garbage_disposal/repository.dart';
import 'package:promillezone/repository/garbage_disposal/trv.dart';
import 'package:promillezone/repository/weather/repository.dart';
import 'package:promillezone/repository/weather/weather_api.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WeatherRepository>(
          create: (_) => WeatherApiRepository(),
        ),
        RepositoryProvider<CollectiveTransportRepository>(
          create: (_) => EnturCollectiveTransportRepository(),
        ),
        RepositoryProvider<GarbageDisposalRepository>(
          create: (_) => TrvGarbageDisposalRepository(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    WeatherCubit(repository: context.read())..initialize(),
              ),
              BlocProvider(
                create: (context) =>
                    CollectiveTransportCubit(repository: context.read())
                      ..initialize(),
              ),
              BlocProvider(
                create: (context) =>
                    GarbageDisposalCubit(repository: context.read())
                      ..initialize(
                        addressId: "c15582ed-a56c-4e8f-bc1a-0ac037b97470",
                      ),
              ),
              BlocProvider(
                create: (context) => DailyContentCubit()..initialize(),
              ),
            ],
            child: child,
          );
        },
      ),
    );
  }
}
