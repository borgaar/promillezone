import 'package:flutter/material.dart';
import 'package:promillezone/feature/kiosk/constants.dart';
import 'package:promillezone/feature/kiosk/container.dart';
import 'package:promillezone/repository/collective_transport/repository.dart';
import 'package:intl/intl.dart';

class CollectiveTransportStopViewer extends StatelessWidget {
  const CollectiveTransportStopViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return KioskPollingContainer<StopPlace>(
      buildSuccess: (context, value) {
        return Container(
          color: kioskBackgroundColor,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(6),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(1),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Header row
              TableRow(
                children: [
                  _buildHeaderCell('Nr.'),
                  _buildHeaderCell('Destinasjon', align: TextAlign.left),
                  _buildHeaderCell('Plt.'),
                  _buildHeaderCell('Status'),
                  _buildHeaderCell('Tid'),
                  _buildHeaderCell('Kl.'),
                ],
              ),
              // Data rows
              ...value.departures
                  .where((d) => d.untilMinutes >= 5)
                  .take(7)
                  .expand(
                    (departure) => [
                      _buildDepartureRow(departure),
                      TableRow(
                        children: List.generate(
                          6,
                          (index) => SizedBox(height: 12),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        );
      },
      mode: TransitionMode.fade,
    );
  }

  Widget _buildHeaderCell(String text, {TextAlign align = TextAlign.center}) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      textAlign: align,
    );
  }

  TableRow _buildDepartureRow(Departure departure) {
    final minutes = departure.untilMinutes;

    final minute = 1000 * 60;
    final isDelayed =
        (departure.expectedDepartureTime.millisecondsSinceEpoch / minute)
                .round() -
            1 >
        (departure.aimedDepartureTime.millisecondsSinceEpoch / minute).round();

    int timePadding = 0;

    if (departure.quay.publicCode == "2" || departure.quay.publicCode == "3") {
      // These platforms are on the other side of the road, so we add 1 minute of extra time to go
      timePadding += 1;
    }

    final status = switch (minutes + timePadding) {
      <= 5 => "skull",
      6 => "spurt",
      7 => "løp",
      8 => "jogg",
      9 => "gå",
      10 => "ferdig",
      11 => "klar",
      12 => "gucci",
      >= 13 => "chillern",
      _ => throw Exception("Unreachable"),
    };

    var destination = departure.destinationDisplay.frontText;

    final maxLength = 29;
    if (destination.length > maxLength) {
      destination = '${destination.substring(0, maxLength - 3)}...';
    }

    return TableRow(
      children: [
        // Line badge
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: departure.line.publicCode.startsWith("FB")
                  ? Colors.grey
                  : Color(0xffA9D22D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                departure.line.publicCode,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
          ),
        ),
        // Destination
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(destination, style: const TextStyle(fontSize: 32)),
        ),
        // Platform
        Text(
          departure.quay.publicCode,
          style: const TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        // Status
        if (status == "skull")
          Image.asset("asset/img/skull_emoji.png", height: 32)
        else
          Text(
            status,
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        // Expected time
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisSize: MainAxisSize.min,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              minutes > 59
                  ? (minutes / 60).floor().toString()
                  : minutes.toString(),
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 3),
            Text(
              minutes > 59
                  ? "time${(minutes / 60).floor() != 1 ? "r" : ""}"
                  : "min",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              formatTime(departure.expectedDepartureTime),
              style: TextStyle(
                fontSize: 24,
                color: isDelayed ? Colors.red : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isDelayed)
              Text(
                formatTime(departure.aimedDepartureTime),
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontSize: 18,
                ),
              )
            else
              SizedBox(height: 0),
          ],
        ),
      ],
    );
  }
}

String formatTime(DateTime time) {
  final formatter = DateFormat.Hm();
  return formatter.format(time);
}
