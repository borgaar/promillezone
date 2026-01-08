import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promillezone/feature/kiosk/container.dart';
import 'package:promillezone/repository/garbage_disposal/repository.dart';

class GarbageDisposal extends StatelessWidget {
  const GarbageDisposal({super.key});

  @override
  Widget build(BuildContext context) {
    return KioskPollingContainer<List<TrashScheduleEntry>>(
      buildSuccess: (context, value) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: value
              .fold(<TrashCategory, TrashScheduleEntry>{}, (
                previousValue,
                element,
              ) {
                if (!previousValue.containsKey(element.type)) {
                  previousValue[element.type] = element;
                }
                return previousValue;
              })
              .values
              .take(8)
              .map((entry) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          child: Row(
                            children: entry.icons
                                .map((i) => Image(image: i, width: 64))
                                .toList(),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatRelativeDay(entry.date),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              entry.label,
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              })
              .toList(),
        );
      },
      mode: TransitionMode.slide,
    );
  }
}

String formatRelativeDay(DateTime date) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime tomorrow = today.add(const Duration(days: 1));
  final DateTime overmorrow = today.add(const Duration(days: 2));

  final DateTime dateOnly = DateTime(date.year, date.month, date.day);

  if (dateOnly == today) {
    return "I dag";
  } else if (dateOnly == tomorrow) {
    return "I morgen";
  } else if (dateOnly == overmorrow) {
    return "Overimorgen";
  } else {
    // Fallback to a standard format for other dates
    return DateFormat.MMMMd().format(date);
  }
}
