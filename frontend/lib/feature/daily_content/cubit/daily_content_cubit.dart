import 'package:bloc/bloc.dart';
import 'package:cron/cron.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

part 'daily_content_state.dart';

class DailyContentCubit extends Cubit<DailyContentState> {
  DailyContentCubit() : super(DailyContentInitial());

  Cron? _cron;

  Future<void> initialize() async {
    final catImageResponse = await Dio().get(
      "https://cataas.com/cat?width=300&height=300",
      options: Options(responseType: ResponseType.bytes),
    );

    if (catImageResponse.statusCode != 200) {
      emit(const DailyContentFailure(errorMessage: "Failed to load cat image"));
      return;
    }

    final image = MemoryImage(catImageResponse.data);

    final jokeResponse = await Dio().get(
      "https://icanhazdadjoke.com/",
      options: Options(headers: {"Accept": "application/json"}),
    );

    if (jokeResponse.statusCode != 200) {
      emit(const DailyContentFailure(errorMessage: "Failed to load joke"));
      return;
    }

    final joke = jokeResponse.data["joke"] as String;

    final quoteResponse = await Dio().get("https://api.kanye.rest/");

    if (quoteResponse.statusCode != 200) {
      emit(const DailyContentFailure(errorMessage: "Failed to load quote"));
      return;
    }

    final quote = quoteResponse.data["quote"] as String;

    emit(DailyContentSuccess(cat: image, joke: joke, quote: quote));

    // Schedule daily refresh at 00:01 AM
    _cron ??= Cron()
      ..schedule(Schedule.parse('1 0 * * *'), () async {
        await initialize();
      });
  }
}
