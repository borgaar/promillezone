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
    extends State<IntervalSwitcher<T>> {
  // ignore: unused_field Just saved as a variable
  late Timer _timer;
  late int _currentIndex;

  @override
  void initState() {
    assert(
      widget.initialIndex >= 0 && widget.initialIndex < widget.children.length,
      "initialIndex must be within the range of children",
    );

    _currentIndex = widget.initialIndex;
    _timer = Timer.periodic(widget.interval, (timer) {
      if (widget.children.length < 2) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.children.length;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.children[_currentIndex];
  }
}
