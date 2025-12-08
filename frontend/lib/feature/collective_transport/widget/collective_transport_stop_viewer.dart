import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promillezone/feature/collective_transport/cubit/collective_transport_cubit.dart';
import 'package:promillezone/repository/collective_transport/repository.dart';
import 'package:intl/intl.dart';

class CollectiveTransportStopViewer extends StatelessWidget {
  const CollectiveTransportStopViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectiveTransportCubit, CollectiveTransportState>(
      builder: (context, state) {
        if (state is CollectiveTransportInitial) {
          return const Center(child: Text('Initializing...'));
        }

        if (state is CollectiveTransportInProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CollectiveTransportLoaded) {
          final stopPlace = state.stopPlaceData;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
                3: IntrinsicColumnWidth(),
                4: IntrinsicColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header row
                TableRow(
                  children: [
                    _buildHeaderCell('Linje'),
                    _buildHeaderCell('Destinasjon'),
                    _buildHeaderCell('Stoppested'),
                    _buildHeaderCell('Platform'),
                    _buildHeaderCell('Forventet'),
                  ],
                ),
                // Data rows
                ...stopPlace.departures.take(15).map((departure) {
                  return _buildDepartureRow(departure);
                }),
              ],
            ),
          );
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  TableRow _buildDepartureRow(Departure departure) {
    final now = DateTime.now();
    final expectedTime = departure.expectedDepartureTime;
    final difference = expectedTime.difference(now);
    final minutes = difference.inMinutes;

    // Parse colors from hex strings
    Color? backgroundColor;
    Color? textColor;

    if (departure.line.presentation.colour != null) {
      backgroundColor = _parseHexColor(departure.line.presentation.colour!);
    }

    if (departure.line.presentation.textColour != null) {
      textColor = _parseHexColor(departure.line.presentation.textColour!);
    }

    // Determine time display
    String timeDisplay;
    Color timeColor = Colors.white;

    if (minutes <= 0) {
      timeDisplay = 'Nå';
      timeDisplay += " 💀";
      timeColor = Colors.white;
    } else if (minutes < 10) {
      timeDisplay = '$minutes min';
      if (minutes <= 2) {
        timeColor = Colors.red;
        timeDisplay += " 💀";
      } else if (minutes <= 5) {
        timeColor = Colors.red.shade300;
        timeDisplay += " 💀";
      }
    } else {
      timeDisplay = DateFormat('HH:mm').format(expectedTime);
      timeColor = Colors.white;
    }

    return TableRow(
      children: [
        // Line badge
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTransportIcon(departure.transportMode),
                  color: textColor ?? Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  departure.line.publicCode,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Destination
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            departure.destinationDisplay.frontText,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        // Stop name
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            departure.quay.name,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        // Platform
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            departure.quay.publicCode,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        // Expected time
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeDisplay,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: timeColor,
                ),
              ),
              if (minutes < 10 && minutes > 0)
                Text(
                  DateFormat('HH:mm').format(expectedTime),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _parseHexColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.grey;
  }

  IconData _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.tram:
        return Icons.tram;
      case TransportMode.rail:
        return Icons.train;
      case TransportMode.metro:
        return Icons.subway;
      case TransportMode.water:
        return Icons.directions_boat;
      case TransportMode.air:
        return Icons.flight;
      case TransportMode.coach:
        return Icons.airport_shuttle;
      default:
        return Icons.directions;
    }
  }
}
