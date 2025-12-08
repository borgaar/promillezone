import 'package:flutter/material.dart';
import 'package:promillezone/feature/kiosk/constants.dart';
import 'package:promillezone/feature/kiosk/container.dart';

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
            return const SizedBox.shrink();
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
            children: [
              Text(
                '${snapshot.data!.hour.toString().padLeft(2, '0')}:${snapshot.data!.minute.toString().padLeft(2, '0')}:${snapshot.data!.second.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: kioskTextColor,
                  fontSize: 94,
                  fontWeight: FontWeight.w300,
                  fontFamily: "JetbrainsMono",
                  height: 1.2,
                ),
              ),
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 85,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.05,
                  height: 1,
                ),
              ),
              Text(
                '${snapshot.data!.day.toString()}. $monthText',
                style: const TextStyle(
                  color: kioskTextColor,
                  fontSize: 64,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                  letterSpacing: 0.64,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
