import 'dart:async';

import 'package:flutter/material.dart';

class IntervalSwitcher<T extends Object> extends StatefulWidget {
  const IntervalSwitcher({
    super.key,
    required this.children,
    required this.interval,
    this.initialIndex = 0,
  });

  final List<Widget> children;
  final Duration interval;
  final int initialIndex;

  @override
  State<IntervalSwitcher<T>> createState() => _IntervalSwitcherState();
}

class _IntervalSwitcherState<T extends Object>
    extends State<IntervalSwitcher<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  // ignore: unused_field Just saved as a variable
  late Timer _timer;
  late int _currentIndex;

  @override
  void initState() {
    assert(
      widget.initialIndex >= 0 && widget.initialIndex < widget.children.length,
      "initialIndex must be within the range of children",
    );

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _currentIndex = widget.initialIndex;
    _timer = Timer.periodic(widget.interval, (timer) {
      if (widget.children.length < 2) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.children.length;
        _controller.forward(from: 0);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                bottom: constraints.maxHeight * (_animation.value - 1),
                child: widget.children[_currentIndex],
              ),
              Positioned(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                bottom: constraints.maxHeight * _animation.value,
                child:
                    widget.children[(_currentIndex -
                            1 +
                            widget.children.length) %
                        widget.children.length],
              ),
            ],
          );
        },
      ),
    );
  }
}
