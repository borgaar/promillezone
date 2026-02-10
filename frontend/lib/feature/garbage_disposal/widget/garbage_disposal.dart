import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:promillezone/feature/kiosk/constants.dart';
import 'package:promillezone/feature/kiosk/container.dart';
import 'package:promillezone/repository/garbage_disposal/repository.dart';
import 'package:promillezone/ui/interval_switcher.dart';

bool Function(TrashScheduleEntry) shownInDay([int daysFromNow = 0]) => (entry) {
  // final today = DateTime.now();
  final today = DateTime.now();
  final theDay = today.add(Duration(days: daysFromNow));
  return theDay.month == entry.date.month &&
      theDay.day == entry.date.day &&
      theDay.year == entry.date.year;
};

class GarbageDisposal extends StatelessWidget {
  const GarbageDisposal({super.key});

  @override
  Widget build(BuildContext context) {
    return KioskPollingContainer<List<TrashScheduleEntry>>(
      omitPadding: true,
      buildSuccess: (context, value) {
        return IntervalSwitcher(
          interval: Duration(seconds: 5),
          children: [
            GarbageDisposalPlanList(entries: value),
            if (value.any(shownInDay(0)))
              GarbageDisposalToday(
                entries: value.where(shownInDay(0)).toList(),
                title: 'I dag',
              ),
            if (value.any(shownInDay(1)))
              GarbageDisposalToday(
                entries: value.where(shownInDay(1)).toList(),
                title: 'I morgen',
              ),
          ],
        );
      },
      mode: TransitionMode.slide,
    );
  }
}

class GarbageDisposalToday extends StatelessWidget {
  const GarbageDisposalToday({
    super.key,
    required this.entries,
    required this.title,
  });

  final String title;
  final List<TrashScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kioskContainerPadding,
      child: Center(
        child: Builder(
          builder: (context) {
            if (entries.length == 1) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 24),
                  ...entries.map((entry) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: entry.icons
                                .map((i) => Image(image: i, width: 120))
                                .toList(),
                          ),
                        ),
                        Text(entry.label, style: TextStyle(fontSize: 32)),
                      ],
                    );
                  }),
                ],
              );
            } else if (entries.length == 2) {
              return Column(
                spacing: 12,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.w600),
                  ),
                  ...entries.map((entry) {
                    return Row(
                      spacing: 24,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: entry.icons
                                .map(
                                  (i) => Image(
                                    image: i,
                                    width: 120 / entry.icons.length,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        SizedBox(
                          width: 145,
                          child: AutoSizeText(
                            entry.label,
                            style: TextStyle(fontSize: 32),
                            minFontSize: 12,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              );
            }
            throw UnimplementedError(
              'GarbageDisposalToday not implemented for ${entries.length} entries',
            );
          },
        ),
      ),
    );
  }
}

class GarbageDisposalPlanList extends StatelessWidget {
  const GarbageDisposalPlanList({super.key, required this.entries});

  final List<TrashScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kioskContainerPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: entries
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
      ),
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
