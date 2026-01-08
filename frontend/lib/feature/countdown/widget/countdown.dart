import 'dart:io';

import 'package:flutter/material.dart';
import 'package:promillezone/feature/kiosk/container.dart';

class Countdown extends StatelessWidget {
  const Countdown({super.key});

  @override
  Widget build(BuildContext context) {
    return KioskContainer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Dager siden siste strømbrudd",
                style: TextStyle(fontSize: 20),
              ),
              FutureBuilder(
                future: () async {
                  final output = await Process.run("who", ["-b"]);
                  assert(output.stdout is String);

                  final date = (output.stdout as String).trim().split(" ")[3];

                  final lastReboot = DateTime.parse(date);

                  return lastReboot;
                }(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text("Feil ved henting av data: ${snapshot.error}");
                  }

                  final lastReboot = snapshot.data!;
                  final now = DateTime.now();

                  final difference = now.difference(lastReboot).inDays;

                  return Text(
                    "$difference ${difference == 0 ? ":(" : ""}",
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
