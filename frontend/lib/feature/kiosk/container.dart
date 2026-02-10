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

enum TransitionMode { slide, fade }

class KioskPollingContainer<T extends Object> extends StatefulWidget {
  const KioskPollingContainer({
    super.key,
    required this.buildSuccess,
    required this.mode,
    this.omitPadding = false,
  });

  final Widget Function(BuildContext context, T value) buildSuccess;
  final TransitionMode mode;
  final bool omitPadding;

  @override
  State<KioskPollingContainer<T>> createState() =>
      _KioskPollingContainerState();
}

class _KioskPollingContainerState<T extends Object>
    extends State<KioskPollingContainer<T>>
    with SingleTickerProviderStateMixin {
  T? previousState;
  T? currentState;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.mode == TransitionMode.fade ? 500 : 1000,
      ),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KioskContainer(
      child: LayoutBuilder(
        builder: (context, constraints) =>
            BlocConsumer<PollingCubit<T>, PollingState<T>>(
              listenWhen: (previous, current) => current is PollingSuccess<T>,
              listener: (context, state) {
                setState(() {
                  previousState = currentState;
                  currentState = (state as PollingSuccess<T>).value;
                  _controller.forward(from: 0);
                });
              },
              builder: (context, state) {
                return switch (state) {
                  PollingInitial<T>() => SizedBox.expand(),
                  PollingFailure<T>(:final message) => Center(
                    child: Text(message, style: TextStyle(color: Colors.red)),
                  ),
                  PollingSuccess<T>(:final value) => AnimatedBuilder(
                    animation: _animation,
                    builder: (context, _) {
                      return Stack(
                        children: [
                          Positioned(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            bottom: () {
                              if (previousState == null ||
                                  widget.mode != TransitionMode.slide) {
                                return 0.0;
                              }

                              return constraints.maxHeight *
                                  (_animation.value - 1);
                            }(),

                            child: Transform.scale(
                              scale: previousState == null
                                  ? _animation.value
                                  : 1,
                              child: Padding(
                                padding: widget.omitPadding
                                    ? EdgeInsets.zero
                                    : kioskContainerPadding,
                                child: widget.buildSuccess(context, value),
                              ),
                            ),
                          ),
                          if (previousState != null)
                            Positioned(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth,
                              bottom: widget.mode != TransitionMode.slide
                                  ? 0
                                  : constraints.maxHeight * _animation.value,
                              child: Opacity(
                                opacity: widget.mode == TransitionMode.fade
                                    ? 1 - _animation.value
                                    : 1,
                                child: Padding(
                                  padding: widget.omitPadding
                                      ? EdgeInsets.zero
                                      : kioskContainerPadding,
                                  child: widget.buildSuccess(
                                    context,
                                    previousState!,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                };
              },
            ),
      ),
    );
  }
}
