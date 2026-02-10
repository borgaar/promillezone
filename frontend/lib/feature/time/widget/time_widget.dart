import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promillezone/feature/kiosk/constants.dart';
import 'package:promillezone/feature/kiosk/container.dart';
import 'package:promillezone/ui/animated_flip_counter.dart';

class TimeWidget extends StatelessWidget {
  const TimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return KioskContainer(
      child: StreamBuilder(
        stream: Stream.periodic(
          const Duration(seconds: 1),
          (_) => DateTime.now(),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.expand();
          }

          final dateText = switch (snapshot.data!.weekday) {
            1 => "Mandag >:(",
            2 => "Tirsdag :(",
            3 => "Onsdag :|",
            4 => "Torsdag :)",
            5 => "Fredag B)",
            6 => "Lørdag :D",
            7 => "Søndag :/",
            _ => throw Exception("Invalid weekday"),
          };

          final monthText = switch (snapshot.data!.month) {
            1 => "Januar",
            2 => "Februar",
            3 => "Mars",
            4 => "April",
            5 => "Mai",
            6 => "Juni",
            7 => "Juli",
            8 => "August",
            9 => "September",
            10 => "Oktober",
            11 => "November",
            12 => "Desember",
            _ => throw Exception("Invalid month"),
          };

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CountingTime(current: snapshot.data!),
              Transform.translate(
                offset: const Offset(0, -10),
                child: Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 72,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.05,
                    height: 1.3,
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                spacing: 12,
                children: [
                  Transform.rotate(
                    filterQuality: FilterQuality.high,
                    angle: -0.10,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          Image.asset(
                            "asset/img/months/day.png",
                            width: 120,
                            fit: BoxFit.contain,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 75,
                              child: Text(
                                snapshot.data!.day.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 70,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "ComicNeue",
                                  height: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "asset/img/months/${DateFormat.MMMM("en").format(snapshot.data!).toLowerCase()}.png",
                        width: 380,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        width: 270,
                        height: 80,
                        child: Text(
                          monthText,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "ComicNeue",
                            fontSize: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

final _tStyle = const TextStyle(
  color: kioskTextColor,
  fontSize: 94,
  fontWeight: FontWeight.w300,
  fontFamily: "JetbrainsMono",
  height: 1.2,
);
final _curve = Curves.easeInOutCubic;
final _duration = Duration(milliseconds: 200);

class CountingTime extends StatelessWidget {
  const CountingTime({super.key, required this.current});

  final DateTime current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedFlipCounter(
          value: current.hour,
          textStyle: _tStyle,
          curve: _curve,
          duration: _duration,
          hideLeadingZeroes: false,
          wholeDigits: 2,
        ),
        Text(":", style: _tStyle),
        AnimatedFlipCounter(
          value: current.minute,
          textStyle: _tStyle,
          curve: _curve,
          duration: _duration,
          hideLeadingZeroes: false,
          wholeDigits: 2,
        ),
        Text(":", style: _tStyle),
        AnimatedFlipCounter(
          value: current.second,
          textStyle: _tStyle,
          curve: _curve,
          duration: _duration,
          hideLeadingZeroes: false,
          wholeDigits: 2,
        ),
      ],
    );
  }
}
