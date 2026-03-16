import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promillezone/feature/kiosk/constants.dart';
import 'package:promillezone/state/cubit/polling_cubit.dart';

class KioskContainer extends StatelessWidget {
  const KioskContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kioskBackgroundColor,
        borderRadius: BorderRadius.circular(kioskBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class KioskPollingContainer<T extends Object> extends StatelessWidget {
  const KioskPollingContainer({
    super.key,
    required this.buildSuccess,
    this.omitPadding = false,
  });

  final Widget Function(BuildContext context, T value) buildSuccess;
  final bool omitPadding;

  @override
  Widget build(BuildContext context) {
    return KioskContainer(
      child: BlocBuilder<PollingCubit<T>, PollingState<T>>(
        builder: (context, state) {
          return switch (state) {
            PollingInitial<T>() => SizedBox.expand(),
            PollingFailure<T>(:final message) => Center(
              child: Text(message, style: TextStyle(color: Colors.red)),
            ),
            PollingSuccess<T>(:final value) => Padding(
              padding: omitPadding
                  ? EdgeInsets.zero
                  : kioskContainerPadding,
              child: buildSuccess(context, value),
            ),
          };
        },
      ),
    );
  }
}
