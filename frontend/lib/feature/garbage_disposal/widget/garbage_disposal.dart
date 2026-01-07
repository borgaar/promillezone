import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promillezone/feature/garbage_disposal/cubit/garbage_disposal_cubit.dart';
import 'package:promillezone/feature/kiosk/container.dart';

class GarbageDisposal extends StatelessWidget {
  const GarbageDisposal({super.key});

  @override
  Widget build(BuildContext context) {
    return KioskContainer(
      child: BlocBuilder<GarbageDisposalCubit, GarbageDisposalState>(
        builder: (context, state) {
          if (state is! GarbageDisposalLoaded) {
            return SizedBox.expand();
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: state.trashSchedule.take(5).map((entry) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: entry.icons
                            .map(
                              (i) => ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(16),
                                child: Image(image: i, width: 80),
                              ),
                            )
                            .toList(),
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
            }).toList(),
          );
        },
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
