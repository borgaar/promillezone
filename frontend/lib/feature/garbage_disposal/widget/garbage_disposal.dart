import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promillezone/feature/garbage_disposal/cubit/garbage_disposal_cubit.dart';
import 'package:promillezone/repository/garbage_disposal/repository.dart';

class GarbageDisposal extends StatelessWidget {
  const GarbageDisposal({super.key});

  String _getCategoryName(TrashCategory category) {
    return switch (category) {
      TrashCategory.glassMetal => 'Glass og metall',
      TrashCategory.food => 'Matavfall',
      TrashCategory.paper => 'Papir',
      TrashCategory.plastic => 'Plast',
      TrashCategory.rest => 'Restavfall',
    };
  }

  IconData _getCategoryIcon(TrashCategory category) {
    return switch (category) {
      TrashCategory.glassMetal => Icons.recycling,
      TrashCategory.food => Icons.restaurant,
      TrashCategory.paper => Icons.article,
      TrashCategory.plastic => Icons.delete_outline,
      TrashCategory.rest => Icons.delete,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarbageDisposalCubit, GarbageDisposalState>(
      builder: (context, state) {
        if (state is GarbageDisposalLoaded) {
          final entries = state.trashSchedule.take(7).toList();
          final dateFormat = DateFormat('dd.MM.yyyy');

          return Column(
            children: [
              Text(
                "Avfallskalender",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ...entries.map(
                (entry) => ListTile(
                  leading: Icon(_getCategoryIcon(entry.type)),
                  title: Text(_getCategoryName(entry.type)),
                  trailing: Text(dateFormat.format(entry.date)),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
