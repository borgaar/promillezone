import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promillezone/feature/daily_content/cubit/daily_content_cubit.dart';
import 'package:promillezone/feature/kiosk/constants.dart';
import 'package:promillezone/feature/kiosk/container.dart';

const titleStyle = TextStyle(
  color: kioskTextColor,
  fontSize: 40,
  fontWeight: FontWeight.w700,
  fontFamily: "Inter",
);

class DailyContentWidget extends StatelessWidget {
  const DailyContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return KioskContainer(
      child: BlocBuilder<DailyContentCubit, DailyContentState>(
        builder: (context, state) {
          return switch (state) {
            DailyContentInitial() => SizedBox.expand(),
            DailyContentFailure(:final errorMessage) => const Center(
              child: Text("Failed to load daily content"),
            ),
            DailyContentSuccess(:final joke, :final quote, :final cat) => Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Dagens katt",
                        style: titleStyle,
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(
                            kioskBorderRadius / 2,
                          ),
                          child: Image(image: cat, fit: BoxFit.fill),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Dagens vits",
                        style: titleStyle,
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              joke,
                              style: const TextStyle(
                                color: kioskTextColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                fontFamily: "ComicNeue",
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Dagens visdomsord",
                        style: titleStyle,
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              quote,
                              style: const TextStyle(
                                color: kioskTextColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                fontFamily: "SourceSerif",
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          };
        },
      ),
    );
  }
}
